import { NextRequest, NextResponse } from 'next/server';
import pool from '@/lib/db';
import { verifyToken } from '@/lib/auth';

export const dynamic = 'force-dynamic';

// GET /api/admin/financial - Financial reports (admin only)
export async function GET(request: NextRequest) {
  try {
    const token = request.headers.get('authorization')?.replace('Bearer ', '');
    if (!token) {
      return NextResponse.json(
        { error: { message: 'Authorization token required', code: 'UNAUTHORIZED' } },
        { status: 401 }
      );
    }

    verifyToken(token);
    // TODO: Add admin role check

    const { searchParams } = new URL(request.url);
    const startDate = searchParams.get('start_date');
    const endDate = searchParams.get('end_date');

    // Session-based revenue calculation
    // Assuming each completed session generates revenue (this is a placeholder)
    const revenueQuery = `
      SELECT
        COUNT(CASE WHEN status = 'completed' THEN 1 END) as completed_sessions,
        COUNT(CASE WHEN status = 'cancelled' THEN 1 END) as cancelled_sessions,
        COUNT(*) as total_sessions,
        DATE_TRUNC('month', session_date) as month
      FROM sessions
      WHERE 1=1
      ${startDate ? `AND session_date >= $1::DATE` : ''}
      ${endDate ? `AND session_date <= $${startDate ? 2 : 1}::DATE` : ''}
      GROUP BY DATE_TRUNC('month', session_date)
      ORDER BY month DESC
    `;

    const params: any[] = [];
    if (startDate) params.push(startDate);
    if (endDate) params.push(endDate);

    const revenueResult = await pool.query(revenueQuery, params);

    // Calculate totals (placeholder rates - $20 per session)
    const SESSION_RATE = 20;
    const totals = revenueResult.rows.reduce(
      (acc, row) => ({
        total_completed: acc.total_completed + parseInt(row.completed_sessions),
        total_revenue: acc.total_revenue + parseInt(row.completed_sessions) * SESSION_RATE,
        total_sessions: acc.total_sessions + parseInt(row.total_sessions)
      }),
      { total_completed: 0, total_revenue: 0, total_sessions: 0 }
    );

    // Mentor earnings (top earners)
    const mentorEarnings = await pool.query(`
      SELECT
        m.id, m.name, m.email,
        COUNT(s.id) as completed_sessions,
        COUNT(s.id) * $1 as total_earnings
      FROM mentors m
      LEFT JOIN sessions s ON m.id = s.mentor_id AND s.status = 'completed'
      ${startDate ? `AND s.session_date >= $2::DATE` : ''}
      ${endDate ? `AND s.session_date <= $${startDate ? 3 : 2}::DATE` : ''}
      GROUP BY m.id, m.name, m.email
      HAVING COUNT(s.id) > 0
      ORDER BY total_earnings DESC
      LIMIT 20
    `, [SESSION_RATE, ...params]);

    return NextResponse.json({
      summary: {
        total_sessions: totals.total_sessions,
        completed_sessions: totals.total_completed,
        total_revenue: totals.total_revenue,
        average_session_rate: SESSION_RATE
      },
      monthly_revenue: revenueResult.rows.map(row => ({
        month: row.month,
        completed_sessions: parseInt(row.completed_sessions),
        cancelled_sessions: parseInt(row.cancelled_sessions),
        revenue: parseInt(row.completed_sessions) * SESSION_RATE
      })),
      top_earning_mentors: mentorEarnings.rows
    });
  } catch (error: any) {
    console.error('Admin financial reports error:', error);
    return NextResponse.json(
      {
        error: {
          message: 'Internal server error while fetching financial reports',
          code: 'INTERNAL_ERROR',
          meta: { error: error.message }
        }
      },
      { status: 500 }
    );
  }
}
