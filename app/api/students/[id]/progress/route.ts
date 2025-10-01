import { NextRequest, NextResponse } from 'next/server';
import pool from '@/lib/db';
import { verifyToken } from '@/lib/auth';

export const dynamic = 'force-dynamic';

// GET /api/students/[id]/progress - Get student progress reports
export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id: student_id } = await params;
    const token = request.headers.get('authorization')?.replace('Bearer ', '');
    if (!token) {
      return NextResponse.json(
        { error: { message: 'Authorization token required', code: 'UNAUTHORIZED' } },
        { status: 401 }
      );
    }

    verifyToken(token);

    const result = await pool.query(
      `SELECT sp.*,
              CASE
                WHEN sp.recorder_type = 'mentor' THEN m.name
                WHEN sp.recorder_type = 'counselor' THEN c.name
              END as recorder_name
       FROM student_progress sp
       LEFT JOIN mentors m ON sp.recorder_type = 'mentor' AND sp.recorder_id = m.id
       LEFT JOIN counselors c ON sp.recorder_type = 'counselor' AND sp.recorder_id = c.id
       WHERE sp.student_id = $1
       ORDER BY sp.created_at DESC`,
      [student_id]
    );

    return NextResponse.json({
      progress_reports: result.rows,
      count: result.rows.length
    });
  } catch (error: any) {
    console.error('Get student progress error:', error);
    return NextResponse.json(
      {
        error: {
          message: 'Internal server error while fetching student progress',
          code: 'INTERNAL_ERROR',
          meta: { error: error.message }
        }
      },
      { status: 500 }
    );
  }
}

// POST /api/students/[id]/progress - Add progress report
export async function POST(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id: student_id } = await params;
    const token = request.headers.get('authorization')?.replace('Bearer ', '');
    if (!token) {
      return NextResponse.json(
        { error: { message: 'Authorization token required', code: 'UNAUTHORIZED' } },
        { status: 401 }
      );
    }

    const decoded = verifyToken(token);
    if (!decoded) {
      return NextResponse.json(
        { error: { message: 'Invalid or expired token', code: 'UNAUTHORIZED' } },
        { status: 401 }
      );
    }

    const body = await request.json();
    const { progress_notes, skills_improved, areas_for_improvement } = body;

    if (!progress_notes) {
      return NextResponse.json(
        {
          error: {
            message: 'Missing required field: progress_notes',
            code: 'VALIDATION_ERROR'
          }
        },
        { status: 400 }
      );
    }

    // Current system only supports mentor auth
    const recorderType = 'mentor';
    const recorderId = decoded.mentor_id;

    const result = await pool.query(
      `INSERT INTO student_progress (student_id, recorder_id, recorder_type, progress_notes, skills_improved, areas_for_improvement)
       VALUES ($1, $2, $3, $4, $5, $6)
       RETURNING *`,
      [student_id, recorderId, recorderType, progress_notes, skills_improved || null, areas_for_improvement || null]
    );

    return NextResponse.json({
      progress: result.rows[0],
      message: 'Progress report added successfully'
    }, { status: 201 });
  } catch (error: any) {
    console.error('Add student progress error:', error);
    return NextResponse.json(
      {
        error: {
          message: 'Internal server error while adding student progress',
          code: 'INTERNAL_ERROR',
          meta: { error: error.message }
        }
      },
      { status: 500 }
    );
  }
}
