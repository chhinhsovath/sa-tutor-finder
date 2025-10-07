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

**⚠️ PRODUCTION DATABASE - Prisma Cloud (REQUIRED):**
- **Direct Connection:** `postgres://b0139eef4d39aaaae79aafcbd0231526b051c33b651c81e3c223904bb24086e7:sk_HUFSD9xQzdHrBqSOBYfzc@db.prisma.io:5432/postgres?sslmode=require`
- **Prisma Accelerate (runtime):** `prisma+postgres://accelerate.prisma-data.net/?api_key=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`
- **Database Tool:** Prisma ORM (configured in `prisma/schema.prisma`)
- **Client Import:** `import prisma from '@/lib/prisma'`

**Legacy/Old Database (deprecated):**
- Host: `157.10.73.52:5432`, Database: `sa_tutor_finder`, User: `admin`
- Connection string: `postgresql://admin:P@ssw0rd@157.10.73.52:5432/sa_tutor_finder`
- ⚠️ Do NOT use this connection for new code - use Prisma Cloud above

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

**Prisma Setup Commands:**
```bash
# Generate Prisma Client (after schema changes)
npx prisma generate

# Push schema to database (for development - no migrations)
npx prisma db push

# Create and apply migrations (for production)
npx prisma migrate dev --name init

# Open Prisma Studio to view/edit data
npx prisma studio

# Seed database (if seed script exists in prisma/seed.ts)
npx prisma db seed
```

**⚠️ Legacy Database Setup (deprecated - for reference only):**
```bash
# Connect to old database
PGPASSWORD='P@ssw0rd' psql -h 157.10.73.52 -U admin -d sa_tutor_finder

# Initialize schema (creates tables, indexes, triggers)
PGPASSWORD='P@ssw0rd' psql -h 157.10.73.52 -U admin -d sa_tutor_finder -f scripts/init-db.sql

# Seed test data
PGPASSWORD='P@ssw0rd' psql -h 157.10.73.52 -U admin -d sa_tutor_finder -f scripts/seed-data.sql
```

**⚠️ Important: TIME Type Handling with Prisma**
Prisma handles TIME type automatically - use JavaScript Date objects:
```typescript
// ✅ Correct - Prisma converts Date to TIME automatically
await prisma.availability_slots.create({
  data: {
    mentor_id: mentorId,
    day_of_week: 1,
    start_time: new Date('1970-01-01T09:00:00'), // Only time part is stored
    end_time: new Date('1970-01-01T12:00:00')
  }
});

// For raw SQL queries (if needed), cast with ::TIME:
await prisma.$queryRaw`INSERT INTO availability_slots (start_time, end_time)
VALUES ('09:00'::TIME, '12:00'::TIME)`;
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
- **Use Prisma ORM** - Import from `@/lib/prisma`
- Connection configured in `.env` and `.env.local`
- See "Database Schema" section above for connection strings

**Production API URL:**
- Deployed at: `https://apitutor.openplp.com`
- Flutter app points to production URL (see `lib/config/api_config.dart`)

**Project Structure:**
```
sa-tutor-finder/
├── app/                    # Next.js 14 App Router
│   ├── api/               # API routes (REST endpoints)
│   ├── layout.tsx         # Root layout
│   └── page.tsx           # Home page
├── lib/                   # Backend utilities
│   ├── prisma.ts         # Prisma client singleton (USE THIS)
│   ├── db.ts             # Legacy pg Pool (deprecated)
│   └── auth.ts           # JWT utilities (bcrypt, signToken, verifyToken)
├── lib/ (Flutter)         # Flutter mobile app
│   ├── config/           # API config, theme
│   ├── models/           # Data models
│   ├── providers/        # State management (Provider pattern)
│   ├── screens/          # UI screens (24 total)
│   ├── services/         # API service layer
│   └── main.dart         # Flutter entry point
├── prisma/
│   └── schema.prisma     # Database schema (source of truth)
├── scripts/              # Legacy database scripts (deprecated)
└── public/               # Static assets
```

**Key Architectural Decisions:**
1. **Dual ORM approach:** Prisma is now primary (some routes still use `pg` - needs migration)
2. **Monorepo structure:** Next.js backend + Flutter mobile in same repo
3. **API-first design:** Flutter app is pure REST API consumer
4. **JWT authentication:** Stored in flutter_secure_storage on mobile

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

## Using Prisma in API Routes

**Import Prisma Client:**
```typescript
import prisma from '@/lib/prisma';
```

**Common Patterns:**

```typescript
// Find all active mentors with availability slots
const mentors = await prisma.mentors.findMany({
  where: { status: 'active' },
  include: { availability_slots: true }
});

// Find mentor by ID
const mentor = await prisma.mentors.findUnique({
  where: { id: mentorId },
  include: { availability_slots: true }
});

// Create mentor (signup)
const newMentor = await prisma.mentors.create({
  data: {
    name: 'John Doe',
    email: 'john@example.com',
    password_hash: hashedPassword,
    english_level: 'B2',
    contact: 'telegram.me/johndoe',
  }
});

// Update mentor profile
const updated = await prisma.mentors.update({
  where: { id: mentorId },
  data: {
    name: 'New Name',
    english_level: 'C1'
  }
});

// Atomic slot replacement (transaction)
await prisma.$transaction([
  prisma.availability_slots.deleteMany({
    where: { mentor_id: mentorId }
  }),
  prisma.availability_slots.createMany({
    data: slots.map(s => ({
      mentor_id: mentorId,
      day_of_week: s.day,
      start_time: new Date(`1970-01-01T${s.start}:00`),
      end_time: new Date(`1970-01-01T${s.end}:00`)
    }))
  })
]);

// Filter by availability (time overlap)
const available = await prisma.mentors.findMany({
  where: {
    status: 'active',
    english_level: 'B2',
    availability_slots: {
      some: {
        day_of_week: 1,
        start_time: { lt: new Date('1970-01-01T20:00:00') },
        end_time: { gt: new Date('1970-01-01T18:00:00') }
      }
    }
  },
  include: { availability_slots: true }
});
```

**Migration Status:**
- ⚠️ Current state: Mix of `pg` Pool and Prisma
- 🎯 Goal: Migrate all API routes to use Prisma
- 📍 Routes still using `pg`: auth/login, auth/signup, mentors, mentors/[id], mentors/me/availability
- 📍 Routes to migrate: See `app/api/**/route.ts` files

## Key Design Decisions

1. **Availability is weekly recurring** - No specific dates, only day-of-week + time ranges
2. **Atomic slot replacement** - POST to `/api/mentors/me/availability` replaces all slots (delete old, insert new in transaction)
3. **Timezone stored but not enforced** - Times stored as-is; client handles timezone conversion
4. **Status flag for soft disable** - Admins set `status='inactive'` instead of deleting mentors
5. **UUID primary keys** - Use `gen_random_uuid()` function (built into PostgreSQL)
6. **Prisma as primary ORM** - Legacy `pg` Pool code is being phased out

## Common Commands

**Next.js development:**
```bash
npm install                  # Install dependencies (use --legacy-peer-deps if needed)
npm run dev                  # Start dev server (default port 3000)
npm run build                # Production build
npm run start                # Start production server (port 3000)
```

**Prisma commands:**
```bash
npx prisma generate          # Generate Prisma Client (run after schema changes)
npx prisma db push           # Push schema changes to database (development)
npx prisma migrate dev       # Create and apply migrations (production-ready)
npx prisma studio            # Open database GUI (localhost:5555)
npx prisma format            # Format schema.prisma file
npx prisma validate          # Validate schema syntax
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

**Required files:**
1. `.env` - Used by Prisma CLI (migrations, generate, push)
2. `.env.local` - Used by Next.js runtime (development and production)

**`.env` (Prisma CLI only):**
```env
DATABASE_URL="postgres://b0139eef4d39aaaae79aafcbd0231526b051c33b651c81e3c223904bb24086e7:sk_HUFSD9xQzdHrBqSOBYfzc@db.prisma.io:5432/postgres?sslmode=require"
```

**`.env.local` (Next.js runtime):**
```env
# Prisma Direct Connection (for migrations and schema management)
DATABASE_URL="postgres://b0139eef4d39aaaae79aafcbd0231526b051c33b651c81e3c223904bb24086e7:sk_HUFSD9xQzdHrBqSOBYfzc@db.prisma.io:5432/postgres?sslmode=require"

# Prisma Accelerate (optional - for production runtime optimization)
PRISMA_ACCELERATE_URL="prisma+postgres://accelerate.prisma-data.net/?api_key=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJqd3RfaWQiOjEsInNlY3VyZV9rZXkiOiJza19IVUZTRDl4UXpkSHJCcVNPQllmemMiLCJhcGlfa2V5IjoiMDFLNllNNE5CRjNFWldTUkpaWVRTU0tIQVgiLCJ0ZW5hbnRfaWQiOiJiMDEzOWVlZjRkMzlhYWFhZTc5YWFmY2JkMDIzMTUyNmIwNTFjMzNiNjUxYzgxZTNjMjIzOTA0YmIyNDA4NmU3IiwiaW50ZXJuYWxfc2VjcmV0IjoiNWY2ZGRlOGYtNWE2Yy00NWU3LWJhZTUtNjVkNjZlYWJiZDg1In0.k74tOygmMFOHr-pLdv5uo05n2rJGbowk-q-RLBOrBjg"

JWT_SECRET=7ac3701d2f5a7ebe1044f4c64b31f28c6d7c0a97d5509a79d872cc48b7b596ad5d303beb6a3b930ccbac6b1b67a67bcf83c487dc23a510114134fb93add22848
NEXT_PUBLIC_API_URL=https://apitutor.openplp.com/api
```

**Vercel Deployment Environment Variables:**
Set these in Vercel dashboard for production:
- `DATABASE_URL` - Prisma Cloud direct connection URL
- `JWT_SECRET` - Use the same secret as local
- `NEXT_PUBLIC_API_URL` - Production API URL

**JWT_SECRET generation:**
```bash
node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"
```