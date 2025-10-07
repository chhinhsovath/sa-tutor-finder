import { NextRequest, NextResponse } from 'next/server';
import prisma from '@/lib/prisma';
import { extractToken, verifyToken } from '@/lib/auth';

export const dynamic = 'force-dynamic';

// GET /api/counselors/me - Get counselor's own profile
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
    if (!decoded || decoded.user_type !== 'counselor') {
      return NextResponse.json(
        { error: { message: 'Only counselors can access this endpoint', code: 'FORBIDDEN', meta: {} } },
        { status: 403 }
      );
    }

    const counselorId = decoded.user_id;
    if (!counselorId) {
      return NextResponse.json(
        { error: { message: 'Invalid token', code: 'UNAUTHORIZED', meta: {} } },
        { status: 401 }
      );
    }

    const counselor = await prisma.counselors.findUnique({
      where: { id: counselorId },
      select: {
        id: true,
        name: true,
        email: true,
        phone_number: true,
        specialization: true,
        status: true,
        created_at: true,
        updated_at: true
      }
    });

    if (!counselor) {
      return NextResponse.json(
        { error: { message: 'Counselor not found', code: 'COUNSELOR_NOT_FOUND', meta: {} } },
        { status: 404 }
      );
    }

    return NextResponse.json({ counselor });
  } catch (error: any) {
    console.error('Get counselor profile error:', error);
    return NextResponse.json(
      { error: { message: 'Internal server error', code: 'INTERNAL_ERROR', meta: { error: error.message } } },
      { status: 500 }
    );
  }
}

// PATCH /api/counselors/me - Update counselor's own profile
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
    if (!decoded || decoded.user_type !== 'counselor') {
      return NextResponse.json(
        { error: { message: 'Only counselors can access this endpoint', code: 'FORBIDDEN', meta: {} } },
        { status: 403 }
      );
    }

    const counselorId = decoded.user_id;
    if (!counselorId) {
      return NextResponse.json(
        { error: { message: 'Invalid token', code: 'UNAUTHORIZED', meta: {} } },
        { status: 401 }
      );
    }

    const body = await request.json();
    const { name, phone_number, specialization } = body;

    const updateData: any = {};
    if (name) updateData.name = name;
    if (phone_number !== undefined) updateData.phone_number = phone_number;
    if (specialization !== undefined) updateData.specialization = specialization;

    if (Object.keys(updateData).length === 0) {
      return NextResponse.json(
        { error: { message: 'No fields to update', code: 'VALIDATION_ERROR', meta: {} } },
        { status: 400 }
      );
    }

    const counselor = await prisma.counselors.update({
      where: { id: counselorId },
      data: updateData,
      select: {
        id: true,
        name: true,
        email: true,
        phone_number: true,
        specialization: true,
        status: true,
        created_at: true,
        updated_at: true
      }
    });

    return NextResponse.json({ counselor });
  } catch (error: any) {
    console.error('Update counselor profile error:', error);
    if (error.code === 'P2025') {
      return NextResponse.json(
        { error: { message: 'Counselor not found', code: 'COUNSELOR_NOT_FOUND', meta: {} } },
        { status: 404 }
      );
    }
    return NextResponse.json(
      { error: { message: 'Internal server error', code: 'INTERNAL_ERROR', meta: { error: error.message } } },
      { status: 500 }
    );
  }
}
