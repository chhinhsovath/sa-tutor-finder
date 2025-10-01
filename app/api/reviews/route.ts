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
    if (!decoded) {
      return NextResponse.json(
        { error: { message: 'Invalid or expired token', code: 'UNAUTHORIZED' } },
        { status: 401 }
      );
    }

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

    // This route requires student authentication
    // Current system only supports mentor auth, so return error
    return NextResponse.json(
      {
        error: {
          message: 'Review submission requires student authentication (not yet implemented)',
          code: 'NOT_IMPLEMENTED'
        }
      },
      { status: 501 }
    );
  } catch (error: any) {
    console.error('Submit review error:', error);
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
