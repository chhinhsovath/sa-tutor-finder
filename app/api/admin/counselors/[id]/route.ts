import { NextRequest, NextResponse } from 'next/server';
import prisma from '@/lib/prisma';
import { extractToken, verifyToken } from '@/lib/auth';

export const dynamic = 'force-dynamic';

// PATCH /api/admin/counselors/[id] - Update counselor
export async function PATCH(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const token = extractToken(request.headers.get('authorization'));
    if (!token) {
      return NextResponse.json(
        { error: { message: 'No authorization token provided', code: 'UNAUTHORIZED', meta: {} } },
        { status: 401 }
      );
    }

    const decoded = verifyToken(token);
    if (!decoded || decoded.user_type !== 'admin') {
      return NextResponse.json(
        { error: { message: 'Admin access required', code: 'FORBIDDEN', meta: {} } },
        { status: 403 }
      );
    }

    const body = await request.json();
    const { name, phone_number, specialization, status } = body;

    const updateData: any = {};
    if (name) updateData.name = name;
    if (phone_number !== undefined) updateData.phone_number = phone_number;
    if (specialization !== undefined) updateData.specialization = specialization;
    if (status) updateData.status = status;

    if (Object.keys(updateData).length === 0) {
      return NextResponse.json(
        { error: { message: 'No fields to update', code: 'VALIDATION_ERROR', meta: {} } },
        { status: 400 }
      );
    }

    const counselor = await prisma.counselors.update({
      where: { id: params.id },
      data: updateData,
      select: {
        id: true,
        name: true,
        email: true,
        phone_number: true,
        specialization: true,
        status: true,
        created_at: true
      }
    });

    return NextResponse.json({ counselor });
  } catch (error: any) {
    console.error('Update counselor error:', error);
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

// DELETE /api/admin/counselors/[id] - Delete counselor
export async function DELETE(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const token = extractToken(request.headers.get('authorization'));
    if (!token) {
      return NextResponse.json(
        { error: { message: 'No authorization token provided', code: 'UNAUTHORIZED', meta: {} } },
        { status: 401 }
      );
    }

    const decoded = verifyToken(token);
    if (!decoded || decoded.user_type !== 'admin') {
      return NextResponse.json(
        { error: { message: 'Admin access required', code: 'FORBIDDEN', meta: {} } },
        { status: 403 }
      );
    }

    await prisma.counselors.delete({
      where: { id: params.id }
    });

    return NextResponse.json({ message: 'Counselor deleted successfully' });
  } catch (error: any) {
    console.error('Delete counselor error:', error);
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
