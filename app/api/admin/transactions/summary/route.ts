import { NextRequest, NextResponse } from 'next/server';
import prisma from '@/lib/prisma';
import { extractToken, verifyToken } from '@/lib/auth';

export const dynamic = 'force-dynamic';

// GET /api/admin/transactions/summary - Transaction summary and revenue totals
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
    const startDate = searchParams.get('start_date');
    const endDate = searchParams.get('end_date');

    const whereConditions: any = {};

    if (startDate || endDate) {
      whereConditions.created_at = {};
      if (startDate) {
        whereConditions.created_at.gte = new Date(startDate);
      }
      if (endDate) {
        whereConditions.created_at.lte = new Date(endDate);
      }
    }

    // Get all transactions with session/mentor info
    const allTransactions = await prisma.transactions.findMany({
      where: whereConditions,
      include: {
        session: {
          select: {
            mentor_id: true
          }
        }
      }
    });

    // Calculate totals by status
    const completed = allTransactions.filter(t => t.status === 'completed');
    const pending = allTransactions.filter(t => t.status === 'pending');
    const failed = allTransactions.filter(t => t.status === 'failed');
    const refunded = allTransactions.filter(t => t.status === 'refunded');

    const totalRevenue = completed.reduce((sum, t) => sum + parseFloat(t.amount.toString()), 0);
    const pendingRevenue = pending.reduce((sum, t) => sum + parseFloat(t.amount.toString()), 0);
    const refundedAmount = refunded.reduce((sum, t) => sum + parseFloat(t.amount.toString()), 0);

    // Get unique students and mentors count
    const uniqueStudents = new Set(completed.map(t => t.student_id));
    const uniqueMentors = new Set(
      completed
        .filter(t => t.session?.mentor_id)
        .map(t => t.session!.mentor_id)
    );

    // Calculate average transaction amount
    const avgTransactionAmount = completed.length > 0
      ? totalRevenue / completed.length
      : 0;

    // Get top mentors by revenue
    const mentorRevenue = completed.reduce((acc: any, t) => {
      if (!t.session?.mentor_id) return acc;
      const mentorId = t.session.mentor_id;
      if (!acc[mentorId]) {
        acc[mentorId] = { mentor_id: mentorId, total: 0, count: 0 };
      }
      acc[mentorId].total += parseFloat(t.amount.toString());
      acc[mentorId].count += 1;
      return acc;
    }, {});

    const topMentors = Object.values(mentorRevenue)
      .sort((a: any, b: any) => b.total - a.total)
      .slice(0, 10);

    // Enrich top mentors with names
    const mentorIds = topMentors.map((m: any) => m.mentor_id);
    const mentors = await prisma.mentors.findMany({
      where: { id: { in: mentorIds } },
      select: { id: true, name: true }
    });

    const topMentorsWithNames = topMentors.map((m: any) => {
      const mentor = mentors.find(mentor => mentor.id === m.mentor_id);
      return {
        mentor_id: m.mentor_id,
        mentor_name: mentor?.name || 'Unknown',
        total_revenue: m.total,
        transaction_count: m.count
      };
    });

    // Group transactions by date for trend analysis
    const transactionsByDate: any = {};
    completed.forEach(t => {
      const date = t.created_at.toISOString().split('T')[0];
      if (!transactionsByDate[date]) {
        transactionsByDate[date] = { date, count: 0, revenue: 0 };
      }
      transactionsByDate[date].count += 1;
      transactionsByDate[date].revenue += parseFloat(t.amount.toString());
    });

    const dailyTrend = Object.values(transactionsByDate).sort((a: any, b: any) =>
      a.date.localeCompare(b.date)
    );

    return NextResponse.json({
      summary: {
        total_transactions: allTransactions.length,
        completed_transactions: completed.length,
        pending_transactions: pending.length,
        failed_transactions: failed.length,
        refunded_transactions: refunded.length,
        total_revenue: totalRevenue,
        pending_revenue: pendingRevenue,
        refunded_amount: refundedAmount,
        net_revenue: totalRevenue - refundedAmount,
        average_transaction_amount: avgTransactionAmount,
        unique_students: uniqueStudents.size,
        unique_mentors: uniqueMentors.size
      },
      top_mentors: topMentorsWithNames,
      daily_trend: dailyTrend,
      period: {
        start_date: startDate || 'all_time',
        end_date: endDate || 'now'
      }
    });
  } catch (error: any) {
    console.error('Get transaction summary error:', error);
    return NextResponse.json(
      { error: { message: 'Internal server error', code: 'INTERNAL_ERROR', meta: { error: error.message } } },
      { status: 500 }
    );
  }
}
