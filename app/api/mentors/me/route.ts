import { NextRequest, NextResponse } from 'next/server';
import prisma from '@/lib/prisma';
import { extractToken, verifyToken } from '@/lib/auth';

export const dynamic = 'force-dynamic';

export async function GET(request: NextRequest) {
  try {
    // Verify authentication
    const token = extractToken(request.headers.get('authorization'));
    if (!token) {
      return NextResponse.json(
        {
          error: {
            message: 'No authorization token provided',
            code: 'UNAUTHORIZED',
            meta: {}
          }
        },
        { status: 401 }
      );
    }

    const decoded = verifyToken(token);
    if (!decoded) {
      return NextResponse.json(
        {
          error: {
            message: 'Invalid or expired token',
            code: 'UNAUTHORIZED',
            meta: {}
          }
        },
        { status: 401 }
      );
    }

    // Support both old (mentor_id) and new (user_id) token formats
    const mentorId = decoded.user_id || decoded.mentor_id;

    if (!mentorId || (decoded.user_type && decoded.user_type !== 'mentor')) {
      return NextResponse.json(
        {
          error: {
            message: 'Only mentors can access this endpoint',
            code: 'FORBIDDEN',
            meta: {}
          }
        },
        { status: 403 }
      );
    }

    const mentor = await prisma.mentors.findUnique({
      where: { id: mentorId },
      select: {
        id: true,
        name: true,
        email: true,
        english_level: true,
        contact: true,
        timezone: true,
        status: true,
        bio: true,
        hourly_rate: true,
        total_sessions: true,
        average_rating: true,
        created_at: true,
        updated_at: true
      }
    });

    if (!mentor) {
      return NextResponse.json(
        {
          error: {
            message: 'Mentor not found',
            code: 'MENTOR_NOT_FOUND',
            meta: {}
          }
        },
        { status: 404 }
      );
    }

    return NextResponse.json({ mentor });
  } catch (error: any) {
    console.error('Get mentor profile error:', error);
    return NextResponse.json(
      {
        error: {
          message: 'Internal server error while fetching profile',
          code: 'INTERNAL_ERROR',
          meta: { error: error.message }
        }
      },
      { status: 500 }
    );
  }
}

export async function PATCH(request: NextRequest) {
  try {
    // Verify authentication
    const token = extractToken(request.headers.get('authorization'));
    if (!token) {
      return NextResponse.json(
        {
          error: {
            message: 'No authorization token provided',
            code: 'UNAUTHORIZED',
            meta: {}
          }
        },
        { status: 401 }
      );
    }

    const decoded = verifyToken(token);
    if (!decoded) {
      return NextResponse.json(
        {
          error: {
            message: 'Invalid or expired token',
            code: 'UNAUTHORIZED',
            meta: {}
          }
        },
        { status: 401 }
      );
    }

    // Support both old (mentor_id) and new (user_id) token formats
    const mentorId = decoded.user_id || decoded.mentor_id;

    if (!mentorId || (decoded.user_type && decoded.user_type !== 'mentor')) {
      return NextResponse.json(
        {
          error: {
            message: 'Only mentors can access this endpoint',
            code: 'FORBIDDEN',
            meta: {}
          }
        },
        { status: 403 }
      );
    }

    const body = await request.json();
    const { name, english_level, contact, timezone, bio, hourly_rate } = body;

    const updateData: any = {};

    if (name) updateData.name = name;
    if (contact !== undefined) updateData.contact = contact;
    if (timezone) updateData.timezone = timezone;
    if (bio !== undefined) updateData.bio = bio;
    if (hourly_rate !== undefined) updateData.hourly_rate = hourly_rate;

    if (english_level) {
      const validLevels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
      if (!validLevels.includes(english_level)) {
        return NextResponse.json(
          {
            error: {
              message: 'Invalid english_level',
              code: 'VALIDATION_ERROR',
              meta: { valid_levels: validLevels }
            }
          },
          { status: 400 }
        );
      }
      updateData.english_level = english_level;
    }

    if (Object.keys(updateData).length === 0) {
      return NextResponse.json(
        {
          error: {
            message: 'No fields to update',
            code: 'VALIDATION_ERROR',
            meta: { allowed_fields: ['name', 'english_level', 'contact', 'timezone', 'bio', 'hourly_rate'] }
          }
        },
        { status: 400 }
      );
    }

    const updated = await prisma.mentors.update({
      where: { id: mentorId },
      data: updateData,
      select: {
        id: true,
        name: true,
        email: true,
        english_level: true,
        contact: true,
        timezone: true,
        status: true,
        bio: true,
        hourly_rate: true,
        total_sessions: true,
        average_rating: true,
        created_at: true,
        updated_at: true
      }
    });

    return NextResponse.json(updated);
  } catch (error: any) {
    console.error('Update mentor error:', error);

    if (error.code === 'P2025') {
      return NextResponse.json(
        {
          error: {
            message: 'Mentor not found',
            code: 'MENTOR_NOT_FOUND',
            meta: {}
          }
        },
        { status: 404 }
      );
    }

    return NextResponse.json(
      {
        error: {
          message: 'Internal server error while updating profile',
          code: 'INTERNAL_ERROR',
          meta: { error: error.message }
        }
      },
      { status: 500 }
    );
  }
}
