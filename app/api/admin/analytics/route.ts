import { NextRequest, NextResponse } from 'next/server';
import prisma from '@/lib/prisma';
import { extractToken, verifyToken } from '@/lib/auth';

export const dynamic = 'force-dynamic';

// GET /api/admin/analytics - Platform analytics (admin only)
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
    if (!decoded || decoded.user_type !== 'admin') {
      return NextResponse.json(
        { error: { message: 'Admin access required', code: 'FORBIDDEN', meta: {} } },
        { status: 403 }
      );
    }

    const [
      totalMentors,
      activeMentors,
      totalStudents,
      activeStudents,
      totalSessions,
      completedSessions,
      pendingSessions,
      totalReviews,
      avgRating
    ] = await Promise.all([
      prisma.mentors.count(),
      prisma.mentors.count({ where: { status: 'active' } }),
      prisma.students.count(),
      prisma.students.count({ where: { status: 'active' } }),
      prisma.sessions.count(),
      prisma.sessions.count({ where: { status: 'completed' } }),
      prisma.sessions.count({ where: { status: 'pending' } }),
      prisma.reviews.count(),
      prisma.reviews.aggregate({ _avg: { rating: true } })
    ]);

    return NextResponse.json({
      analytics: {
        mentors: { total: totalMentors, active: activeMentors },
        students: { total: totalStudents, active: activeStudents },
        sessions: { total: totalSessions, completed: completedSessions, pending: pendingSessions },
        reviews: { total: totalReviews, average_rating: avgRating._avg.rating || 0 }
      }
    });
  } catch (error: any) {
    console.error('Admin analytics error:', error);
    return NextResponse.json(
      { error: { message: 'Internal server error', code: 'INTERNAL_ERROR', meta: { error: error.message } } },
      { status: 500 }
    );
  }
}
