import { NextRequest, NextResponse } from 'next/server';
import pool from '@/lib/db';

export async function GET(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const { id } = params;

    // Get mentor details
    const mentorResult = await pool.query(
      `SELECT id, name, email, english_level, contact, timezone, status, created_at, updated_at
       FROM mentors
       WHERE id = $1`,
      [id]
    );

    if (mentorResult.rows.length === 0) {
      return NextResponse.json(
        {
          error: {
            message: 'Mentor not found',
            code: 'MENTOR_NOT_FOUND',
            meta: { mentor_id: id }
          }
        },
        { status: 404 }
      );
    }

    const mentor = mentorResult.rows[0];

    // Get availability slots
    const slotsResult = await pool.query(
      `SELECT id, day_of_week, start_time, end_time
       FROM availability_slots
       WHERE mentor_id = $1
       ORDER BY day_of_week, start_time`,
      [id]
    );

    return NextResponse.json({
      ...mentor,
      availability_slots: slotsResult.rows
    });
  } catch (error: any) {
    console.error('Get mentor error:', error);
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
