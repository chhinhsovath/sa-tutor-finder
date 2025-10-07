import { NextRequest, NextResponse } from 'next/server';
import prisma from '@/lib/prisma';
import { extractToken, verifyToken } from '@/lib/auth';

export const dynamic = 'force-dynamic';

// GET /api/students/me - Get student profile
export async function GET(request: NextRequest) {
  try {
    const token = extractToken(request.headers.get('authorization'));
    if (!token) {
      return NextResponse.json(
        { error: { message: 'No authorization token provided', code: 'UNAUTHORIZED', meta: {} } },
        { status: 401 }
      );
    }

    const decoded = verifyToken(token);
    if (!decoded) {
      return NextResponse.json(
        { error: { message: 'Invalid or expired token', code: 'UNAUTHORIZED', meta: {} } },
        { status: 401 }
      );
    }

    const userId = decoded.user_id;
    if (!userId || decoded.user_type !== 'student') {
      return NextResponse.json(
        { error: { message: 'Only students can access this endpoint', code: 'FORBIDDEN', meta: {} } },
        { status: 403 }
      );
    }

    const student = await prisma.students.findUnique({
      where: { id: userId },
      select: {
        id: true,
        name: true,
        email: true,
        phone_number: true,
        english_level: true,
        learning_goals: true,
        timezone: true,
        status: true,
        total_sessions: true,
        created_at: true,
        updated_at: true
      }
    });

    if (!student) {
      return NextResponse.json(
        { error: { message: 'Student not found', code: 'STUDENT_NOT_FOUND', meta: {} } },
        { status: 404 }
      );
    }

    return NextResponse.json({ student });
  } catch (error: any) {
    console.error('Get student profile error:', error);
    return NextResponse.json(
      { error: { message: 'Internal server error', code: 'INTERNAL_ERROR', meta: { error: error.message } } },
      { status: 500 }
    );
  }
}

// PATCH /api/students/me - Update student profile
export async function PATCH(request: NextRequest) {
  try {
    const token = extractToken(request.headers.get('authorization'));
    if (!token) {
      return NextResponse.json(
        { error: { message: 'No authorization token provided', code: 'UNAUTHORIZED', meta: {} } },
        { status: 401 }
      );
    }

    const decoded = verifyToken(token);
    if (!decoded) {
      return NextResponse.json(
        { error: { message: 'Invalid or expired token', code: 'UNAUTHORIZED', meta: {} } },
        { status: 401 }
      );
    }

    const userId = decoded.user_id;
    if (!userId || decoded.user_type !== 'student') {
      return NextResponse.json(
        { error: { message: 'Only students can access this endpoint', code: 'FORBIDDEN', meta: {} } },
        { status: 403 }
      );
    }

    const body = await request.json();
    const { name, phone_number, english_level, learning_goals, timezone } = body;

    const updateData: any = {};
    if (name) updateData.name = name;
    if (phone_number !== undefined) updateData.phone_number = phone_number;
    if (english_level) updateData.english_level = english_level;
    if (learning_goals !== undefined) updateData.learning_goals = learning_goals;
    if (timezone) updateData.timezone = timezone;

    if (Object.keys(updateData).length === 0) {
      return NextResponse.json(
        { error: { message: 'No fields to update', code: 'VALIDATION_ERROR', meta: {} } },
        { status: 400 }
      );
    }

    const updated = await prisma.students.update({
      where: { id: userId },
      data: updateData,
      select: {
        id: true,
        name: true,
        email: true,
        phone_number: true,
        english_level: true,
        learning_goals: true,
        timezone: true,
        status: true,
        total_sessions: true,
        created_at: true,
        updated_at: true
      }
    });

    return NextResponse.json({ student: updated });
  } catch (error: any) {
    console.error('Update student error:', error);
    return NextResponse.json(
      { error: { message: 'Internal server error', code: 'INTERNAL_ERROR', meta: { error: error.message } } },
      { status: 500 }
    );
  }
}
