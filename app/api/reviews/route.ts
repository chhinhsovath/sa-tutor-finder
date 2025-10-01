import { NextRequest, NextResponse } from 'next/server';
import pool from '@/lib/db';
import { verifyToken } from '@/lib/auth';

export const dynamic = 'force-dynamic';

// POST /api/reviews - Submit a review for a mentor
export async function POST(request: NextRequest) {
  try {
    const token = request.headers.get('authorization')?.replace('Bearer ', '');
    if (!token) {
      return NextResponse.json(
        { error: { message: 'Authorization token required', code: 'UNAUTHORIZED' } },
        { status: 401 }
      );
    }

    const decoded = verifyToken(token);
    const body = await request.json();
    const { mentor_id, session_id, rating, comment } = body;

    if (!mentor_id || !rating) {
      return NextResponse.json(
        {
          error: {
            message: 'Missing required fields: mentor_id, rating',
            code: 'VALIDATION_ERROR'
          }
        },
        { status: 400 }
      );
    }

    if (rating < 1 || rating > 5) {
      return NextResponse.json(
        {
          error: {
            message: 'Rating must be between 1 and 5',
            code: 'VALIDATION_ERROR'
          }
        },
        { status: 400 }
      );
    }

    // If session_id provided, verify it belongs to student and mentor
    if (session_id) {
      const sessionCheck = await pool.query(
        'SELECT * FROM sessions WHERE id = $1 AND student_id = $2 AND mentor_id = $3',
        [session_id, decoded.student_id, mentor_id]
      );

      if (sessionCheck.rows.length === 0) {
        return NextResponse.json(
          {
            error: {
              message: 'Session not found or does not match mentor',
              code: 'INVALID_SESSION'
            }
          },
          { status: 400 }
        );
      }

      // Check if review already exists for this session
      const existingReview = await pool.query(
        'SELECT * FROM reviews WHERE session_id = $1 AND student_id = $2',
        [session_id, decoded.student_id]
      );

      if (existingReview.rows.length > 0) {
        return NextResponse.json(
          {
            error: {
              message: 'You have already reviewed this session',
              code: 'REVIEW_EXISTS'
            }
          },
          { status: 400 }
        );
      }
    }

    const result = await pool.query(
      `INSERT INTO reviews (student_id, mentor_id, session_id, rating, comment)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING *`,
      [decoded.student_id, mentor_id, session_id || null, rating, comment || null]
    );

    return NextResponse.json({
      review: result.rows[0],
      message: 'Review submitted successfully'
    }, { status: 201 });
  } catch (error: any) {
    console.error('Submit review error:', error);
    if (error.code === '23505') { // Unique violation
      return NextResponse.json(
        {
          error: {
            message: 'You have already reviewed this session',
            code: 'REVIEW_EXISTS'
          }
        },
        { status: 400 }
      );
    }
    return NextResponse.json(
      {
        error: {
          message: 'Internal server error while submitting review',
          code: 'INTERNAL_ERROR',
          meta: { error: error.message }
        }
      },
      { status: 500 }
    );
  }
}
