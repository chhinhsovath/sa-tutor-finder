import { NextRequest, NextResponse } from 'next/server';
import prisma from '@/lib/prisma';
import { extractToken, verifyToken } from '@/lib/auth';

export const dynamic = 'force-dynamic';

// GET /api/students/me/progress - Get student progress report
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
    if (!decoded || decoded.user_type !== 'student') {
      return NextResponse.json(
        { error: { message: 'Only students can access this endpoint', code: 'FORBIDDEN', meta: {} } },
        { status: 403 }
      );
    }

    const studentId = decoded.user_id;
    if (!studentId) {
      return NextResponse.json(
        { error: { message: 'Invalid token', code: 'UNAUTHORIZED', meta: {} } },
        { status: 401 }
      );
    }

    // Get student profile
    const student = await prisma.students.findUnique({
      where: { id: studentId },
      select: {
        id: true,
        name: true,
        email: true,
        english_level: true,
        total_sessions: true,
        created_at: true
      }
    });

    if (!student) {
      return NextResponse.json(
        { error: { message: 'Student not found', code: 'STUDENT_NOT_FOUND', meta: {} } },
        { status: 404 }
      );
    }

    // Get all sessions
    const sessions = await prisma.sessions.findMany({
      where: { student_id: studentId },
      include: {
        mentor: {
          select: { id: true, name: true, english_level: true }
        }
      },
      orderBy: { session_date: 'desc' }
    });

    // Get all reviews submitted by student
    const reviews = await prisma.reviews.findMany({
      where: { student_id: studentId },
      include: {
        mentor: {
          select: { name: true }
        }
      },
      orderBy: { created_at: 'desc' }
    });

    // Calculate statistics
    const completedSessions = sessions.filter(s => s.status === 'completed');
    const upcomingSessions = sessions.filter(s => ['pending', 'confirmed'].includes(s.status));
    const cancelledSessions = sessions.filter(s => s.status === 'cancelled');

    // Get unique mentors worked with
    const uniqueMentors = new Set(completedSessions.map(s => s.mentor_id));

    // Calculate average rating given
    const avgRatingGiven = reviews.length > 0
      ? reviews.reduce((sum, r) => sum + r.rating, 0) / reviews.length
      : null;

    // Get sessions with feedback
    const sessionsWithFeedback = completedSessions.filter(s => s.mentor_feedback);

    // Recent activity (last 5 sessions)
    const recentSessions = sessions.slice(0, 5);

    // Learning progress insights
    const progressInsights = [];
    
    if (completedSessions.length > 0) {
      progressInsights.push(`Completed ${completedSessions.length} sessions`);
    }
    
    if (uniqueMentors.size > 0) {
      progressInsights.push(`Worked with ${uniqueMentors.size} different mentors`);
    }
    
    if (reviews.length > 0) {
      progressInsights.push(`Provided ${reviews.length} reviews`);
    }
    
    if (sessionsWithFeedback.length > 0) {
      progressInsights.push(`Received feedback from ${sessionsWithFeedback.length} sessions`);
    }

    return NextResponse.json({
      progress: {
        student: {
          name: student.name,
          current_level: student.english_level,
          member_since: student.created_at
        },
        statistics: {
          total_sessions: sessions.length,
          completed_sessions: completedSessions.length,
          upcoming_sessions: upcomingSessions.length,
          cancelled_sessions: cancelledSessions.length,
          unique_mentors: uniqueMentors.size,
          reviews_submitted: reviews.length,
          average_rating_given: avgRatingGiven,
          sessions_with_feedback: sessionsWithFeedback.length
        },
        insights: progressInsights,
        recent_activity: recentSessions.map(s => ({
          session_id: s.id,
          mentor_name: s.mentor.name,
          date: s.session_date,
          status: s.status,
          has_feedback: !!s.mentor_feedback,
          has_review: reviews.some(r => r.session_id === s.id)
        })),
        feedback_summary: sessionsWithFeedback.slice(0, 5).map(s => ({
          session_id: s.id,
          mentor_name: s.mentor.name,
          date: s.session_date,
          feedback: s.mentor_feedback
        }))
      }
    });
  } catch (error: any) {
    console.error('Get student progress error:', error);
    return NextResponse.json(
      { error: { message: 'Internal server error', code: 'INTERNAL_ERROR', meta: { error: error.message } } },
      { status: 500 }
    );
  }
}
