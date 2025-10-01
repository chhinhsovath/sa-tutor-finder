import { NextRequest, NextResponse } from 'next/server';
import pool from '@/lib/db';
import { verifyToken } from '@/lib/auth';

export const dynamic = 'force-dynamic';

// POST /api/sessions/[id]/feedback - Mentor provides feedback after session
export async function POST(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id: session_id } = await params;
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

    const body = await request.json();
    const { rating, student_performance, notes } = body;

    // Verify session belongs to mentor
    const sessionCheck = await pool.query(
      'SELECT * FROM sessions WHERE id = $1 AND mentor_id = $2',
      [session_id, decoded.mentor_id]
    );

    if (sessionCheck.rows.length === 0) {
      return NextResponse.json(
        { error: { message: 'Session not found or unauthorized', code: 'FORBIDDEN' } },
        { status: 403 }
      );
    }

    const session = sessionCheck.rows[0];

    // Check if feedback already exists
    const existingFeedback = await pool.query(
      'SELECT * FROM session_feedback WHERE session_id = $1',
      [session_id]
    );

    let result;
    if (existingFeedback.rows.length > 0) {
      // Update existing feedback
      result = await pool.query(
        `UPDATE session_feedback
         SET rating = $1, student_performance = $2, notes = $3
         WHERE session_id = $4
         RETURNING *`,
        [rating || null, student_performance || null, notes || null, session_id]
      );
    } else {
      // Create new feedback
      result = await pool.query(
        `INSERT INTO session_feedback (session_id, mentor_id, student_id, rating, student_performance, notes)
         VALUES ($1, $2, $3, $4, $5, $6)
         RETURNING *`,
        [session_id, decoded.mentor_id, session.student_id, rating || null, student_performance || null, notes || null]
      );
    }

    return NextResponse.json({
      feedback: result.rows[0],
      message: 'Feedback submitted successfully'
    });
  } catch (error: any) {
    console.error('Submit feedback error:', error);
    return NextResponse.json(
      {
        error: {
          message: 'Internal server error while submitting feedback',
          code: 'INTERNAL_ERROR',
          meta: { error: error.message }
        }
      },
      { status: 500 }
    );
  }
}

// GET /api/sessions/[id]/feedback - Get session feedback
export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id: session_id } = await params;
    const token = request.headers.get('authorization')?.replace('Bearer ', '');
    if (!token) {
      return NextResponse.json(
        { error: { message: 'Authorization token required', code: 'UNAUTHORIZED' } },
        { status: 401 }
      );
    }

    verifyToken(token);

    const result = await pool.query(
      `SELECT sf.*,
              m.name as mentor_name,
              st.name as student_name
       FROM session_feedback sf
       JOIN mentors m ON sf.mentor_id = m.id
       JOIN students st ON sf.student_id = st.id
       WHERE sf.session_id = $1`,
      [session_id]
    );

    if (result.rows.length === 0) {
      return NextResponse.json(
        { error: { message: 'Feedback not found', code: 'FEEDBACK_NOT_FOUND' } },
        { status: 404 }
      );
    }

    return NextResponse.json({ feedback: result.rows[0] });
  } catch (error: any) {
    console.error('Get feedback error:', error);
    return NextResponse.json(
      {
        error: {
          message: 'Internal server error while fetching feedback',
          code: 'INTERNAL_ERROR',
          meta: { error: error.message }
        }
      },
      { status: 500 }
    );
  }
}
