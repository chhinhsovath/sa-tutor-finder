import { NextRequest, NextResponse } from 'next/server';
import prisma from '@/lib/prisma';
import { extractToken, verifyToken } from '@/lib/auth';

export const dynamic = 'force-dynamic';

// GET /api/sessions/[id] - Get session details
export async function GET(
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

    const session = await prisma.sessions.findUnique({
      where: { id: params.id },
      include: {
        student: { select: { id: true, name: true, email: true, phone_number: true } },
        mentor: { select: { id: true, name: true, email: true, contact: true } },
        review: true
      }
    });

    if (!session) {
      return NextResponse.json(
        { error: { message: 'Session not found', code: 'SESSION_NOT_FOUND', meta: {} } },
        { status: 404 }
      );
    }

    // Check authorization
    const userId = decoded.user_id || decoded.mentor_id;
    if (session.student_id !== userId && session.mentor_id !== userId) {
      return NextResponse.json(
        { error: { message: 'You do not have access to this session', code: 'FORBIDDEN', meta: {} } },
        { status: 403 }
      );
    }

    return NextResponse.json({ session });
  } catch (error: any) {
    console.error('Get session error:', error);
    return NextResponse.json(
      { error: { message: 'Internal server error', code: 'INTERNAL_ERROR', meta: { error: error.message } } },
      { status: 500 }
    );
  }
}

// PATCH /api/sessions/[id] - Update session (confirm, cancel, complete, add feedback)
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
    const userType = decoded.user_type || 'mentor';

    const session = await prisma.sessions.findUnique({
      where: { id: params.id }
    });

    if (!session) {
      return NextResponse.json(
        { error: { message: 'Session not found', code: 'SESSION_NOT_FOUND', meta: {} } },
        { status: 404 }
      );
    }

    // Check authorization
    if (session.student_id !== userId && session.mentor_id !== userId) {
      return NextResponse.json(
        { error: { message: 'You do not have access to this session', code: 'FORBIDDEN', meta: {} } },
        { status: 403 }
      );
    }

    const body = await request.json();
    const { status, mentor_feedback, student_feedback, cancellation_reason } = body;

    const updateData: any = {};

    // Status updates
    if (status) {
      // Mentor can confirm pending sessions
      if (status === 'confirmed' && userType === 'mentor' && session.status === 'pending') {
        updateData.status = 'confirmed';
      }
      // Mentor can mark as completed
      else if (status === 'completed' && userType === 'mentor') {
        updateData.status = 'completed';
        // Increment mentor's total sessions
        await prisma.mentors.update({
          where: { id: session.mentor_id },
          data: { total_sessions: { increment: 1 } }
        });
        await prisma.students.update({
          where: { id: session.student_id },
          data: { total_sessions: { increment: 1 } }
        });
      }
      // Anyone can cancel
      else if (status === 'cancelled') {
        updateData.status = 'cancelled';
        if (cancellation_reason) {
          updateData.cancellation_reason = cancellation_reason;
        }
      }
      // Mentor can mark no-show
      else if (status === 'no_show' && userType === 'mentor') {
        updateData.status = 'no_show';
      }
      else {
        return NextResponse.json(
          { error: { message: 'Invalid status transition', code: 'VALIDATION_ERROR', meta: {} } },
          { status: 400 }
        );
      }
    }

    // Feedback
    if (mentor_feedback && userType === 'mentor') {
      updateData.mentor_feedback = mentor_feedback;
    }
    if (student_feedback && userType === 'student') {
      updateData.student_feedback = student_feedback;
    }

    if (Object.keys(updateData).length === 0) {
      return NextResponse.json(
        { error: { message: 'No fields to update', code: 'VALIDATION_ERROR', meta: {} } },
        { status: 400 }
      );
    }

    const updated = await prisma.sessions.update({
      where: { id: params.id },
      data: updateData,
      include: {
        student: { select: { id: true, name: true, email: true } },
        mentor: { select: { id: true, name: true, email: true } }
      }
    });

    return NextResponse.json({ session: updated });
  } catch (error: any) {
    console.error('Update session error:', error);
    return NextResponse.json(
      { error: { message: 'Internal server error', code: 'INTERNAL_ERROR', meta: { error: error.message } } },
      { status: 500 }
    );
  }
}
