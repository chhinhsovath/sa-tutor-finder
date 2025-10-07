import { NextRequest, NextResponse } from 'next/server';
import prisma from '@/lib/prisma';
import { hashPassword, signToken } from '@/lib/auth';

export const dynamic = 'force-dynamic';

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const { name, email, password, user_type, english_level, contact, phone_number, learning_goals, specialization } = body;

    // Validation
    if (!name || !email || !password) {
      return NextResponse.json(
        {
          error: {
            message: 'Name, email, and password are required',
            code: 'VALIDATION_ERROR',
            meta: { missing_fields: ['name', 'email', 'password'].filter(f => !body[f]) }
          }
        },
        { status: 400 }
      );
    }

    // Default to student if user_type not provided
    const accountType = user_type || 'student';

    if (!['mentor', 'student', 'counselor'].includes(accountType)) {
      return NextResponse.json(
        {
          error: {
            message: 'Invalid user_type. Must be one of: mentor, student, counselor',
            code: 'VALIDATION_ERROR',
            meta: { valid_types: ['mentor', 'student', 'counselor'], provided: accountType }
          }
        },
        { status: 400 }
      );
    }

    // Validate english_level for mentor and student
    if ((accountType === 'mentor' || accountType === 'student') && !english_level) {
      return NextResponse.json(
        {
          error: {
            message: `English level is required for ${accountType} accounts`,
            code: 'VALIDATION_ERROR',
            meta: { missing_field: 'english_level' }
          }
        },
        { status: 400 }
      );
    }

    const validLevels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
    if (english_level && !validLevels.includes(english_level)) {
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

    // Check if email exists in any user table
    const [existingMentor, existingStudent, existingCounselor, existingAdmin] = await Promise.all([
      prisma.mentors.findUnique({ where: { email } }),
      prisma.students.findUnique({ where: { email } }),
      prisma.counselors.findUnique({ where: { email } }),
      prisma.admins.findUnique({ where: { email } })
    ]);

    if (existingMentor || existingStudent || existingCounselor || existingAdmin) {
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

    let newUser: any = null;

    // Create user based on type
    switch (accountType) {
      case 'mentor':
        newUser = await prisma.mentors.create({
          data: {
            name,
            email,
            password_hash,
            english_level,
            contact: contact || null
          }
        });
        break;

      case 'student':
        newUser = await prisma.students.create({
          data: {
            name,
            email,
            password_hash,
            english_level: english_level || 'A1',
            phone_number: phone_number || null,
            learning_goals: learning_goals || null
          }
        });
        break;

      case 'counselor':
        newUser = await prisma.counselors.create({
          data: {
            name,
            email,
            password_hash,
            phone_number: phone_number || null,
            specialization: specialization || null
          }
        });
        break;
    }

    // Generate JWT
    const token = signToken({
      user_id: newUser.id,
      user_type: accountType as 'student' | 'mentor' | 'counselor'
    });

    // Remove password_hash from response
    const { password_hash: _, ...userWithoutPassword } = newUser;

    return NextResponse.json(
      {
        token,
        user: {
          ...userWithoutPassword,
          user_type: accountType
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
