import { NextRequest, NextResponse } from 'next/server';
import pool from '@/lib/db';
import { verifyToken } from '@/lib/auth';

export const dynamic = 'force-dynamic';

// GET /api/admin/students - List all students (admin only)
export async function GET(request: NextRequest) {
  try {
    const token = request.headers.get('authorization')?.replace('Bearer ', '');
    if (!token) {
      return NextResponse.json(
        { error: { message: 'Authorization token required', code: 'UNAUTHORIZED' } },
        { status: 401 }
      );
    }

    verifyToken(token);
    // TODO: Add admin role check when auth system supports roles

    const { searchParams } = new URL(request.url);
    const status = searchParams.get('status');
    const gradeLevel = searchParams.get('grade_level');
    const search = searchParams.get('search');

    let query = `
      SELECT s.*,
             COUNT(DISTINCT ses.id) as total_sessions,
             COUNT(DISTINCT CASE WHEN ses.status = 'completed' THEN ses.id END) as completed_sessions
      FROM students s
      LEFT JOIN sessions ses ON s.id = ses.student_id
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

    if (search) {
      params.push(`%${search}%`);
      query += ` AND (s.name ILIKE $${params.length} OR s.email ILIKE $${params.length})`;
    }

    query += ' GROUP BY s.id ORDER BY s.created_at DESC';

    const result = await pool.query(query, params);

    return NextResponse.json({
      students: result.rows,
      count: result.rows.length
    });
  } catch (error: any) {
    console.error('Admin get students error:', error);
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
