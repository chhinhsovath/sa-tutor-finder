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
    if (!decoded) {
      return NextResponse.json(
        { error: { message: 'Invalid or expired token', code: 'UNAUTHORIZED' } },
        { status: 401 }
      );
    }

    const { searchParams } = new URL(request.url);
    const status = searchParams.get('status');

    let query = `
      SELECT s.*,
             m.name as mentor_name, m.email as mentor_email,
             st.name as student_name, st.email as student_email
      FROM sessions s
      JOIN mentors m ON s.mentor_id = m.id
      JOIN students st ON s.student_id = st.id
      WHERE s.mentor_id = $1
    `;
    const params: any[] = [decoded.mentor_id];

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
    if (!decoded) {
      return NextResponse.json(
        { error: { message: 'Invalid or expired token', code: 'UNAUTHORIZED' } },
        { status: 401 }
      );
    }

    // This route requires student authentication to book sessions
    // Current system only supports mentor auth, so return error
    return NextResponse.json(
      {
        error: {
          message: 'Session booking requires student authentication (not yet implemented)',
          code: 'NOT_IMPLEMENTED'
        }
      },
      { status: 501 }
    );
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
