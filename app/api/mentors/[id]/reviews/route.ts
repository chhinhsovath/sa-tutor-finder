import { NextRequest, NextResponse } from 'next/server';
import pool from '@/lib/db';

export const dynamic = 'force-dynamic';

// GET /api/mentors/[id]/reviews - Get all reviews for a mentor
export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id: mentor_id } = await params;

    // Get reviews with student names
    const result = await pool.query(
      `SELECT r.*,
              s.name as student_name
       FROM reviews r
       JOIN students s ON r.student_id = s.id
       WHERE r.mentor_id = $1
       ORDER BY r.created_at DESC`,
      [mentor_id]
    );

    // Calculate average rating and distribution
    const stats = await pool.query(
      `SELECT
         COUNT(*) as total_reviews,
         AVG(rating) as average_rating,
         COUNT(CASE WHEN rating = 5 THEN 1 END) as five_star,
         COUNT(CASE WHEN rating = 4 THEN 1 END) as four_star,
         COUNT(CASE WHEN rating = 3 THEN 1 END) as three_star,
         COUNT(CASE WHEN rating = 2 THEN 1 END) as two_star,
         COUNT(CASE WHEN rating = 1 THEN 1 END) as one_star
       FROM reviews
       WHERE mentor_id = $1`,
      [mentor_id]
    );

    return NextResponse.json({
      reviews: result.rows,
      stats: {
        total_reviews: parseInt(stats.rows[0].total_reviews),
        average_rating: parseFloat(stats.rows[0].average_rating || 0).toFixed(1),
        distribution: {
          5: parseInt(stats.rows[0].five_star),
          4: parseInt(stats.rows[0].four_star),
          3: parseInt(stats.rows[0].three_star),
          2: parseInt(stats.rows[0].two_star),
          1: parseInt(stats.rows[0].one_star)
        }
      }
    });
  } catch (error: any) {
    console.error('Get mentor reviews error:', error);
    return NextResponse.json(
      {
        error: {
          message: 'Internal server error while fetching reviews',
          code: 'INTERNAL_ERROR',
          meta: { error: error.message }
        }
      },
      { status: 500 }
    );
  }
}
