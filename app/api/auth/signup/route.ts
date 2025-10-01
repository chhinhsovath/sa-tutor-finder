import { NextRequest, NextResponse } from 'next/server';
import pool from '@/lib/db';
import { hashPassword, signToken } from '@/lib/auth';

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const { name, email, password, english_level, contact } = body;

    // Validation
    if (!name || !email || !password || !english_level) {
      return NextResponse.json(
        {
          error: {
            message: 'Name, email, password, and english_level are required',
            code: 'VALIDATION_ERROR',
            meta: { missing_fields: ['name', 'email', 'password', 'english_level'].filter(f => !body[f]) }
          }
        },
        { status: 400 }
      );
    }

    const validLevels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
    if (!validLevels.includes(english_level)) {
      return NextResponse.json(
        {
          error: {
            message: 'Invalid english_level. Must be one of: A1, A2, B1, B2, C1, C2',
            code: 'VALIDATION_ERROR',
            meta: { valid_levels: validLevels, provided: english_level }
          }
        },
        { status: 400 }
      );
    }

    if (password.length < 6) {
      return NextResponse.json(
        {
          error: {
            message: 'Password must be at least 6 characters',
            code: 'VALIDATION_ERROR',
            meta: { min_length: 6 }
          }
        },
        { status: 400 }
      );
    }

    // Check if email exists
    const existingUser = await pool.query(
      'SELECT id FROM mentors WHERE email = $1',
      [email]
    );

    if (existingUser.rows.length > 0) {
      return NextResponse.json(
        {
          error: {
            message: 'Email already exists',
            code: 'AUTH_EMAIL_EXISTS',
            meta: { email }
          }
        },
        { status: 409 }
      );
    }

    // Hash password
    const password_hash = await hashPassword(password);

    // Insert mentor
    const result = await pool.query(
      `INSERT INTO mentors (name, email, password_hash, english_level, contact)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING id, name, email, english_level, contact, timezone, status, created_at, updated_at`,
      [name, email, password_hash, english_level, contact || null]
    );

    const mentor = result.rows[0];

    // Generate JWT
    const token = signToken({ mentor_id: mentor.id });

    return NextResponse.json(
      {
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
      },
      { status: 201 }
    );
  } catch (error: any) {
    console.error('Signup error:', error);
    return NextResponse.json(
      {
        error: {
          message: 'Internal server error during signup',
          code: 'INTERNAL_ERROR',
          meta: { error: error.message }
        }
      },
      { status: 500 }
    );
  }
}
