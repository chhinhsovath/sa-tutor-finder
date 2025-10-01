import { NextRequest, NextResponse } from 'next/server';
import pool from '@/lib/db';
import { verifyToken } from '@/lib/auth';

export const dynamic = 'force-dynamic';

// PATCH /api/admin/students/[id] - Update student (admin only)
export async function PATCH(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params;
    const token = request.headers.get('authorization')?.replace('Bearer ', '');
    if (!token) {
      return NextResponse.json(
        { error: { message: 'Authorization token required', code: 'UNAUTHORIZED' } },
        { status: 401 }
      );
    }

    verifyToken(token);
    // TODO: Add admin role check

    const body = await request.json();
    const { status, grade_level, name, email, contact } = body;

    const updates: string[] = [];
    const values: any[] = [];
    let paramCount = 1;

    if (status) {
      updates.push(`status = $${paramCount++}`);
      values.push(status);
    }
    if (grade_level) {
      updates.push(`grade_level = $${paramCount++}`);
      values.push(grade_level);
    }
    if (name) {
      updates.push(`name = $${paramCount++}`);
      values.push(name);
    }
    if (email) {
      updates.push(`email = $${paramCount++}`);
      values.push(email);
    }
    if (contact !== undefined) {
      updates.push(`contact = $${paramCount++}`);
      values.push(contact);
    }

    if (updates.length === 0) {
      return NextResponse.json(
        { error: { message: 'No fields to update', code: 'VALIDATION_ERROR' } },
        { status: 400 }
      );
    }

    values.push(id);
    const result = await pool.query(
      `UPDATE students SET ${updates.join(', ')} WHERE id = $${paramCount} RETURNING *`,
      values
    );

    if (result.rows.length === 0) {
      return NextResponse.json(
        { error: { message: 'Student not found', code: 'STUDENT_NOT_FOUND' } },
        { status: 404 }
      );
    }

    return NextResponse.json({
      student: result.rows[0],
      message: 'Student updated successfully'
    });
  } catch (error: any) {
    console.error('Admin update student error:', error);
    return NextResponse.json(
      {
        error: {
          message: 'Internal server error while updating student',
          code: 'INTERNAL_ERROR',
          meta: { error: error.message }
        }
      },
      { status: 500 }
    );
  }
}
