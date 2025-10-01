import { NextRequest, NextResponse } from 'next/server';
import pool from '@/lib/db';
import { verifyToken } from '@/lib/auth';

export const dynamic = 'force-dynamic';

// GET /api/messages - Get messages for a conversation
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
    const otherUserId = searchParams.get('other_user_id');
    const otherUserType = searchParams.get('other_user_type'); // 'student', 'mentor', 'counselor'

    if (!otherUserId || !otherUserType) {
      return NextResponse.json(
        {
          error: {
            message: 'Missing required parameters: other_user_id, other_user_type',
            code: 'VALIDATION_ERROR'
          }
        },
        { status: 400 }
      );
    }

    // Determine current user type
    const currentUserType = decoded.mentor_id ? 'mentor' : decoded.student_id ? 'student' : 'counselor';
    const currentUserId = decoded.mentor_id || decoded.student_id || decoded.counselor_id;

    const result = await pool.query(
      `SELECT * FROM messages
       WHERE (
         (sender_id = $1 AND sender_type = $2 AND receiver_id = $3 AND receiver_type = $4) OR
         (sender_id = $3 AND sender_type = $4 AND receiver_id = $1 AND receiver_type = $2)
       )
       ORDER BY created_at ASC`,
      [currentUserId, currentUserType, otherUserId, otherUserType]
    );

    // Mark messages as read
    await pool.query(
      `UPDATE messages
       SET is_read = TRUE
       WHERE receiver_id = $1 AND receiver_type = $2 AND sender_id = $3 AND sender_type = $4 AND is_read = FALSE`,
      [currentUserId, currentUserType, otherUserId, otherUserType]
    );

    return NextResponse.json({
      messages: result.rows,
      count: result.rows.length
    });
  } catch (error: any) {
    console.error('Get messages error:', error);
    return NextResponse.json(
      {
        error: {
          message: 'Internal server error while fetching messages',
          code: 'INTERNAL_ERROR',
          meta: { error: error.message }
        }
      },
      { status: 500 }
    );
  }
}

// POST /api/messages - Send a message
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
    const { receiver_id, receiver_type, message } = body;

    if (!receiver_id || !receiver_type || !message) {
      return NextResponse.json(
        {
          error: {
            message: 'Missing required fields: receiver_id, receiver_type, message',
            code: 'VALIDATION_ERROR'
          }
        },
        { status: 400 }
      );
    }

    // Determine current user type
    const senderType = decoded.mentor_id ? 'mentor' : decoded.student_id ? 'student' : 'counselor';
    const senderId = decoded.mentor_id || decoded.student_id || decoded.counselor_id;

    const result = await pool.query(
      `INSERT INTO messages (sender_id, sender_type, receiver_id, receiver_type, message, is_read)
       VALUES ($1, $2, $3, $4, $5, FALSE)
       RETURNING *`,
      [senderId, senderType, receiver_id, receiver_type, message]
    );

    return NextResponse.json({
      message: result.rows[0],
      success: true
    }, { status: 201 });
  } catch (error: any) {
    console.error('Send message error:', error);
    return NextResponse.json(
      {
        error: {
          message: 'Internal server error while sending message',
          code: 'INTERNAL_ERROR',
          meta: { error: error.message }
        }
      },
      { status: 500 }
    );
  }
}
