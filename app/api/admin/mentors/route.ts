import { NextRequest, NextResponse } from 'next/server';
import prisma from '@/lib/prisma';
import { extractToken, verifyToken } from '@/lib/auth';

export const dynamic = 'force-dynamic';

// GET /api/admin/mentors - List all mentors (admin only)
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

    const { searchParams } = new URL(request.url);
    const status = searchParams.get('status');

    const whereConditions: any = {};
    if (status) whereConditions.status = status;

    const mentors = await prisma.mentors.findMany({
      where: whereConditions,
      select: {
        id: true,
        name: true,
        email: true,
        english_level: true,
        status: true,
        total_sessions: true,
        average_rating: true,
        created_at: true
      },
      orderBy: { created_at: 'desc' }
    });

    return NextResponse.json({ mentors, count: mentors.length });
  } catch (error: any) {
    console.error('Admin get mentors error:', error);
    return NextResponse.json(
      { error: { message: 'Internal server error', code: 'INTERNAL_ERROR', meta: { error: error.message } } },
      { status: 500 }
    );
  }
}
