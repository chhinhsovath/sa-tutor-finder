import { NextRequest, NextResponse } from 'next/server';
import pool from '@/lib/db';
import { verifyPassword, signToken } from '@/lib/auth';

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const { email, password } = body;

    // Validation
    if (!email || !password) {
      return NextResponse.json(
        {
          error: {
            message: 'Email and password are required',
            code: 'VALIDATION_ERROR',
            meta: { missing_fields: [!email && 'email', !password && 'password'].filter(Boolean) }
          }
        },
        { status: 400 }
      );
    }

    // Find mentor
    const result = await pool.query(
      `SELECT id, name, email, password_hash, english_level, contact, timezone, status, created_at, updated_at
       FROM mentors
       WHERE email = $1`,
      [email]
    );

    if (result.rows.length === 0) {
      return NextResponse.json(
        {
          error: {
            message: 'Invalid email or password',
            code: 'AUTH_INVALID_CREDENTIALS',
            meta: {}
          }
        },
        { status: 401 }
      );
    }

    const mentor = result.rows[0];

    // Verify password
    const isValid = await verifyPassword(password, mentor.password_hash);

    if (!isValid) {
      return NextResponse.json(
        {
          error: {
            message: 'Invalid email or password',
            code: 'AUTH_INVALID_CREDENTIALS',
            meta: {}
          }
        },
        { status: 401 }
      );
    }

    // Generate JWT
    const token = signToken({ mentor_id: mentor.id });

    return NextResponse.json({
      token,
      mentor: {
        id: mentor.id,
        name: mentor.name,
        email: mentor.email,
        english_level: mentor.english_level,
        contact: mentor.contact,
        timezone: mentor.timezone,
        status: mentor.status,
        created_at: mentor.created_at,
        updated_at: mentor.updated_at
      }
    });
  } catch (error: any) {
    console.error('Login error:', error);
    return NextResponse.json(
      {
        error: {
          message: 'Internal server error during login',
          code: 'INTERNAL_ERROR',
          meta: { error: error.message }
        }
      },
      { status: 500 }
    );
  }
}
