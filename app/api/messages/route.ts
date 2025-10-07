import { NextRequest, NextResponse } from 'next/server';
import prisma from '@/lib/prisma';
import { extractToken, verifyToken } from '@/lib/auth';

export const dynamic = 'force-dynamic';

// GET /api/messages - List messages (conversation with specific user)
export async function GET(request: NextRequest) {
  try {
    const token = extractToken(request.headers.get('authorization'));
    if (!token) {
      return NextResponse.json(
        { error: { message: 'No authorization token provided', code: 'UNAUTHORIZED', meta: {} } },
        { status: 401 }
      );
    }

    const decoded = verifyToken(token);
    if (!decoded) {
      return NextResponse.json(
        { error: { message: 'Invalid or expired token', code: 'UNAUTHORIZED', meta: {} } },
        { status: 401 }
      );
    }

    const userId = decoded.user_id || decoded.mentor_id;
    const userType = decoded.user_type || 'mentor';

    const { searchParams } = new URL(request.url);
    const otherUserId = searchParams.get('user_id');

    if (!otherUserId) {
      return NextResponse.json(
        { error: { message: 'user_id query parameter is required', code: 'VALIDATION_ERROR', meta: {} } },
        { status: 400 }
      );
    }

    // Fetch messages between the two users
    const messages = await prisma.messages.findMany({
      where: {
        OR: [
          { sender_id: userId, recipient_id: otherUserId },
          { sender_id: otherUserId, recipient_id: userId }
        ]
      },
      orderBy: { created_at: 'asc' }
    });

    // Mark messages as read
    await prisma.messages.updateMany({
      where: {
        sender_id: otherUserId,
        recipient_id: userId,
        is_read: false
      },
      data: { is_read: true }
    });

    return NextResponse.json({ messages, count: messages.length });
  } catch (error: any) {
    console.error('Get messages error:', error);
    return NextResponse.json(
      { error: { message: 'Internal server error', code: 'INTERNAL_ERROR', meta: { error: error.message } } },
      { status: 500 }
    );
  }
}

// POST /api/messages - Send a message
export async function POST(request: NextRequest) {
  try {
    const token = extractToken(request.headers.get('authorization'));
    if (!token) {
      return NextResponse.json(
        { error: { message: 'No authorization token provided', code: 'UNAUTHORIZED', meta: {} } },
        { status: 401 }
      );
    }

    const decoded = verifyToken(token);
    if (!decoded) {
      return NextResponse.json(
        { error: { message: 'Invalid or expired token', code: 'UNAUTHORIZED', meta: {} } },
        { status: 401 }
      );
    }

    const userId = decoded.user_id || decoded.mentor_id;
    const userType = decoded.user_type || 'mentor';

    if (!userId) {
      return NextResponse.json(
        { error: { message: 'Invalid token', code: 'UNAUTHORIZED', meta: {} } },
        { status: 401 }
      );
    }

    const body = await request.json();
    const { recipient_id, recipient_type, content } = body;

    if (!recipient_id || !recipient_type || !content) {
      return NextResponse.json(
        {
          error: {
            message: 'Missing required fields',
            code: 'VALIDATION_ERROR',
            meta: { required: ['recipient_id', 'recipient_type', 'content'] }
          }
        },
        { status: 400 }
      );
    }

    if (!['student', 'mentor', 'counselor'].includes(recipient_type)) {
      return NextResponse.json(
        { error: { message: 'Invalid recipient_type', code: 'VALIDATION_ERROR', meta: {} } },
        { status: 400 }
      );
    }

    // Create message
    const message = await prisma.messages.create({
      data: {
        sender_id: userId,
        sender_type: userType as any,
        recipient_id,
        recipient_type: recipient_type as any,
        content
      }
    });

    // TODO: Create notification for recipient

    return NextResponse.json({ message }, { status: 201 });
  } catch (error: any) {
    console.error('Send message error:', error);
    return NextResponse.json(
      { error: { message: 'Internal server error', code: 'INTERNAL_ERROR', meta: { error: error.message } } },
      { status: 500 }
    );
  }
}
