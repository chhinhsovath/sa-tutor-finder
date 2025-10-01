import { NextRequest, NextResponse } from 'next/server';
import pool from '@/lib/db';
import { verifyToken } from '@/lib/auth';

export const dynamic = 'force-dynamic';

// GET /api/notifications/settings - Get notification settings
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

    const userType = 'mentor';
    const userId = decoded.mentor_id;

    const result = await pool.query(
      'SELECT * FROM notification_settings WHERE user_id = $1 AND user_type = $2',
      [userId, userType]
    );

    if (result.rows.length === 0) {
      // Create default settings
      const newSettings = await pool.query(
        `INSERT INTO notification_settings (user_id, user_type)
         VALUES ($1, $2)
         RETURNING *`,
        [userId, userType]
      );
      return NextResponse.json({ settings: newSettings.rows[0] });
    }

    return NextResponse.json({ settings: result.rows[0] });
  } catch (error: any) {
    console.error('Get notification settings error:', error);
    return NextResponse.json(
      {
        error: {
          message: 'Internal server error while fetching notification settings',
          code: 'INTERNAL_ERROR',
          meta: { error: error.message }
        }
      },
      { status: 500 }
    );
  }
}

// PATCH /api/notifications/settings - Update notification settings
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
    if (!decoded) {
      return NextResponse.json(
        { error: { message: 'Invalid or expired token', code: 'UNAUTHORIZED' } },
        { status: 401 }
      );
    }

    const body = await request.json();
    const {
      email_notifications,
      push_notifications,
      sms_notifications,
      session_reminders,
      message_notifications,
      review_notifications
    } = body;

    const userType = 'mentor';
    const userId = decoded.mentor_id;

    const updates: string[] = [];
    const values: any[] = [];
    let paramCount = 1;

    if (email_notifications !== undefined) {
      updates.push(`email_notifications = $${paramCount++}`);
      values.push(email_notifications);
    }
    if (push_notifications !== undefined) {
      updates.push(`push_notifications = $${paramCount++}`);
      values.push(push_notifications);
    }
    if (sms_notifications !== undefined) {
      updates.push(`sms_notifications = $${paramCount++}`);
      values.push(sms_notifications);
    }
    if (session_reminders !== undefined) {
      updates.push(`session_reminders = $${paramCount++}`);
      values.push(session_reminders);
    }
    if (message_notifications !== undefined) {
      updates.push(`message_notifications = $${paramCount++}`);
      values.push(message_notifications);
    }
    if (review_notifications !== undefined) {
      updates.push(`review_notifications = $${paramCount++}`);
      values.push(review_notifications);
    }

    if (updates.length === 0) {
      return NextResponse.json(
        { error: { message: 'No fields to update', code: 'VALIDATION_ERROR' } },
        { status: 400 }
      );
    }

    values.push(userId, userType);

    const result = await pool.query(
      `UPDATE notification_settings
       SET ${updates.join(', ')}
       WHERE user_id = $${paramCount++} AND user_type = $${paramCount}
       RETURNING *`,
      values
    );

    if (result.rows.length === 0) {
      // Create if not exists
      const newSettings = await pool.query(
        `INSERT INTO notification_settings (
          user_id, user_type,
          email_notifications, push_notifications, sms_notifications,
          session_reminders, message_notifications, review_notifications
         )
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
         RETURNING *`,
        [
          userId, userType,
          email_notifications ?? true,
          push_notifications ?? true,
          sms_notifications ?? false,
          session_reminders ?? true,
          message_notifications ?? true,
          review_notifications ?? true
        ]
      );
      return NextResponse.json({
        settings: newSettings.rows[0],
        message: 'Settings created successfully'
      });
    }

    return NextResponse.json({
      settings: result.rows[0],
      message: 'Settings updated successfully'
    });
  } catch (error: any) {
    console.error('Update notification settings error:', error);
    return NextResponse.json(
      {
        error: {
          message: 'Internal server error while updating notification settings',
          code: 'INTERNAL_ERROR',
          meta: { error: error.message }
        }
      },
      { status: 500 }
    );
  }
}
