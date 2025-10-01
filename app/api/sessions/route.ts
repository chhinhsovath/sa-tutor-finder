import { NextRequest, NextResponse } from 'next/server';
import pool from '@/lib/db';
import { verifyToken } from '@/lib/auth';

export const dynamic = 'force-dynamic';

// GET /api/sessions - List sessions (for student or mentor)
export async function GET(request: NextRequest) {
  try {
    const token = request.headers.get('authorization')?.replace('Bearer ', '');
    if (!token) {
      return NextResponse.json(
        { error: { message: 'Authorization token required', code: 'UNAUTHORIZED' } },
        { status: 401 }
      );
    }

    const decoded = verifyToken(token);
    const { searchParams } = new URL(request.url);
    const status = searchParams.get('status');
    const userType = searchParams.get('user_type'); // 'student' or 'mentor'

    let query = `
      SELECT s.*,
             m.name as mentor_name, m.email as mentor_email,
             st.name as student_name, st.email as student_email
      FROM sessions s
      JOIN mentors m ON s.mentor_id = m.id
      JOIN students st ON s.student_id = st.id
      WHERE 1=1
    `;
    const params: any[] = [];

    if (userType === 'mentor') {
      params.push(decoded.mentor_id);
      query += ` AND s.mentor_id = $${params.length}`;
    } else if (userType === 'student') {
      params.push(decoded.student_id);
      query += ` AND s.student_id = $${params.length}`;
    }

    if (status) {
      params.push(status);
      query += ` AND s.status = $${params.length}`;
    }

    query += ' ORDER BY s.session_date DESC, s.start_time DESC';

    const result = await pool.query(query, params);

    return NextResponse.json({
      sessions: result.rows,
      count: result.rows.length
    });
  } catch (error: any) {
    console.error('Get sessions error:', error);
    return NextResponse.json(
      {
        error: {
          message: 'Internal server error while fetching sessions',
          code: 'INTERNAL_ERROR',
          meta: { error: error.message }
        }
      },
      { status: 500 }
    );
  }
}

// POST /api/sessions - Book a new session
export async function POST(request: NextRequest) {
  try {
    const token = request.headers.get('authorization')?.replace('Bearer ', '');
    if (!token) {
      return NextResponse.json(
        { error: { message: 'Authorization token required', code: 'UNAUTHORIZED' } },
        { status: 401 }
      );
    }

    const decoded = verifyToken(token);
    const body = await request.json();
    const { mentor_id, session_date, start_time, end_time, notes } = body;

    if (!mentor_id || !session_date || !start_time || !end_time) {
      return NextResponse.json(
        {
          error: {
            message: 'Missing required fields: mentor_id, session_date, start_time, end_time',
            code: 'VALIDATION_ERROR'
          }
        },
        { status: 400 }
      );
    }

    // Check if mentor is available at that time
    const availabilityCheck = await pool.query(
      `SELECT * FROM availability_slots
       WHERE mentor_id = $1
       AND day_of_week = EXTRACT(ISODOW FROM $2::DATE)
       AND start_time <= $3::TIME
       AND end_time >= $4::TIME`,
      [mentor_id, session_date, start_time, end_time]
    );

    if (availabilityCheck.rows.length === 0) {
      return NextResponse.json(
        {
          error: {
            message: 'Mentor is not available at the selected time',
            code: 'MENTOR_NOT_AVAILABLE'
          }
        },
        { status: 400 }
      );
    }

    // Check for conflicting sessions
    const conflictCheck = await pool.query(
      `SELECT * FROM sessions
       WHERE mentor_id = $1
       AND session_date = $2
       AND status != 'cancelled'
       AND (
         (start_time <= $3::TIME AND end_time > $3::TIME) OR
         (start_time < $4::TIME AND end_time >= $4::TIME) OR
         (start_time >= $3::TIME AND end_time <= $4::TIME)
       )`,
      [mentor_id, session_date, start_time, end_time]
    );

    if (conflictCheck.rows.length > 0) {
      return NextResponse.json(
        {
          error: {
            message: 'This time slot is already booked',
            code: 'TIME_SLOT_CONFLICT'
          }
        },
        { status: 400 }
      );
    }

    const result = await pool.query(
      `INSERT INTO sessions (student_id, mentor_id, session_date, start_time, end_time, notes, status)
       VALUES ($1, $2, $3, $4, $5, $6, 'scheduled')
       RETURNING *`,
      [decoded.student_id, mentor_id, session_date, start_time, end_time, notes || null]
    );

    return NextResponse.json({
      session: result.rows[0],
      message: 'Session booked successfully'
    }, { status: 201 });
  } catch (error: any) {
    console.error('Create session error:', error);
    return NextResponse.json(
      {
        error: {
          message: 'Internal server error while creating session',
          code: 'INTERNAL_ERROR',
          meta: { error: error.message }
        }
      },
      { status: 500 }
    );
  }
}
