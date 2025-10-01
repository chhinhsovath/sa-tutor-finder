import { NextRequest, NextResponse } from 'next/server';
import pool from '@/lib/db';
import { extractToken, verifyToken } from '@/lib/auth';

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

    const result = await pool.query(
      `SELECT id, day_of_week, start_time, end_time
       FROM availability_slots
       WHERE mentor_id = $1
       ORDER BY day_of_week, start_time`,
      [decoded.mentor_id]
    );

    return NextResponse.json({
      availability_slots: result.rows
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

    // Use transaction for atomic replacement
    const client = await pool.connect();
    try {
      await client.query('BEGIN');

      // Delete existing slots
      await client.query(
        'DELETE FROM availability_slots WHERE mentor_id = $1',
        [decoded.mentor_id]
      );

      // Insert new slots
      const insertedSlots = [];
      for (const slot of slots) {
        const result = await client.query(
          `INSERT INTO availability_slots (mentor_id, day_of_week, start_time, end_time)
           VALUES ($1, $2, $3, $4)
           RETURNING id, day_of_week, start_time, end_time`,
          [decoded.mentor_id, slot.day_of_week, slot.start_time, slot.end_time]
        );
        insertedSlots.push(result.rows[0]);
      }

      await client.query('COMMIT');

      return NextResponse.json({
        message: 'Availability updated successfully',
        availability_slots: insertedSlots
      });
    } catch (error) {
      await client.query('ROLLBACK');
      throw error;
    } finally {
      client.release();
    }
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
