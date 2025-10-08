import { NextRequest, NextResponse } from 'next/server';
import prisma from '@/lib/prisma';
import { isValidCoordinates } from '@/lib/utils/geocoding';

export const dynamic = 'force-dynamic';

/**
 * GET /api/mentors/nearby - Find mentors within specified radius
 * Query parameters:
 *   - latitude (required): Reference point latitude
 *   - longitude (required): Reference point longitude
 *   - radius_km (required): Search radius in kilometers (1-15)
 *   - english_level (optional): Filter by English proficiency
 *   - day (optional): Filter by availability day (1-7)
 *   - from, to (optional): Filter by time range
 */
export async function GET(request: NextRequest) {
  try {
    const { searchParams } = request.url.includes('?')
      ? new URL(request.url)
      : { searchParams: new URLSearchParams() };

    const latitude = parseFloat(searchParams.get('latitude') || '');
    const longitude = parseFloat(searchParams.get('longitude') || '');
    const radiusKm = parseInt(searchParams.get('radius_km') || '');
    const englishLevel = searchParams.get('english_level');
    const day = searchParams.get('day') ? parseInt(searchParams.get('day')!) : null;
    const from = searchParams.get('from');
    const to = searchParams.get('to');

    // Validation
    if (!latitude || !longitude) {
      return NextResponse.json(
        {
          error: {
            message: 'latitude and longitude are required',
            code: 'VALIDATION_ERROR',
          },
        },
        { status: 400 }
      );
    }

    if (!isValidCoordinates(latitude, longitude)) {
      return NextResponse.json(
        {
          error: {
            message: 'Invalid coordinates. Latitude must be -90 to 90, longitude must be -180 to 180',
            code: 'VALIDATION_ERROR',
          },
        },
        { status: 400 }
      );
    }

    if (!radiusKm || radiusKm < 1 || radiusKm > 15) {
      return NextResponse.json(
        {
          error: {
            message: 'radius_km is required and must be between 1 and 15',
            code: 'VALIDATION_ERROR',
          },
        },
        { status: 400 }
      );
    }

    // Build WHERE clause
    const where: any = {
      status: 'active',
      offers_in_person: true,
      latitude: { not: null },
      longitude: { not: null },
    };

    if (englishLevel) {
      where.english_level = englishLevel;
    }

    // Get all potential mentors with coordinates
    const mentors = await prisma.mentors.findMany({
      where,
      select: {
        id: true,
        name: true,
        email: true,
        english_level: true,
        contact: true,
        bio: true,
        hourly_rate: true,
        average_rating: true,
        total_sessions: true,
        address: true,
        latitude: true,
        longitude: true,
        max_travel_distance_km: true,
        created_at: true,
        updated_at: true,
        availability_slots: day
          ? {
              where: { day_of_week: day },
            }
          : true,
      },
    });

    // Calculate distance for each mentor using Haversine formula
    const mentorsWithDistance = mentors
      .map((mentor) => {
        const mentorLat = mentor.latitude ? parseFloat(mentor.latitude.toString()) : null;
        const mentorLon = mentor.longitude ? parseFloat(mentor.longitude.toString()) : null;

        if (!mentorLat || !mentorLon) {
          return null;
        }

        // Haversine formula for distance calculation
        const R = 6371; // Earth's radius in kilometers
        const dLat = toRadians(mentorLat - latitude);
        const dLon = toRadians(mentorLon - longitude);

        const a =
          Math.sin(dLat / 2) * Math.sin(dLat / 2) +
          Math.cos(toRadians(latitude)) *
            Math.cos(toRadians(mentorLat)) *
            Math.sin(dLon / 2) *
            Math.sin(dLon / 2);

        const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        const distance = R * c;

        return {
          ...mentor,
          distance_km: Math.round(distance * 10) / 10, // Round to 1 decimal
        };
      })
      .filter((m): m is NonNullable<typeof m> => m !== null)
      .filter((m) => m.distance_km <= radiusKm); // Filter by radius

    // Filter by time availability if provided
    let filteredMentors = mentorsWithDistance;
    if (day && from && to) {
      filteredMentors = mentorsWithDistance.filter((mentor) => {
        if (!mentor.availability_slots || mentor.availability_slots.length === 0) {
          return false;
        }

        // Check if any slot overlaps with requested time
        return mentor.availability_slots.some((slot) => {
          const slotStart = formatTime(slot.start_time);
          const slotEnd = formatTime(slot.end_time);
          return slotStart < to && slotEnd > from;
        });
      });
    }

    // Sort by distance (closest first)
    filteredMentors.sort((a, b) => a.distance_km - b.distance_km);

    // Remove sensitive fields
    const publicMentors = filteredMentors.map((mentor) => ({
      id: mentor.id,
      name: mentor.name,
      english_level: mentor.english_level,
      contact: mentor.contact,
      bio: mentor.bio,
      hourly_rate: mentor.hourly_rate,
      average_rating: mentor.average_rating,
      total_sessions: mentor.total_sessions,
      address: mentor.address,
      latitude: mentor.latitude,
      longitude: mentor.longitude,
      distance_km: mentor.distance_km,
      availability_slots: mentor.availability_slots,
    }));

    return NextResponse.json(
      {
        mentors: publicMentors,
        count: publicMentors.length,
        search_params: {
          latitude,
          longitude,
          radius_km: radiusKm,
          english_level: englishLevel || null,
          day: day || null,
          time_range: from && to ? { from, to } : null,
        },
      },
      { status: 200 }
    );
  } catch (error: any) {
    console.error('Nearby mentors search error:', error);
    return NextResponse.json(
      {
        error: {
          message: 'Internal server error during nearby search',
          code: 'INTERNAL_ERROR',
          meta: { error: error.message },
        },
      },
      { status: 500 }
    );
  }
}

// Helper function to convert degrees to radians
function toRadians(degrees: number): number {
  return degrees * (Math.PI / 180);
}

// Helper function to format TIME type to HH:MM string
function formatTime(date: Date): string {
  return date.toISOString().split('T')[1].substring(0, 5);
}
