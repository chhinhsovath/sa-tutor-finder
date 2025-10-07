import { NextRequest, NextResponse } from 'next/server';
import prisma from '@/lib/prisma';
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
    const { name, email, phone_number, english_level, learning_goals, timezone, status } = body;

    const updateData: any = {};

    if (name !== undefined) updateData.name = name;
    if (email !== undefined) updateData.email = email;
    if (phone_number !== undefined) updateData.phone_number = phone_number;
    if (english_level !== undefined) updateData.english_level = english_level;
    if (learning_goals !== undefined) updateData.learning_goals = learning_goals;
    if (timezone !== undefined) updateData.timezone = timezone;
    if (status !== undefined) updateData.status = status;

    if (Object.keys(updateData).length === 0) {
      return NextResponse.json(
        { error: { message: 'No fields to update', code: 'VALIDATION_ERROR' } },
        { status: 400 }
      );
    }

    const student = await prisma.students.update({
      where: { id },
      data: updateData
    });

    return NextResponse.json({
      student,
      message: 'Student updated successfully'
    });
  } catch (error: any) {
    console.error('Admin update student error:', error);

    if (error.code === 'P2025') {
      return NextResponse.json(
        { error: { message: 'Student not found', code: 'STUDENT_NOT_FOUND' } },
        { status: 404 }
      );
    }

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

// DELETE /api/admin/students/[id] - Delete student (admin only)
export async function DELETE(
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

    await prisma.students.delete({
      where: { id }
    });

    return NextResponse.json({
      message: 'Student deleted successfully'
    });
  } catch (error: any) {
    console.error('Admin delete student error:', error);

    if (error.code === 'P2025') {
      return NextResponse.json(
        { error: { message: 'Student not found', code: 'STUDENT_NOT_FOUND' } },
        { status: 404 }
      );
    }

    return NextResponse.json(
      {
        error: {
          message: 'Internal server error while deleting student',
          code: 'INTERNAL_ERROR',
          meta: { error: error.message }
        }
      },
      { status: 500 }
    );
  }
}
