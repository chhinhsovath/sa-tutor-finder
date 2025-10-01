import { NextRequest, NextResponse } from 'next/server';
import pool from '@/lib/db';
import { verifyToken } from '@/lib/auth';

export const dynamic = 'force-dynamic';

// GET /api/students - List students (for mentors/counselors)
export async function GET(request: NextRequest) {
  try {
    const token = request.headers.get('authorization')?.replace('Bearer ', '');
    if (!token) {
      return NextResponse.json(
        { error: { message: 'Authorization token required', code: 'UNAUTHORIZED' } },
        { status: 401 }
      );
    }

    const decoded = verifyToken(token);
    const { searchParams } = new URL(request.url);
    const status = searchParams.get('status');
    const gradeLevel = searchParams.get('grade_level');

    // Only mentors and counselors can list students
    if (!decoded.mentor_id && !decoded.counselor_id) {
      return NextResponse.json(
        { error: { message: 'Forbidden: Only mentors and counselors can access', code: 'FORBIDDEN' } },
        { status: 403 }
      );
    }

    let query = `
      SELECT s.id, s.name, s.email, s.grade_level, s.contact, s.status, s.created_at
      FROM students s
      WHERE 1=1
    `;
    const params: any[] = [];

    if (status) {
      params.push(status);
      query += ` AND s.status = $${params.length}`;
    }

    if (gradeLevel) {
      params.push(gradeLevel);
      query += ` AND s.grade_level = $${params.length}`;
    }

    query += ' ORDER BY s.name ASC';

    const result = await pool.query(query, params);

    return NextResponse.json({
      students: result.rows,
      count: result.rows.length
    });
  } catch (error: any) {
    console.error('Get students error:', error);
    return NextResponse.json(
      {
        error: {
          message: 'Internal server error while fetching students',
          code: 'INTERNAL_ERROR',
          meta: { error: error.message }
        }
      },
      { status: 500 }
    );
  }
}
