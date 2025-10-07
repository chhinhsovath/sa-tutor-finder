import { NextRequest, NextResponse } from 'next/server';
import prisma from '@/lib/prisma';

export const dynamic = 'force-dynamic';

export async function GET(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const { id } = params;

    const mentor = await prisma.mentors.findUnique({
      where: { id },
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
        updated_at: true,
        availability_slots: {
          orderBy: [
            { day_of_week: 'asc' },
            { start_time: 'asc' }
          ]
        },
        reviews: {
          include: {
            student: {
              select: {
                id: true,
                name: true
              }
            }
          },
          orderBy: {
            created_at: 'desc'
          },
          take: 10
        }
      }
    });

    if (!mentor) {
      return NextResponse.json(
        {
          error: {
            message: 'Mentor not found',
            code: 'MENTOR_NOT_FOUND',
            meta: { id }
          }
        },
        { status: 404 }
      );
    }

    if (mentor.status !== 'active') {
      return NextResponse.json(
        {
          error: {
            message: 'Mentor is not active',
            code: 'MENTOR_INACTIVE',
            meta: { status: mentor.status }
          }
        },
        { status: 403 }
      );
    }

    return NextResponse.json({ mentor });
  } catch (error: any) {
    console.error('Get mentor detail error:', error);
    return NextResponse.json(
      {
        error: {
          message: 'Internal server error while fetching mentor details',
          code: 'INTERNAL_ERROR',
          meta: { error: error.message }
        }
      },
      { status: 500 }
    );
  }
}
