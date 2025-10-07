import { NextRequest, NextResponse } from 'next/server';
import prisma from '@/lib/prisma';
import { extractToken, verifyToken } from '@/lib/auth';

export const dynamic = 'force-dynamic';

// POST /api/reviews - Create a review for a session
export async function POST(request: NextRequest) {
  try {
    const token = extractToken(request.headers.get('authorization'));
    if (!token) {
      return NextResponse.json(
        { error: { message: 'No authorization token provided', code: 'UNAUTHORIZED', meta: {} } },
        { status: 401 }
      );
    }

    const decoded = verifyToken(token);
    if (!decoded) {
      return NextResponse.json(
        { error: { message: 'Invalid or expired token', code: 'UNAUTHORIZED', meta: {} } },
        { status: 401 }
      );
    }

    const userId = decoded.user_id || decoded.mentor_id;
    const userType = decoded.user_type || 'student';

    if (userType !== 'student') {
      return NextResponse.json(
        { error: { message: 'Only students can leave reviews', code: 'FORBIDDEN', meta: {} } },
        { status: 403 }
      );
    }

    const body = await request.json();
    const { session_id, rating, comment } = body;

    if (!session_id || !rating) {
      return NextResponse.json(
        { error: { message: 'session_id and rating are required', code: 'VALIDATION_ERROR', meta: {} } },
        { status: 400 }
      );
    }

    if (rating < 1 || rating > 5) {
      return NextResponse.json(
        { error: { message: 'Rating must be between 1 and 5', code: 'VALIDATION_ERROR', meta: {} } },
        { status: 400 }
      );
    }

    // Check session exists and belongs to student
    const session = await prisma.sessions.findUnique({ where: { id: session_id } });
    if (!session) {
      return NextResponse.json(
        { error: { message: 'Session not found', code: 'SESSION_NOT_FOUND', meta: {} } },
        { status: 404 }
      );
    }

    if (session.student_id !== userId) {
      return NextResponse.json(
        { error: { message: 'You can only review your own sessions', code: 'FORBIDDEN', meta: {} } },
        { status: 403 }
      );
    }

    if (session.status !== 'completed') {
      return NextResponse.json(
        { error: { message: 'Can only review completed sessions', code: 'VALIDATION_ERROR', meta: {} } },
        { status: 400 }
      );
    }

    // Check if review already exists
    const existingReview = await prisma.reviews.findUnique({ where: { session_id } });
    if (existingReview) {
      return NextResponse.json(
        { error: { message: 'Session already has a review', code: 'REVIEW_EXISTS', meta: {} } },
        { status: 409 }
      );
    }

    // Create review
    const review = await prisma.reviews.create({
      data: {
        session_id,
        student_id: userId,
        mentor_id: session.mentor_id,
        rating,
        comment: comment || null
      },
      include: {
        student: { select: { id: true, name: true } },
        mentor: { select: { id: true, name: true } }
      }
    });

    // Update mentor's average rating
    const mentorReviews = await prisma.reviews.findMany({
      where: { mentor_id: session.mentor_id },
      select: { rating: true }
    });

    const avgRating = mentorReviews.reduce((sum, r) => sum + r.rating, 0) / mentorReviews.length;

    await prisma.mentors.update({
      where: { id: session.mentor_id },
      data: { average_rating: avgRating }
    });

    return NextResponse.json({ review }, { status: 201 });
  } catch (error: any) {
    console.error('Create review error:', error);
    return NextResponse.json(
      { error: { message: 'Internal server error', code: 'INTERNAL_ERROR', meta: { error: error.message } } },
      { status: 500 }
    );
  }
}
