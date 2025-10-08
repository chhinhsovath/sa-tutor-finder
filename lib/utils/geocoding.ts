/**
 * Geocoding utility for converting addresses to latitude/longitude coordinates
 * Uses OpenStreetMap Nominatim API (free, no API key required)
 * For production, consider upgrading to Google Geocoding API for better accuracy
 */

export interface GeocodingResult {
  latitude: number;
  longitude: number;
  display_name: string;
  address?: {
    city?: string;
    country?: string;
    postcode?: string;
  };
}

export interface ReverseGeocodingResult {
  display_name: string;
  address: {
    road?: string;
    suburb?: string;
    city?: string;
    country?: string;
    postcode?: string;
  };
}

/**
 * Convert address string to latitude/longitude coordinates
 * @param address Full address string (e.g., "123 Main St, Phnom Penh, Cambodia")
 * @returns GeocodingResult with coordinates
 */
export async function geocodeAddress(address: string): Promise<GeocodingResult | null> {
  if (!address || address.trim().length === 0) {
    throw new Error('Address is required');
  }

  try {
    const encodedAddress = encodeURIComponent(address);
    const url = `https://nominatim.openstreetmap.org/search?q=${encodedAddress}&format=json&limit=1&addressdetails=1`;

    const response = await fetch(url, {
      headers: {
        'User-Agent': 'SA-Tutor-Finder/1.0', // Required by Nominatim
      },
    });

    if (!response.ok) {
      throw new Error(`Geocoding API error: ${response.statusText}`);
    }

    const data = await response.json();

    if (!data || data.length === 0) {
      return null; // Address not found
    }

    const result = data[0];
    return {
      latitude: parseFloat(result.lat),
      longitude: parseFloat(result.lon),
      display_name: result.display_name,
      address: result.address,
    };
  } catch (error) {
    console.error('Geocoding error:', error);
    throw new Error(`Failed to geocode address: ${error instanceof Error ? error.message : 'Unknown error'}`);
  }
}

/**
 * Convert latitude/longitude to human-readable address
 * @param latitude Latitude coordinate
 * @param longitude Longitude coordinate
 * @returns ReverseGeocodingResult with address components
 */
export async function reverseGeocode(
  latitude: number,
  longitude: number
): Promise<ReverseGeocodingResult | null> {
  if (!latitude || !longitude) {
    throw new Error('Latitude and longitude are required');
  }

  try {
    const url = `https://nominatim.openstreetmap.org/reverse?lat=${latitude}&lon=${longitude}&format=json&addressdetails=1`;

    const response = await fetch(url, {
      headers: {
        'User-Agent': 'SA-Tutor-Finder/1.0',
      },
    });

    if (!response.ok) {
      throw new Error(`Reverse geocoding API error: ${response.statusText}`);
    }

    const data = await response.json();

    if (!data || data.error) {
      return null;
    }

    return {
      display_name: data.display_name,
      address: data.address,
    };
  } catch (error) {
    console.error('Reverse geocoding error:', error);
    throw new Error(`Failed to reverse geocode: ${error instanceof Error ? error.message : 'Unknown error'}`);
  }
}

/**
 * Calculate distance between two coordinates using Haversine formula
 * @param lat1 Latitude of point 1
 * @param lon1 Longitude of point 1
 * @param lat2 Latitude of point 2
 * @param lon2 Longitude of point 2
 * @returns Distance in kilometers
 */
export function calculateDistance(
  lat1: number,
  lon1: number,
  lat2: number,
  lon2: number
): number {
  const R = 6371; // Earth's radius in kilometers
  const dLat = toRadians(lat2 - lat1);
  const dLon = toRadians(lon2 - lon1);

  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(toRadians(lat1)) *
      Math.cos(toRadians(lat2)) *
      Math.sin(dLon / 2) *
      Math.sin(dLon / 2);

  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  const distance = R * c;

  return Math.round(distance * 10) / 10; // Round to 1 decimal place
}

function toRadians(degrees: number): number {
  return degrees * (Math.PI / 180);
}

/**
 * Validate if coordinates are within valid ranges
 * @param latitude Latitude coordinate
 * @param longitude Longitude coordinate
 * @returns true if valid
 */
export function isValidCoordinates(latitude: number, longitude: number): boolean {
  return (
    typeof latitude === 'number' &&
    typeof longitude === 'number' &&
    latitude >= -90 &&
    latitude <= 90 &&
    longitude >= -180 &&
    longitude <= 180 &&
    !isNaN(latitude) &&
    !isNaN(longitude)
  );
}
