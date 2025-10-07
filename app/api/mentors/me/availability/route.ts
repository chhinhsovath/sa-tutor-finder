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

    const slots = await prisma.availability_slots.findMany({
      where: { mentor_id: mentorId },
      orderBy: [
        { day_of_week: 'asc' },
        { start_time: 'asc' }
      ]
    });

    return NextResponse.json({
      availability_slots: slots
    });
  } catch (error: any) {
    console.error('Get availability error:', error);
    return NextResponse.json(
      {
        error: {
          message: 'Internal server error while fetching availability',
          code: 'INTERNAL_ERROR',
          meta: { error: error.message }
        }
      },
      { status: 500 }
    );
  }
}

export async function POST(request: NextRequest) {
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
    const { slots } = body;

    if (!Array.isArray(slots)) {
      return NextResponse.json(
        {
          error: {
            message: 'slots must be an array',
            code: 'VALIDATION_ERROR',
            meta: { expected: 'array', received: typeof slots }
          }
        },
        { status: 400 }
      );
    }

    // Validate all slots
    for (let i = 0; i < slots.length; i++) {
      const slot = slots[i];
      if (!slot.day_of_week || !slot.start_time || !slot.end_time) {
        return NextResponse.json(
          {
            error: {
              message: `Slot at index ${i} is missing required fields`,
              code: 'VALIDATION_ERROR',
              meta: {
                slot_index: i,
                required_fields: ['day_of_week', 'start_time', 'end_time']
              }
            }
          },
          { status: 400 }
        );
      }

      if (slot.day_of_week < 1 || slot.day_of_week > 7) {
        return NextResponse.json(
          {
            error: {
              message: `Invalid day_of_week at index ${i}. Must be 1-7`,
              code: 'VALIDATION_ERROR',
              meta: { slot_index: i, valid_range: '1-7', received: slot.day_of_week }
            }
          },
          { status: 400 }
        );
      }
    }

    // Use Prisma transaction for atomic replacement
    const result = await prisma.$transaction(async (tx) => {
      // Delete existing slots
      await tx.availability_slots.deleteMany({
        where: { mentor_id: mentorId }
      });

      // Insert new slots
      const insertedSlots = [];
      for (const slot of slots) {
        // Parse time strings to Date objects for TIME columns
        const startTime = new Date(`1970-01-01T${slot.start_time}:00`);
        const endTime = new Date(`1970-01-01T${slot.end_time}:00`);

        const newSlot = await tx.availability_slots.create({
          data: {
            mentor_id: mentorId,
            day_of_week: slot.day_of_week,
            start_time: startTime,
            end_time: endTime
          }
        });
        insertedSlots.push(newSlot);
      }

      return insertedSlots;
    });

    return NextResponse.json({
      message: 'Availability updated successfully',
      availability_slots: result
    });
  } catch (error: any) {
    console.error('Update availability error:', error);
    return NextResponse.json(
      {
        error: {
          message: 'Internal server error while updating availability',
          code: 'INTERNAL_ERROR',
          meta: { error: error.message }
        }
      },
      { status: 500 }
    );
  }
}
