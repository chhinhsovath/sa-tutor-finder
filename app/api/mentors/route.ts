import { NextRequest, NextResponse } from 'next/server';
import prisma from '@/lib/prisma';
import { Prisma } from '@prisma/client';

export const dynamic = 'force-dynamic';

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url);
    const day = searchParams.get('day');
    const from = searchParams.get('from');
    const to = searchParams.get('to');
    const level = searchParams.get('level');

    // Build where conditions
    const whereConditions: Prisma.mentorsWhereInput = {
      status: 'active'
    };

    // Add english level filter
    if (level) {
      whereConditions.english_level = level as any;
    }

    // Add availability filters
    if (day || (from && to)) {
      const availabilityFilters: any = {};

      if (day) {
        availabilityFilters.day_of_week = parseInt(day);
      }

      if (from && to) {
        // Time overlap: start_time < search_end AND end_time > search_start
        availabilityFilters.start_time = {
          lt: new Date(`1970-01-01T${to}:00`)
        };
        availabilityFilters.end_time = {
          gt: new Date(`1970-01-01T${from}:00`)
        };
      }

      whereConditions.availability_slots = {
        some: availabilityFilters
      };
    }

    // Fetch mentors with their availability slots
    const mentors = await prisma.mentors.findMany({
      where: whereConditions,
      include: {
        availability_slots: true
      },
      orderBy: {
        created_at: 'desc'
      }
    });

    // Format response (exclude password_hash if accidentally included)
    const formattedMentors = mentors.map(mentor => {
      const { password_hash, ...mentorWithoutPassword } = mentor;
      return mentorWithoutPassword;
    });

    return NextResponse.json({
      mentors: formattedMentors,
      count: formattedMentors.length
    });
  } catch (error: any) {
    console.error('Get mentors error:', error);
    return NextResponse.json(
      {
        error: {
          message: 'Internal server error while fetching mentors',
          code: 'INTERNAL_ERROR',
          meta: { error: error.message }
        }
      },
      { status: 500 }
    );
  }
}
