import { NextRequest, NextResponse } from 'next/server';
import pool from '@/lib/db';
import { verifyToken } from '@/lib/auth';

export const dynamic = 'force-dynamic';

// GET /api/sessions/[id] - Get session details
export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params;
    const token = request.headers.get('authorization')?.replace('Bearer ', '');
    if (!token) {
      return NextResponse.json(
        { error: { message: 'Authorization token required', code: 'UNAUTHORIZED' } },
        { status: 401 }
      );
    }

    verifyToken(token);

    const result = await pool.query(
      `SELECT s.*,
              m.name as mentor_name, m.email as mentor_email, m.contact as mentor_contact,
              st.name as student_name, st.email as student_email
       FROM sessions s
       JOIN mentors m ON s.mentor_id = m.id
       JOIN students st ON s.student_id = st.id
       WHERE s.id = $1`,
      [id]
    );

    if (result.rows.length === 0) {
      return NextResponse.json(
        { error: { message: 'Session not found', code: 'SESSION_NOT_FOUND' } },
        { status: 404 }
      );
    }

    return NextResponse.json({ session: result.rows[0] });
  } catch (error: any) {
    console.error('Get session error:', error);
    return NextResponse.json(
      {
        error: {
          message: 'Internal server error while fetching session',
          code: 'INTERNAL_ERROR',
          meta: { error: error.message }
        }
      },
      { status: 500 }
    );
  }
}

// PATCH /api/sessions/[id] - Update session (change status, reschedule)
export async function PATCH(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params;
    const token = request.headers.get('authorization')?.replace('Bearer ', '');
    if (!token) {
      return NextResponse.json(
        { error: { message: 'Authorization token required', code: 'UNAUTHORIZED' } },
        { status: 401 }
      );
    }

    const decoded = verifyToken(token);
    const body = await request.json();
    const { status, session_date, start_time, end_time, notes } = body;

    // Verify session belongs to user
    const sessionCheck = await pool.query(
      'SELECT * FROM sessions WHERE id = $1 AND (student_id = $2 OR mentor_id = $3)',
      [id, decoded.student_id || null, decoded.mentor_id || null]
    );

    if (sessionCheck.rows.length === 0) {
      return NextResponse.json(
        { error: { message: 'Session not found or unauthorized', code: 'FORBIDDEN' } },
        { status: 403 }
      );
    }

    const updates: string[] = [];
    const values: any[] = [];
    let paramCount = 1;

    if (status) {
      updates.push(`status = $${paramCount++}`);
      values.push(status);
    }
    if (session_date) {
      updates.push(`session_date = $${paramCount++}`);
      values.push(session_date);
    }
    if (start_time) {
      updates.push(`start_time = $${paramCount++}`);
      values.push(start_time);
    }
    if (end_time) {
      updates.push(`end_time = $${paramCount++}`);
      values.push(end_time);
    }
    if (notes !== undefined) {
      updates.push(`notes = $${paramCount++}`);
      values.push(notes);
    }

    if (updates.length === 0) {
      return NextResponse.json(
        { error: { message: 'No fields to update', code: 'VALIDATION_ERROR' } },
        { status: 400 }
      );
    }

    values.push(id);
    const result = await pool.query(
      `UPDATE sessions SET ${updates.join(', ')} WHERE id = $${paramCount} RETURNING *`,
      values
    );

    return NextResponse.json({
      session: result.rows[0],
      message: 'Session updated successfully'
    });
  } catch (error: any) {
    console.error('Update session error:', error);
    return NextResponse.json(
      {
        error: {
          message: 'Internal server error while updating session',
          code: 'INTERNAL_ERROR',
          meta: { error: error.message }
        }
      },
      { status: 500 }
    );
  }
}

// DELETE /api/sessions/[id] - Cancel session
export async function DELETE(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params;
    const token = request.headers.get('authorization')?.replace('Bearer ', '');
    if (!token) {
      return NextResponse.json(
        { error: { message: 'Authorization token required', code: 'UNAUTHORIZED' } },
        { status: 401 }
      );
    }

    const decoded = verifyToken(token);

    // Verify session belongs to user
    const sessionCheck = await pool.query(
      'SELECT * FROM sessions WHERE id = $1 AND (student_id = $2 OR mentor_id = $3)',
      [id, decoded.student_id || null, decoded.mentor_id || null]
    );

    if (sessionCheck.rows.length === 0) {
      return NextResponse.json(
        { error: { message: 'Session not found or unauthorized', code: 'FORBIDDEN' } },
        { status: 403 }
      );
    }

    await pool.query(
      "UPDATE sessions SET status = 'cancelled' WHERE id = $1",
      [id]
    );

    return NextResponse.json({ message: 'Session cancelled successfully' });
  } catch (error: any) {
    console.error('Delete session error:', error);
    return NextResponse.json(
      {
        error: {
          message: 'Internal server error while cancelling session',
          code: 'INTERNAL_ERROR',
          meta: { error: error.message }
        }
      },
      { status: 500 }
    );
  }
}
