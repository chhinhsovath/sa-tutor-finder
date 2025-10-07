import { NextRequest, NextResponse } from 'next/server';
import prisma from '@/lib/prisma';
import { extractToken, verifyToken } from '@/lib/auth';

export const dynamic = 'force-dynamic';

// GET /api/notifications/preferences - Get user's notification preferences
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
        { error: { message: 'Invalid token', code: 'UNAUTHORIZED', meta: {} } },
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

    // Find or create notification preferences
    let preferences = await prisma.notification_preferences.findUnique({
      where: {
        user_id_user_type: {
          user_id: userId,
          user_type: userType as any
        }
      }
    });

    // Create default preferences if not exists
    if (!preferences) {
      preferences = await prisma.notification_preferences.create({
        data: {
          user_id: userId,
          user_type: userType as any,
          email_notifications: true,
          push_notifications: true,
          session_reminders: true,
          message_notifications: true,
          review_notifications: true,
          marketing_emails: false
        }
      });
    }

    return NextResponse.json({ preferences });
  } catch (error: any) {
    console.error('Get notification preferences error:', error);
    return NextResponse.json(
      { error: { message: 'Internal server error', code: 'INTERNAL_ERROR', meta: { error: error.message } } },
      { status: 500 }
    );
  }
}

// PATCH /api/notifications/preferences - Update notification preferences
export async function PATCH(request: NextRequest) {
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
        { error: { message: 'Invalid token', code: 'UNAUTHORIZED', meta: {} } },
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
    const {
      email_notifications,
      push_notifications,
      session_reminders,
      message_notifications,
      review_notifications,
      marketing_emails
    } = body;

    const updateData: any = {};
    if (email_notifications !== undefined) updateData.email_notifications = email_notifications;
    if (push_notifications !== undefined) updateData.push_notifications = push_notifications;
    if (session_reminders !== undefined) updateData.session_reminders = session_reminders;
    if (message_notifications !== undefined) updateData.message_notifications = message_notifications;
    if (review_notifications !== undefined) updateData.review_notifications = review_notifications;
    if (marketing_emails !== undefined) updateData.marketing_emails = marketing_emails;

    if (Object.keys(updateData).length === 0) {
      return NextResponse.json(
        { error: { message: 'No fields to update', code: 'VALIDATION_ERROR', meta: {} } },
        { status: 400 }
      );
    }

    // Upsert preferences (create if not exists, update if exists)
    const preferences = await prisma.notification_preferences.upsert({
      where: {
        user_id_user_type: {
          user_id: userId,
          user_type: userType as any
        }
      },
      update: updateData,
      create: {
        user_id: userId,
        user_type: userType as any,
        ...updateData
      }
    });

    return NextResponse.json({ preferences });
  } catch (error: any) {
    console.error('Update notification preferences error:', error);
    return NextResponse.json(
      { error: { message: 'Internal server error', code: 'INTERNAL_ERROR', meta: { error: error.message } } },
      { status: 500 }
    );
  }
}
