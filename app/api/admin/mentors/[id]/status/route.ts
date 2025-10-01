import { NextRequest, NextResponse } from 'next/server';
import pool from '@/lib/db';
import { extractToken, verifyToken } from '@/lib/auth';

export async function PATCH(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    // Verify authentication
    const token = extractToken(request.headers.get('authorization'));
    if (!token) {
      return NextResponse.json(
        {
          error: {
            message: 'No authorization token provided',
            code: 'UNAUTHORIZED',
            meta: {}
          }
        },
        { status: 401 }
      );
    }

    const decoded = verifyToken(token);
    if (!decoded) {
      return NextResponse.json(
        {
          error: {
            message: 'Invalid or expired token',
            code: 'UNAUTHORIZED',
            meta: {}
          }
        },
        { status: 401 }
      );
    }

    // TODO: Add admin role check here when implementing role system
    // For now, any authenticated user can change status

    const { id } = params;
    const body = await request.json();
    const { status } = body;

    if (!status || !['active', 'inactive'].includes(status)) {
      return NextResponse.json(
        {
          error: {
            message: 'Invalid status. Must be "active" or "inactive"',
            code: 'VALIDATION_ERROR',
            meta: { valid_statuses: ['active', 'inactive'], received: status }
          }
        },
        { status: 400 }
      );
    }

    const result = await pool.query(
      `UPDATE mentors
       SET status = $1
       WHERE id = $2
       RETURNING id, name, email, english_level, contact, timezone, status, created_at, updated_at`,
      [status, id]
    );

    if (result.rows.length === 0) {
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

    return NextResponse.json({
      message: 'Mentor status updated successfully',
      mentor: result.rows[0]
    });
  } catch (error: any) {
    console.error('Update mentor status error:', error);
    return NextResponse.json(
      {
        error: {
          message: 'Internal server error while updating mentor status',
          code: 'INTERNAL_ERROR',
          meta: { error: error.message }
        }
      },
      { status: 500 }
    );
  }
}
