import { NextRequest, NextResponse } from 'next/server';
import pool from '@/lib/db';
import { extractToken, verifyToken } from '@/lib/auth';

export async function GET(request: NextRequest) {
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

    const result = await pool.query(
      `SELECT id, name, email, english_level, contact, timezone, status, created_at, updated_at
       FROM mentors
       WHERE id = $1`,
      [decoded.mentor_id]
    );

    if (result.rows.length === 0) {
      return NextResponse.json(
        {
          error: {
            message: 'Mentor not found',
            code: 'MENTOR_NOT_FOUND',
            meta: {}
          }
        },
        { status: 404 }
      );
    }

    return NextResponse.json({ mentor: result.rows[0] });
  } catch (error: any) {
    console.error('Get mentor profile error:', error);
    return NextResponse.json(
      {
        error: {
          message: 'Internal server error while fetching profile',
          code: 'INTERNAL_ERROR',
          meta: { error: error.message }
        }
      },
      { status: 500 }
    );
  }
}

export async function PATCH(request: NextRequest) {
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

    const body = await request.json();
    const { name, english_level, contact, timezone } = body;

    const updates: string[] = [];
    const params: any[] = [];
    let paramCount = 1;

    if (name) {
      updates.push(`name = $${paramCount++}`);
      params.push(name);
    }

    if (english_level) {
      const validLevels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
      if (!validLevels.includes(english_level)) {
        return NextResponse.json(
          {
            error: {
              message: 'Invalid english_level',
              code: 'VALIDATION_ERROR',
              meta: { valid_levels: validLevels }
            }
          },
          { status: 400 }
        );
      }
      updates.push(`english_level = $${paramCount++}`);
      params.push(english_level);
    }

    if (contact !== undefined) {
      updates.push(`contact = $${paramCount++}`);
      params.push(contact);
    }

    if (timezone) {
      updates.push(`timezone = $${paramCount++}`);
      params.push(timezone);
    }

    if (updates.length === 0) {
      return NextResponse.json(
        {
          error: {
            message: 'No fields to update',
            code: 'VALIDATION_ERROR',
            meta: { allowed_fields: ['name', 'english_level', 'contact', 'timezone'] }
          }
        },
        { status: 400 }
      );
    }

    params.push(decoded.mentor_id);

    const result = await pool.query(
      `UPDATE mentors
       SET ${updates.join(', ')}
       WHERE id = $${paramCount}
       RETURNING id, name, email, english_level, contact, timezone, status, created_at, updated_at`,
      params
    );

    if (result.rows.length === 0) {
      return NextResponse.json(
        {
          error: {
            message: 'Mentor not found',
            code: 'MENTOR_NOT_FOUND',
            meta: {}
          }
        },
        { status: 404 }
      );
    }

    return NextResponse.json(result.rows[0]);
  } catch (error: any) {
    console.error('Update mentor error:', error);
    return NextResponse.json(
      {
        error: {
          message: 'Internal server error while updating profile',
          code: 'INTERNAL_ERROR',
          meta: { error: error.message }
        }
      },
      { status: 500 }
    );
  }
}
