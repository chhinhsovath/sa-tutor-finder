import { NextRequest, NextResponse } from 'next/server';
import prisma from '@/lib/prisma';
import { extractToken, verifyToken } from '@/lib/auth';

export const dynamic = 'force-dynamic';

// GET /api/counselors/dashboard - Get counselor dashboard data
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
    if (!decoded || decoded.user_type !== 'counselor') {
      return NextResponse.json(
        { error: { message: 'Only counselors can access this endpoint', code: 'FORBIDDEN', meta: {} } },
        { status: 403 }
      );
    }

    const counselorId = decoded.user_id;
    if (!counselorId) {
      return NextResponse.json(
        { error: { message: 'Invalid token', code: 'UNAUTHORIZED', meta: {} } },
        { status: 401 }
      );
    }

    // Get counselor profile
    const counselor = await prisma.counselors.findUnique({
      where: { id: counselorId },
      select: {
        id: true,
        name: true,
        email: true,
        specialization: true,
        status: true
      }
    });

    if (!counselor) {
      return NextResponse.json(
        { error: { message: 'Counselor not found', code: 'COUNSELOR_NOT_FOUND', meta: {} } },
        { status: 404 }
      );
    }

    // Get platform statistics
    const [
      totalStudents,
      totalMentors,
      totalSessions,
      activeSessions,
      completedSessions,
      pendingTickets,
      totalReviews
    ] = await Promise.all([
      prisma.students.count(),
      prisma.mentors.count({ where: { status: 'active' } }),
      prisma.sessions.count(),
      prisma.sessions.count({
        where: { status: { in: ['pending', 'confirmed'] } }
      }),
      prisma.sessions.count({ where: { status: 'completed' } }),
      prisma.support_tickets.count({
        where: { status: { in: ['open', 'in_progress'] } }
      }),
      prisma.reviews.count()
    ]);

    // Get recent sessions (last 10)
    const recentSessions = await prisma.sessions.findMany({
      take: 10,
      orderBy: { created_at: 'desc' },
      include: {
        student: {
          select: { id: true, name: true, email: true }
        },
        mentor: {
          select: { id: true, name: true, email: true }
        }
      }
    });

    // Get recent support tickets (last 10)
    const recentTickets = await prisma.support_tickets.findMany({
      take: 10,
      orderBy: { created_at: 'desc' },
      where: { status: { in: ['open', 'in_progress'] } }
    });

    // Calculate average ratings
    const reviewStats = await prisma.reviews.aggregate({
      _avg: { rating: true },
      _count: { rating: true }
    });

    // Get top mentors by rating
    const topMentors = await prisma.mentors.findMany({
      where: { status: 'active' },
      orderBy: { average_rating: 'desc' },
      take: 5,
      select: {
        id: true,
        name: true,
        email: true,
        english_level: true,
        average_rating: true,
        _count: {
          select: { reviews: true }
        }
      }
    });

    // Get students who need attention (low session count or no sessions)
    const studentsNeedingAttention = await prisma.students.findMany({
      where: {
        OR: [
          { total_sessions: { lte: 2 } },
          { total_sessions: 0 }
        ]
      },
      take: 10,
      orderBy: { created_at: 'desc' },
      select: {
        id: true,
        name: true,
        email: true,
        english_level: true,
        total_sessions: true,
        created_at: true
      }
    });

    return NextResponse.json({
      dashboard: {
        counselor: {
          name: counselor.name,
          specialization: counselor.specialization
        },
        statistics: {
          total_students: totalStudents,
          total_mentors: totalMentors,
          total_sessions: totalSessions,
          active_sessions: activeSessions,
          completed_sessions: completedSessions,
          pending_tickets: pendingTickets,
          total_reviews: totalReviews,
          average_rating: reviewStats._avg.rating ? parseFloat(reviewStats._avg.rating.toFixed(1)) : 0
        },
        recent_sessions: recentSessions.map(s => ({
          id: s.id,
          student_name: s.student.name,
          mentor_name: s.mentor.name,
          session_date: s.session_date,
          status: s.status,
          created_at: s.created_at
        })),
        recent_tickets: recentTickets.map(t => ({
          id: t.id,
          subject: t.subject,
          status: t.status,
          priority: t.priority,
          category: t.category,
          created_at: t.created_at
        })),
        top_mentors: topMentors.map(m => ({
          id: m.id,
          name: m.name,
          email: m.email,
          english_level: m.english_level,
          average_rating: m.average_rating,
          total_reviews: m._count.reviews
        })),
        students_needing_attention: studentsNeedingAttention,
        alerts: []
      }
    });
  } catch (error: any) {
    console.error('Get counselor dashboard error:', error);
    return NextResponse.json(
      { error: { message: 'Internal server error', code: 'INTERNAL_ERROR', meta: { error: error.message } } },
      { status: 500 }
    );
  }
}
