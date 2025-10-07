import { NextRequest, NextResponse } from 'next/server';
import prisma from '@/lib/prisma';
import { extractToken, verifyToken } from '@/lib/auth';

export const dynamic = 'force-dynamic';

// GET /api/sessions - List user's sessions
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
    const status = searchParams.get('status');

    // Build filter based on user type
    const whereConditions: any = {};
    if (userType === 'student') {
      whereConditions.student_id = userId;
    } else if (userType === 'mentor') {
      whereConditions.mentor_id = userId;
    }

    if (status) {
      whereConditions.status = status;
    }

    const sessions = await prisma.sessions.findMany({
      where: whereConditions,
      include: {
        student: {
          select: { id: true, name: true, email: true, english_level: true }
        },
        mentor: {
          select: { id: true, name: true, email: true, english_level: true, contact: true }
        }
      },
      orderBy: [
        { session_date: 'desc' },
        { start_time: 'desc' }
      ]
    });

    return NextResponse.json({ sessions, count: sessions.length });
  } catch (error: any) {
    console.error('Get sessions error:', error);
    return NextResponse.json(
      { error: { message: 'Internal server error', code: 'INTERNAL_ERROR', meta: { error: error.message } } },
      { status: 500 }
    );
  }
}

// POST /api/sessions - Book a new session
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
    const userType = decoded.user_type || 'student';

    if (!userId) {
      return NextResponse.json(
        { error: { message: 'Invalid token', code: 'UNAUTHORIZED', meta: {} } },
        { status: 401 }
      );
    }

    if (userType !== 'student') {
      return NextResponse.json(
        { error: { message: 'Only students can book sessions', code: 'FORBIDDEN', meta: {} } },
        { status: 403 }
      );
    }

    const body = await request.json();
    const { mentor_id, session_date, start_time, end_time, duration_minutes, notes } = body;

    // Validation
    if (!mentor_id || !session_date || !start_time || !end_time || !duration_minutes) {
      return NextResponse.json(
        {
          error: {
            message: 'Missing required fields',
            code: 'VALIDATION_ERROR',
            meta: { required: ['mentor_id', 'session_date', 'start_time', 'end_time', 'duration_minutes'] }
          }
        },
        { status: 400 }
      );
    }

    // Check mentor exists and is active
    const mentor = await prisma.mentors.findUnique({ where: { id: mentor_id } });
    if (!mentor) {
      return NextResponse.json(
        { error: { message: 'Mentor not found', code: 'MENTOR_NOT_FOUND', meta: {} } },
        { status: 404 }
      );
    }

    if (mentor.status !== 'active') {
      return NextResponse.json(
        { error: { message: 'Mentor is not active', code: 'MENTOR_INACTIVE', meta: {} } },
        { status: 403 }
      );
    }

    // Parse dates
    const sessionDate = new Date(session_date);
    const startTimeDate = new Date(`1970-01-01T${start_time}:00`);
    const endTimeDate = new Date(`1970-01-01T${end_time}:00`);

    // Check for conflicting sessions
    const conflictingSessions = await prisma.sessions.findMany({
      where: {
        mentor_id,
        session_date: sessionDate,
        status: { in: ['pending', 'confirmed'] },
        OR: [
          {
            AND: [
              { start_time: { lte: endTimeDate } },
              { end_time: { gt: startTimeDate } }
            ]
          }
        ]
      }
    });

    if (conflictingSessions.length > 0) {
      return NextResponse.json(
        {
          error: {
            message: 'Mentor has conflicting session at this time',
            code: 'SESSION_CONFLICT',
            meta: { conflicts: conflictingSessions.length }
          }
        },
        { status: 409 }
      );
    }

    // Create session
    const newSession = await prisma.sessions.create({
      data: {
        student_id: userId,
        mentor_id,
        session_date: sessionDate,
        start_time: startTimeDate,
        end_time: endTimeDate,
        duration_minutes,
        notes: notes || null,
        status: 'pending'
      },
      include: {
        student: { select: { id: true, name: true, email: true } },
        mentor: { select: { id: true, name: true, email: true, contact: true } }
      }
    });

    // TODO: Create notification for mentor

    return NextResponse.json({ session: newSession }, { status: 201 });
  } catch (error: any) {
    console.error('Create session error:', error);
    return NextResponse.json(
      { error: { message: 'Internal server error', code: 'INTERNAL_ERROR', meta: { error: error.message } } },
      { status: 500 }
    );
  }
}
