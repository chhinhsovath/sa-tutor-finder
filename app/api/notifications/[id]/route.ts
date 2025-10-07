import { NextRequest, NextResponse } from 'next/server';
import prisma from '@/lib/prisma';
import { extractToken, verifyToken } from '@/lib/auth';

export const dynamic = 'force-dynamic';

// PATCH /api/notifications/[id] - Mark notification as read
export async function PATCH(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
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

    const notification = await prisma.notifications.findUnique({
      where: { id: params.id }
    });

    if (!notification) {
      return NextResponse.json(
        { error: { message: 'Notification not found', code: 'NOTIFICATION_NOT_FOUND', meta: {} } },
        { status: 404 }
      );
    }

    if (notification.user_id !== userId) {
      return NextResponse.json(
        { error: { message: 'Unauthorized', code: 'FORBIDDEN', meta: {} } },
        { status: 403 }
      );
    }

    const updated = await prisma.notifications.update({
      where: { id: params.id },
      data: { is_read: true }
    });

    return NextResponse.json({ notification: updated });
  } catch (error: any) {
    console.error('Mark notification read error:', error);
    return NextResponse.json(
      { error: { message: 'Internal server error', code: 'INTERNAL_ERROR', meta: { error: error.message } } },
      { status: 500 }
    );
  }
}
