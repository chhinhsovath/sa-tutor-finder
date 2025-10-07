import { NextRequest, NextResponse } from 'next/server';
import prisma from '@/lib/prisma';

export const dynamic = 'force-dynamic';

// GET /api/support/faq - List FAQ items
export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url);
    const category = searchParams.get('category');

    const whereConditions: any = {
      is_published: true
    };

    if (category) {
      whereConditions.category = category;
    }

    const faqs = await prisma.faq.findMany({
      where: whereConditions,
      orderBy: [
        { category: 'asc' },
        { order: 'asc' }
      ]
    });

    // Increment view count for all returned FAQs
    const faqIds = faqs.map(f => f.id);
    if (faqIds.length > 0) {
      await prisma.faq.updateMany({
        where: { id: { in: faqIds } },
        data: { view_count: { increment: 1 } }
      });
    }

    return NextResponse.json({ faqs, count: faqs.length });
  } catch (error: any) {
    console.error('Get FAQ error:', error);
    return NextResponse.json(
      { error: { message: 'Internal server error', code: 'INTERNAL_ERROR', meta: { error: error.message } } },
      { status: 500 }
    );
  }
}
