import { NextRequest, NextResponse } from 'next/server';
import prisma from '@/lib/prisma';
import { extractToken, verifyToken } from '@/lib/auth';

export const dynamic = 'force-dynamic';

// GET /api/admin/transactions - List all transactions with filters
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
    const studentId = searchParams.get('student_id');
    const mentorId = searchParams.get('mentor_id');
    const startDate = searchParams.get('start_date');
    const endDate = searchParams.get('end_date');
    const limit = parseInt(searchParams.get('limit') || '50');
    const offset = parseInt(searchParams.get('offset') || '0');

    const whereConditions: any = {};

    if (status) {
      whereConditions.status = status;
    }

    if (studentId) {
      whereConditions.student_id = studentId;
    }

    if (mentorId) {
      whereConditions.session = {
        mentor_id: mentorId
      };
    }

    if (startDate || endDate) {
      whereConditions.created_at = {};
      if (startDate) {
        whereConditions.created_at.gte = new Date(startDate);
      }
      if (endDate) {
        whereConditions.created_at.lte = new Date(endDate);
      }
    }

    const [transactions, totalCount] = await Promise.all([
      prisma.transactions.findMany({
        where: whereConditions,
        include: {
          student: {
            select: { id: true, name: true, email: true }
          },
          session: {
            select: {
              id: true,
              session_date: true,
              duration_minutes: true,
              mentor: {
                select: { id: true, name: true, email: true }
              }
            }
          }
        },
        orderBy: { created_at: 'desc' },
        take: limit,
        skip: offset
      }),
      prisma.transactions.count({ where: whereConditions })
    ]);

    return NextResponse.json({
      transactions,
      pagination: {
        total: totalCount,
        limit,
        offset,
        hasMore: offset + transactions.length < totalCount
      }
    });
  } catch (error: any) {
    console.error('Get transactions error:', error);
    return NextResponse.json(
      { error: { message: 'Internal server error', code: 'INTERNAL_ERROR', meta: { error: error.message } } },
      { status: 500 }
    );
  }
}
