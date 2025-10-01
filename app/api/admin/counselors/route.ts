import { NextRequest, NextResponse } from 'next/server';
import pool from '@/lib/db';
import { verifyToken } from '@/lib/auth';

export const dynamic = 'force-dynamic';

// GET /api/admin/counselors - List all counselors (admin only)
export async function GET(request: NextRequest) {
  try {
    const token = request.headers.get('authorization')?.replace('Bearer ', '');
    if (!token) {
      return NextResponse.json(
        { error: { message: 'Authorization token required', code: 'UNAUTHORIZED' } },
        { status: 401 }
      );
    }

    verifyToken(token);
    // TODO: Add admin role check

    const { searchParams } = new URL(request.url);
    const status = searchParams.get('status');
    const search = searchParams.get('search');

    let query = 'SELECT * FROM counselors WHERE 1=1';
    const params: any[] = [];

    if (status) {
      params.push(status);
      query += ` AND status = $${params.length}`;
    }

    if (search) {
      params.push(`%${search}%`);
      query += ` AND (name ILIKE $${params.length} OR email ILIKE $${params.length})`;
    }

    query += ' ORDER BY created_at DESC';

    const result = await pool.query(query, params);

    return NextResponse.json({
      counselors: result.rows,
      count: result.rows.length
    });
  } catch (error: any) {
    console.error('Admin get counselors error:', error);
    return NextResponse.json(
      {
        error: {
          message: 'Internal server error while fetching counselors',
          code: 'INTERNAL_ERROR',
          meta: { error: error.message }
        }
      },
      { status: 500 }
    );
  }
}
