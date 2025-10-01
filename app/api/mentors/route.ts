import { NextRequest, NextResponse } from 'next/server';
import pool from '@/lib/db';

export const dynamic = 'force-dynamic';

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url);
    const day = searchParams.get('day');
    const from = searchParams.get('from');
    const to = searchParams.get('to');
    const level = searchParams.get('level');

    let query = `
      SELECT DISTINCT m.id, m.name, m.email, m.english_level, m.contact, m.timezone, m.status, m.created_at, m.updated_at
      FROM mentors m
    `;
    const params: any[] = [];
    const conditions: string[] = ['m.status = $1'];
    params.push('active');

    // If filtering by availability
    if (day || (from && to)) {
      query += ' JOIN availability_slots s ON m.id = s.mentor_id';

      if (day) {
        conditions.push(`s.day_of_week = $${params.length + 1}`);
        params.push(parseInt(day));
      }

      if (from && to) {
        conditions.push(`s.start_time < $${params.length + 1}`);
        params.push(to);
        conditions.push(`s.end_time > $${params.length + 1}`);
        params.push(from);
      }
    }

    if (level) {
      conditions.push(`m.english_level = $${params.length + 1}`);
      params.push(level);
    }

    if (conditions.length > 0) {
      query += ' WHERE ' + conditions.join(' AND ');
    }

    query += ' ORDER BY m.created_at DESC';

    const result = await pool.query(query, params);

    return NextResponse.json({
      mentors: result.rows,
      count: result.rows.length
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
