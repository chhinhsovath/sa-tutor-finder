import { NextRequest, NextResponse } from 'next/server';
import pool from '@/lib/db';
import { verifyToken } from '@/lib/auth';

export const dynamic = 'force-dynamic';

// GET /api/admin/analytics - Platform analytics (admin only)
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

    // User statistics
    const userStats = await pool.query(`
      SELECT
        (SELECT COUNT(*) FROM mentors WHERE status = 'active') as active_mentors,
        (SELECT COUNT(*) FROM mentors) as total_mentors,
        (SELECT COUNT(*) FROM students WHERE status = 'active') as active_students,
        (SELECT COUNT(*) FROM students) as total_students,
        (SELECT COUNT(*) FROM counselors WHERE status = 'active') as active_counselors,
        (SELECT COUNT(*) FROM counselors) as total_counselors
    `);

    // Session statistics
    const sessionStats = await pool.query(`
      SELECT
        COUNT(*) as total_sessions,
        COUNT(CASE WHEN status = 'scheduled' THEN 1 END) as scheduled,
        COUNT(CASE WHEN status = 'completed' THEN 1 END) as completed,
        COUNT(CASE WHEN status = 'cancelled' THEN 1 END) as cancelled,
        COUNT(CASE WHEN status = 'no-show' THEN 1 END) as no_show
      FROM sessions
    `);

    // Recent sessions trend (last 30 days)
    const sessionTrend = await pool.query(`
      SELECT
        DATE(session_date) as date,
        COUNT(*) as count
      FROM sessions
      WHERE session_date >= CURRENT_DATE - INTERVAL '30 days'
      GROUP BY DATE(session_date)
      ORDER BY date DESC
      LIMIT 30
    `);

    // Average rating per mentor
    const ratingStats = await pool.query(`
      SELECT
        AVG(rating) as average_rating,
        COUNT(*) as total_reviews
      FROM reviews
    `);

    // Top rated mentors
    const topMentors = await pool.query(`
      SELECT
        m.id, m.name, m.english_level,
        AVG(r.rating) as average_rating,
        COUNT(r.id) as review_count
      FROM mentors m
      LEFT JOIN reviews r ON m.id = r.mentor_id
      WHERE m.status = 'active'
      GROUP BY m.id, m.name, m.english_level
      HAVING COUNT(r.id) > 0
      ORDER BY average_rating DESC, review_count DESC
      LIMIT 10
    `);

    // Engagement metrics
    const engagementStats = await pool.query(`
      SELECT
        (SELECT COUNT(*) FROM messages WHERE created_at >= CURRENT_DATE - INTERVAL '7 days') as messages_last_7_days,
        (SELECT COUNT(*) FROM sessions WHERE session_date >= CURRENT_DATE - INTERVAL '7 days') as sessions_last_7_days,
        (SELECT COUNT(*) FROM reviews WHERE created_at >= CURRENT_DATE - INTERVAL '7 days') as reviews_last_7_days
    `);

    return NextResponse.json({
      users: userStats.rows[0],
      sessions: sessionStats.rows[0],
      session_trend: sessionTrend.rows,
      ratings: ratingStats.rows[0],
      top_mentors: topMentors.rows,
      engagement: engagementStats.rows[0]
    });
  } catch (error: any) {
    console.error('Admin analytics error:', error);
    return NextResponse.json(
      {
        error: {
          message: 'Internal server error while fetching analytics',
          code: 'INTERNAL_ERROR',
          meta: { error: error.message }
        }
      },
      { status: 500 }
    );
  }
}
