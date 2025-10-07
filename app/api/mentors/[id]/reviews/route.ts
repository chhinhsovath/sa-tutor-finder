import { NextRequest, NextResponse } from 'next/server';
import prisma from '@/lib/prisma';

export const dynamic = 'force-dynamic';

// GET /api/mentors/[id]/reviews - Get reviews for a mentor with pagination
export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id: mentor_id } = await params;
    const { searchParams } = new URL(request.url);

    // Pagination parameters
    const limit = parseInt(searchParams.get('limit') || '10');
    const offset = parseInt(searchParams.get('offset') || '0');

    // Get reviews with student names (paginated)
    const [reviews, totalCount] = await Promise.all([
      prisma.reviews.findMany({
        where: { mentor_id },
        include: {
          student: {
            select: { id: true, name: true }
          }
        },
        orderBy: { created_at: 'desc' },
        take: limit,
        skip: offset
      }),
      prisma.reviews.count({ where: { mentor_id } })
    ]);

    // Calculate average rating and distribution
    const allReviews = await prisma.reviews.findMany({
      where: { mentor_id },
      select: { rating: true }
    });

    const distribution = { 5: 0, 4: 0, 3: 0, 2: 0, 1: 0 };
    let totalRating = 0;

    allReviews.forEach(r => {
      distribution[r.rating as keyof typeof distribution]++;
      totalRating += r.rating;
    });

    const averageRating = allReviews.length > 0
      ? (totalRating / allReviews.length).toFixed(1)
      : '0.0';

    // Format reviews to include student_name for compatibility
    const formattedReviews = reviews.map(r => ({
      id: r.id,
      mentor_id: r.mentor_id,
      student_id: r.student_id,
      student_name: r.student.name,
      session_id: r.session_id,
      rating: r.rating,
      comment: r.comment,
      created_at: r.created_at,
      updated_at: r.updated_at
    }));

    return NextResponse.json({
      reviews: formattedReviews,
      stats: {
        total_reviews: totalCount,
        average_rating: averageRating,
        distribution
      },
      pagination: {
        total: totalCount,
        limit,
        offset,
        hasMore: offset + reviews.length < totalCount
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
