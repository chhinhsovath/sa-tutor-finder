import { NextRequest, NextResponse } from 'next/server';
import pool from '@/lib/db';
import { verifyToken } from '@/lib/auth';

export const dynamic = 'force-dynamic';

// GET /api/notifications - Get notifications for current user
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
    const unreadOnly = searchParams.get('unread_only') === 'true';

    const userType = decoded.mentor_id ? 'mentor' : decoded.student_id ? 'student' : 'counselor';
    const userId = decoded.mentor_id || decoded.student_id || decoded.counselor_id;

    let query = `
      SELECT * FROM notifications
      WHERE user_id = $1 AND user_type = $2
    `;
    const params = [userId, userType];

    if (unreadOnly) {
      query += ' AND is_read = FALSE';
    }

    query += ' ORDER BY created_at DESC LIMIT 100';

    const result = await pool.query(query, params);

    return NextResponse.json({
      notifications: result.rows,
      count: result.rows.length
    });
  } catch (error: any) {
    console.error('Get notifications error:', error);
    return NextResponse.json(
      {
        error: {
          message: 'Internal server error while fetching notifications',
          code: 'INTERNAL_ERROR',
          meta: { error: error.message }
        }
      },
      { status: 500 }
    );
  }
}

// PATCH /api/notifications - Mark notifications as read
export async function PATCH(request: NextRequest) {
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
    const { notification_ids, mark_all } = body;

    const userType = decoded.mentor_id ? 'mentor' : decoded.student_id ? 'student' : 'counselor';
    const userId = decoded.mentor_id || decoded.student_id || decoded.counselor_id;

    if (mark_all) {
      await pool.query(
        'UPDATE notifications SET is_read = TRUE WHERE user_id = $1 AND user_type = $2',
        [userId, userType]
      );
      return NextResponse.json({ message: 'All notifications marked as read' });
    }

    if (!notification_ids || !Array.isArray(notification_ids)) {
      return NextResponse.json(
        {
          error: {
            message: 'notification_ids must be an array or use mark_all: true',
            code: 'VALIDATION_ERROR'
          }
        },
        { status: 400 }
      );
    }

    await pool.query(
      'UPDATE notifications SET is_read = TRUE WHERE id = ANY($1) AND user_id = $2 AND user_type = $3',
      [notification_ids, userId, userType]
    );

    return NextResponse.json({ message: 'Notifications marked as read' });
  } catch (error: any) {
    console.error('Update notifications error:', error);
    return NextResponse.json(
      {
        error: {
          message: 'Internal server error while updating notifications',
          code: 'INTERNAL_ERROR',
          meta: { error: error.message }
        }
      },
      { status: 500 }
    );
  }
}
