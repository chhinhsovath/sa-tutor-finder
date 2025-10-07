import { NextRequest, NextResponse } from 'next/server';
import prisma from '@/lib/prisma';
import { verifyPassword, signToken } from '@/lib/auth';

export const dynamic = 'force-dynamic';

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const { email, password, user_type } = body;

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

    let user: any = null;
    let userRole: string = '';

    // If user_type is specified, only search that table
    if (user_type) {
      switch (user_type) {
        case 'mentor':
          user = await prisma.mentors.findUnique({ where: { email } });
          userRole = 'mentor';
          break;
        case 'student':
          user = await prisma.students.findUnique({ where: { email } });
          userRole = 'student';
          break;
        case 'counselor':
          user = await prisma.counselors.findUnique({ where: { email } });
          userRole = 'counselor';
          break;
        case 'admin':
          user = await prisma.admins.findUnique({ where: { email } });
          userRole = 'admin';
          break;
        default:
          return NextResponse.json(
            {
              error: {
                message: 'Invalid user type',
                code: 'VALIDATION_ERROR',
                meta: { valid_types: ['mentor', 'student', 'counselor', 'admin'] }
              }
            },
            { status: 400 }
          );
      }
    } else {
      // Search all user tables
      const [mentor, student, counselor, admin] = await Promise.all([
        prisma.mentors.findUnique({ where: { email } }),
        prisma.students.findUnique({ where: { email } }),
        prisma.counselors.findUnique({ where: { email } }),
        prisma.admins.findUnique({ where: { email } })
      ]);

      if (mentor) {
        user = mentor;
        userRole = 'mentor';
      } else if (student) {
        user = student;
        userRole = 'student';
      } else if (counselor) {
        user = counselor;
        userRole = 'counselor';
      } else if (admin) {
        user = admin;
        userRole = 'admin';
      }
    }

    if (!user) {
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

    // Verify password
    const isValid = await verifyPassword(password, user.password_hash);

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

    // Check if user is active (not suspended/inactive)
    if (user.status && user.status !== 'active') {
      return NextResponse.json(
        {
          error: {
            message: 'Account is not active',
            code: 'AUTH_ACCOUNT_INACTIVE',
            meta: { status: user.status }
          }
        },
        { status: 403 }
      );
    }

    // Generate JWT with user_id and user_type
    const token = signToken({
      user_id: user.id,
      user_type: userRole as 'student' | 'mentor' | 'counselor' | 'admin'
    });

    // Remove password_hash from response
    const { password_hash, ...userWithoutPassword } = user;

    return NextResponse.json({
      token,
      user: {
        ...userWithoutPassword,
        user_type: userRole
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
