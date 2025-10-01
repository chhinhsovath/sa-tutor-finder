# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**SA Tutor Finder** - A tutor/mentor discovery platform where mentors register with availability and English proficiency, and learners can filter mentors by schedule and language level.

**Tech Stack:**
- **Frontend**: Flutter mobile app (calls REST API)
- **Backend**: Next.js 14 App Router with API routes (deployed on Vercel)
- **Database**: PostgreSQL (hosted at 157.10.73.52)
- **Auth**: JWT-based authentication with bcrypt password hashing

## Critical Naming Convention

**⚠️ ALWAYS USE snake_case FOR ALL DATABASE FIELDS AND API RESPONSES**

This project follows strict snake_case convention across all layers:
- Database columns: `mentor_id`, `english_level`, `created_at`, `day_of_week`
- API responses: Return snake_case JSON (no camelCase transformation)
- Flutter models: Expect snake_case in JSON parsing

**Common fields:**
- Primary keys: `id` (UUID)
- Foreign keys: `mentor_id` (not `mentorId`)
- Timestamps: `created_at`, `updated_at` (not `createdAt`, `updatedAt`)
- Enums: `english_level`, `day_of_week`, `start_time`, `end_time`

## Database Schema

**Connection Details:**
- Host: `157.10.73.52`
- Port: `5432`
- Database: `sa_tutor_finder`
- User: `admin`
- Password: `P@ssw0rd`
- Connection string: `postgresql://admin:P@ssw0rd@157.10.73.52:5432/sa_tutor_finder`

**Tables:**
1. **mentors** - Core mentor profiles
   - `id` (UUID PK), `name`, `email` (unique), `password_hash`
   - `english_level` (enum: A1, A2, B1, B2, C1, C2)
   - `contact`, `timezone` (default: 'Asia/Phnom_Penh')
   - `status` (enum: active, inactive)
   - `created_at`, `updated_at`

2. **availability_slots** - Weekly availability schedule
   - `id` (UUID PK), `mentor_id` (FK → mentors.id, CASCADE DELETE)
   - `day_of_week` (int: 1=Monday ... 7=Sunday)
   - `start_time`, `end_time` (PostgreSQL TIME type)

**Key relationships:**
- One mentor has many availability_slots
- Deleting a mentor cascades to their slots

**Test Data:**
- Seeded with 10 mentors across all English levels (A2-C2)
- 22 availability slots with varied schedules
- Test password for all accounts: `password123`
- Bcrypt hash: `$2b$10$VD7v1hJ3.WKZbNFZBe5vS.y21U3VZPhhzUHp7v0Cpkod0qF.QTt3G`

**Database Setup Commands:**
```bash
# Connect to database
PGPASSWORD='P@ssw0rd' psql -h 157.10.73.52 -U admin -d sa_tutor_finder

# Initialize schema (creates tables, indexes, triggers)
PGPASSWORD='P@ssw0rd' psql -h 157.10.73.52 -U admin -d sa_tutor_finder -f scripts/init-db.sql

# Seed test data
PGPASSWORD='P@ssw0rd' psql -h 157.10.73.52 -U admin -d sa_tutor_finder -f scripts/seed-data.sql

# Verify data
PGPASSWORD='P@ssw0rd' psql -h 157.10.73.52 -U admin -d sa_tutor_finder -c "SELECT name, email, english_level, status FROM mentors ORDER BY name;"
```

**⚠️ Important: TIME Type Casting**
PostgreSQL requires explicit type casting for TIME literals:
```sql
-- ❌ Wrong (will fail)
INSERT INTO availability_slots (start_time, end_time) VALUES ('09:00', '12:00');

-- ✅ Correct
INSERT INTO availability_slots (start_time, end_time) VALUES ('09:00'::TIME, '12:00'::TIME);
```

## API Routes Structure

All routes under `app/api/`:

**Authentication:**
- `POST /api/auth/signup` - Create mentor account
- `POST /api/auth/login` - Login with email/password, return JWT

**Public Mentor Discovery:**
- `GET /api/mentors` - List active mentors with filters:
  - `?day=1` (1-7 for Mon-Sun)
  - `&from=18:00&to=20:00` (time range overlap)
  - `&level=B1` (English level filter)
- `GET /api/mentors/[id]` - Get mentor detail

**Authenticated Mentor Operations:**
- `PATCH /api/mentors/me` - Update own profile (requires JWT)
- `GET /api/mentors/me/availability` - List own availability slots
- `POST /api/mentors/me/availability` - Replace all weekly slots (atomic operation)

**Admin Operations:**
- `PATCH /api/admin/mentors/[id]/status` - Set mentor active/inactive

## Search/Filter Logic

**Time slot overlap query:**
```sql
SELECT DISTINCT m.*
FROM mentors m
JOIN availability_slots s ON m.id = s.mentor_id
WHERE s.day_of_week = $day
  AND s.start_time < $to
  AND s.end_time > $from
  AND (m.english_level = $level OR $level IS NULL)
  AND m.status = 'active'
```

**Key logic:**
- `start_time < search_end AND end_time > search_start` = time overlap
- Optional level filter (pass NULL to skip)
- Only show active mentors

## Development Environment

**Database Connection:**
- Host: 157.10.73.52:5432
- Database: `sa_tutor_finder`
- Credentials in `.env.local` (see `/prd/.env.me` for reference)

**Production API URL:**
- Deployed at: `https://tutor.openplp.com/api` (or Vercel deployment URL)
- Flutter app should point to production URL by default

**Project Structure:**
- All files created directly in root folder (no nested project folders)
- Next.js app in root with `app/` directory
- Flutter app in root with standard Flutter structure

## Flutter Development

**Completed Screens (24 total):**

*Authentication:*
- login_screen.dart
- mentor_registration_screen.dart

*Mentor Screens:*
- mentor_search_screen.dart - Main search/filter interface
- mentor_detail_screen.dart - Detailed mentor profile
- mentor_dashboard_screen.dart - Mentor's main dashboard
- availability_management_screen.dart - Weekly schedule editor
- mentor_profile_edit_screen.dart - Edit mentor profile
- availability_setting_screen.dart - Quick toggle availability
- mentor_reviews_screen.dart - Display mentor reviews/ratings
- session_feedback_screen.dart - Mentor provides session feedback

*Student Screens:*
- student_dashboard_screen.dart - Student's main dashboard
- session_booking_screen.dart - Book sessions with calendar (uses table_calendar)
- messaging_screen.dart - 1-on-1 messaging with mentor
- notification_settings_screen.dart - Configure notification preferences
- help_support_screen.dart - FAQ and support contact
- rate_mentor_screen.dart - Rate mentor after session (1-5 stars)
- student_progress_reports_screen.dart - View student progress

*Guidance Counselor:*
- guidance_counselor_dashboard_screen.dart - Counselor dashboard

*Admin Screens:*
- admin_mentor_management_screen.dart - Search/filter mentors
- admin_student_management_screen.dart - Manage students
- admin_counselor_management_screen.dart - Manage counselors
- admin_financial_reporting_screen.dart - Revenue and transactions
- admin_analytics_screen.dart - Platform statistics

**Theme Configuration:**
- Primary Color: `#1193D4` (blue)
- Uses Material Design 3
- State management: Provider pattern
- Navigation: Named routes with arguments

**HTTP Client:**
- Package: `dio`
- Base URL: `https://apitutor.openplp.com` (production API)
- Auth: JWT stored in secure storage (flutter_secure_storage)

**Dependencies:**
```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.2
  dio: ^5.7.0
  flutter_secure_storage: ^9.2.2
  table_calendar: ^3.1.2  # For session booking calendar
```

**Flutter Commands:**
```bash
flutter pub get              # Install dependencies
flutter run                  # Run on connected device/emulator
flutter build apk            # Build Android APK
flutter build ios            # Build iOS (requires macOS)
```

**API Response Format:**
All responses use snake_case. Example mentor object:
```json
{
  "id": "uuid",
  "name": "John Doe",
  "email": "john@example.com",
  "english_level": "B2",
  "contact": "telegram.me/johndoe",
  "timezone": "Asia/Phnom_Penh",
  "status": "active",
  "created_at": "2025-10-01T12:00:00Z",
  "updated_at": "2025-10-01T12:00:00Z"
}
```

## Key Design Decisions

1. **Availability is weekly recurring** - No specific dates, only day-of-week + time ranges
2. **Atomic slot replacement** - POST to `/api/mentors/me/availability` replaces all slots (delete old, insert new in transaction)
3. **Timezone stored but not enforced** - Times stored as-is; client handles timezone conversion
4. **Status flag for soft disable** - Admins set `status='inactive'` instead of deleting mentors
5. **UUID primary keys** - Use `uuid-ossp` extension for PostgreSQL

## Common Commands

**Next.js development:**
```bash
npm install                  # Install dependencies (use --legacy-peer-deps if needed)
npm run dev                  # Start dev server (default port 3000)
npm run build                # Production build
npm run start                # Start production server (port 3000)
```

**Testing API Endpoints:**
```bash
# List all active mentors
curl http://localhost:3000/api/mentors

# Filter by English level
curl "http://localhost:3000/api/mentors?level=C1"

# Filter by day and time
curl "http://localhost:3000/api/mentors?day=1&from=09:00&to=12:00"

# Login
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"sarah.johnson@example.com","password":"password123"}'

# Get mentor's own availability (requires JWT)
curl http://localhost:3000/api/mentors/me/availability \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Deployment:**
- Push to GitHub → Vercel auto-deploys
- Production URL: `https://apitutor.openplp.com`
- Environment variables in Vercel:
  - `DATABASE_URL`
  - `JWT_SECRET`
  - `NEXT_PUBLIC_API_URL`

## Authentication Flow

1. **Signup**: POST `/api/auth/signup` with `{ name, email, password, english_level, contact }`
   - Hash password with bcrypt (salt rounds: 10)
   - Return JWT token
2. **Login**: POST `/api/auth/login` with `{ email, password }`
   - Verify bcrypt hash
   - Return JWT token
3. **Protected routes**: Verify JWT in middleware or route handler
   - Extract mentor ID from JWT payload
   - Use for `mentors/me/*` operations

## Error Handling Standard

**⚠️ ALWAYS return detailed error responses:**
```json
{
  "error": {
    "message": "Detailed human-readable error",
    "code": "ERROR_CODE",
    "meta": { "field": "additional context" }
  }
}
```

**Common error codes:**
- `AUTH_INVALID_CREDENTIALS` - Login failed
- `AUTH_EMAIL_EXISTS` - Signup with existing email
- `VALIDATION_ERROR` - Invalid input
- `MENTOR_NOT_FOUND` - ID doesn't exist
- `UNAUTHORIZED` - Missing/invalid JWT
- `FORBIDDEN` - Valid JWT but insufficient permissions

## Known Issues and Solutions

### 1. Tailwind CSS v4 PostCSS Plugin Error

**Error:** `It looks like you're trying to use 'tailwindcss' directly as a PostCSS plugin...`

**Solution:**
```bash
npm install @tailwindcss/postcss --legacy-peer-deps
```

Update `postcss.config.js`:
```javascript
module.exports = {
  plugins: {
    '@tailwindcss/postcss': {},
  },
}
```

### 2. Next.js Dynamic Route Warning

**Error:** Build warning about dynamic server usage on API routes

**Solution:** Add to all API route files:
```typescript
export const dynamic = 'force-dynamic';

export async function GET(request: NextRequest) {
  // ... route handler
}
```

### 3. PostgreSQL TIME Type Errors

**Error:** `column "start_time" is of type time without time zone but expression is of type text`

**Solution:** Always cast time literals with `::TIME`:
```sql
INSERT INTO availability_slots (start_time, end_time)
VALUES ('09:00'::TIME, '12:00'::TIME);
```

### 4. Bcrypt Hash Generation for Test Data

When seeding test data, generate proper bcrypt hashes:

**Generate hash:**
```javascript
// scripts/generate-hash.js
const bcrypt = require('bcryptjs');

async function generateHash() {
  const password = 'password123';
  const hash = await bcrypt.hash(password, 10);
  console.log('Password:', password);
  console.log('Bcrypt hash:', hash);
}

generateHash();
```

**Run:**
```bash
node scripts/generate-hash.js
```

### 5. Port Already in Use

**Error:** `EADDRINUSE: address already in use :::3000`

**Solution:**
```bash
# Find and kill process on port 3000
lsof -ti:3000 | xargs kill -9

# Or use different port
PORT=3001 npm run dev
```

## Environment Variables

**`.env.local` (local development):**
```env
DATABASE_URL=postgresql://admin:P@ssw0rd@157.10.73.52:5432/sa_tutor_finder
JWT_SECRET=7ac3701d2f5a7ebe1044f4c64b31f28c6d7c0a97d5509a79d872cc48b7b596ad5d303beb6a3b930ccbac6b1b67a67bcf83c487dc23a510114134fb93add22848
NEXT_PUBLIC_API_URL=https://apitutor.openplp.com
```

**JWT_SECRET generation:**
```bash
node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"
```
