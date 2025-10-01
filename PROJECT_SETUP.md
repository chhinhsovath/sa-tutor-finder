# SA Tutor Finder - Complete Project Setup

## Project Overview

A full-stack tutor/mentor discovery platform with:
- **Backend**: Next.js 14 with TypeScript, PostgreSQL database
- **Frontend**: Flutter mobile app with modern UI/UX
- **Authentication**: JWT-based with bcrypt password hashing
- **API**: RESTful endpoints for mentor management and discovery

## Tech Stack

### Backend (Next.js 14)
- **Framework**: Next.js 14 App Router
- **Language**: TypeScript
- **Database**: PostgreSQL
- **Auth**: JWT + bcrypt
- **Deployment**: Vercel-ready

### Frontend (Flutter)
- **Framework**: Flutter (mobile-first)
- **State Management**: Provider
- **HTTP Client**: Dio
- **Secure Storage**: flutter_secure_storage
- **UI**: Custom theme matching HTML designs

## Database Setup

### 1. Connect to PostgreSQL

```bash
# Production database
PGPASSWORD='P@ssw0rd' psql -h 157.10.73.52 -U admin -d sa_tutor_finder
```

**Database Credentials:**
- Host: `157.10.73.52`
- Port: `5432` (default)
- Database: `sa_tutor_finder`
- Username: `admin`
- Password: `P@ssw0rd`

### 2. Run Database Migration

**Initial setup (creates tables and schema):**
```bash
PGPASSWORD='P@ssw0rd' psql -h 157.10.73.52 -U admin -d sa_tutor_finder -f scripts/init-db.sql
```

**Seed test data (10 mentors with availability):**
```bash
PGPASSWORD='P@ssw0rd' psql -h 157.10.73.52 -U admin -d sa_tutor_finder -f scripts/seed-data.sql
```

**Test login credentials (all users):**
- Email: Any of the seeded emails (e.g., `sarah.johnson@example.com`)
- Password: `password123`
- Bcrypt hash: `$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhkO`

This creates:
- `mentors` table (with English levels, contact info, status)
- `availability_slots` table (weekly schedule: day, start/end time)
- Indexes for performance
- Sample data for testing

### Database Schema

**mentors table:**
- `id` (UUID, PK)
- `name`, `email` (unique), `password_hash`
- `english_level` (A1-C2)
- `contact`, `timezone`
- `status` (active/inactive)
- `created_at`, `updated_at`

**availability_slots table:**
- `id` (UUID, PK)
- `mentor_id` (FK → mentors.id, CASCADE DELETE)
- `day_of_week` (1-7: Monday-Sunday)
- `start_time`, `end_time` (TIME)

## Backend Setup (Next.js)

### 1. Install Dependencies

```bash
npm install
```

### 2. Configure Environment

Create `.env.local`:

```env
DATABASE_URL=postgresql://admin:P@ssw0rd@157.10.73.52:5432/sa_tutor_finder
JWT_SECRET=your-secret-key-change-in-production-minimum-32-characters-long
```

### 3. Start Development Server

```bash
npm run dev
```

Server runs at: `http://localhost:3000`

### 4. Test API Endpoints

**Authentication:**
```bash
# Signup
curl -X POST http://localhost:3000/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com",
    "password": "password123",
    "english_level": "B2",
    "contact": "telegram.me/johndoe"
  }'

# Login
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "password123"
  }'
```

**Mentor Discovery:**
```bash
# Get all active mentors
curl http://localhost:3000/api/mentors

# Filter by day (1=Monday, 2=Tuesday, etc.)
curl "http://localhost:3000/api/mentors?day=1"

# Filter by time range
curl "http://localhost:3000/api/mentors?from=18:00&to=20:00"

# Filter by English level
curl "http://localhost:3000/api/mentors?level=B2"

# Combined filters
curl "http://localhost:3000/api/mentors?day=1&from=18:00&to=20:00&level=B2"

# Get mentor detail
curl http://localhost:3000/api/mentors/{mentor_id}
```

**Profile Management (requires JWT):**
```bash
# Update own profile
curl -X PATCH http://localhost:3000/api/mentors/me \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Updated Name",
    "english_level": "C1"
  }'

# Get own availability
curl http://localhost:3000/api/mentors/me/availability \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"

# Update availability (replaces all slots atomically)
curl -X POST http://localhost:3000/api/mentors/me/availability \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "slots": [
      {"day_of_week": 1, "start_time": "18:00", "end_time": "20:00"},
      {"day_of_week": 3, "start_time": "19:00", "end_time": "21:00"}
    ]
  }'
```

### 5. Deploy to Vercel

```bash
# Install Vercel CLI
npm i -g vercel

# Deploy
vercel

# Set environment variables in Vercel dashboard:
# DATABASE_URL=postgresql://...
# JWT_SECRET=...
```

## Frontend Setup (Flutter)

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Configure API URL

Edit `lib/config/api_config.dart`:

```dart
// For local development
static const String baseUrl = 'http://localhost:3000/api';

// For production
static const String baseUrl = 'https://tutor.openplp.com/api';
```

### 3. Run the App

```bash
# iOS Simulator
flutter run

# Android Emulator
flutter run

# Specific device
flutter devices
flutter run -d <device-id>
```

### 4. Build Release

```bash
# Android APK
flutter build apk --release

# iOS (requires macOS + Xcode)
flutter build ios --release

# App Bundle (for Play Store)
flutter build appbundle --release
```

## Project Structure

```
sa-tutor-finder/
├── app/                          # Next.js app directory
│   ├── api/                      # API routes
│   │   ├── auth/
│   │   │   ├── signup/route.ts
│   │   │   └── login/route.ts
│   │   ├── mentors/
│   │   │   ├── route.ts          # List mentors
│   │   │   ├── [id]/route.ts     # Mentor detail
│   │   │   └── me/
│   │   │       ├── route.ts      # Update profile
│   │   │       └── availability/route.ts
│   │   └── admin/
│   │       └── mentors/[id]/status/route.ts
│   ├── layout.tsx
│   ├── page.tsx
│   └── globals.css
├── lib/                          # Flutter app
│   ├── config/
│   │   ├── api_config.dart       # API endpoints
│   │   └── theme.dart            # App theme
│   ├── models/
│   │   └── mentor.dart           # Data models
│   ├── providers/
│   │   └── auth_provider.dart    # State management
│   ├── screens/
│   │   ├── login_screen.dart
│   │   ├── registration_screen.dart
│   │   ├── mentor_search_screen.dart
│   │   └── mentor_detail_screen.dart
│   ├── services/
│   │   └── api_service.dart      # HTTP client
│   └── main.dart
├── scripts/
│   └── init-db.sql               # Database schema
├── .env.local                    # Backend environment
├── package.json
├── pubspec.yaml
├── CLAUDE.md                     # Project context for Claude
└── PROJECT_SETUP.md              # This file
```

## Key Features Implemented

### Backend (Next.js API)
- ✅ JWT authentication with bcrypt
- ✅ Mentor registration and login
- ✅ Mentor search with filters (day, time, level)
- ✅ Profile management (update info, availability)
- ✅ Admin status management
- ✅ Detailed error responses with codes
- ✅ PostgreSQL with proper indexes
- ✅ snake_case naming convention throughout

### Frontend (Flutter)
- ✅ Login screen with validation
- ✅ Registration screen with role selection
- ✅ Mentor search with filters
- ✅ Mentor detail with calendar view
- ✅ Custom theme matching HTML designs
- ✅ Dark mode support
- ✅ Secure JWT storage
- ✅ Error handling and loading states

## API Response Format

All API responses use snake_case:

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

Error responses:

```json
{
  "error": {
    "message": "Detailed error message",
    "code": "ERROR_CODE",
    "meta": { "additional": "context" }
  }
}
```

## Naming Convention (CRITICAL)

**⚠️ ALWAYS USE snake_case:**
- Database fields: `english_level`, `created_at`, `day_of_week`
- API responses: No camelCase transformation
- Flutter models: Match database exactly

This ensures consistency across:
- PostgreSQL database
- Next.js API
- Flutter mobile app

## Common Issues & Solutions

### Issue: "Connection refused" in Flutter
**Solution**: Change API URL from `localhost` to your machine's IP address:
```dart
// macOS/Linux: Get IP with `ifconfig`
// Windows: Get IP with `ipconfig`
static const String baseUrl = 'http://192.168.1.x:3000/api';
```

### Issue: "JWT verification failed"
**Solution**: Ensure JWT_SECRET is the same across all environments and is at least 32 characters.

### Issue: "Database connection error"
**Solution**: Check `.env.local` has correct DATABASE_URL and database is accessible:
```bash
psql -U admin -h 157.10.73.52 -d sa_tutor_finder
```

### Issue: "Flutter build fails"
**Solution**: Run `flutter clean && flutter pub get`

## Development Workflow

1. **Start Backend**:
   ```bash
   npm run dev
   ```

2. **Test API** (Postman, curl, or browser):
   - http://localhost:3000/api/mentors

3. **Start Flutter**:
   ```bash
   flutter run
   ```

4. **Make Changes**:
   - Backend: Hot reload automatic
   - Flutter: Press `r` for hot reload, `R` for hot restart

## Production Deployment

### Backend (Vercel)
1. Push code to GitHub
2. Connect repo in Vercel dashboard
3. Set environment variables
4. Deploy automatically on push

### Frontend (App Stores)
1. Update version in `pubspec.yaml`
2. Build release: `flutter build appbundle`
3. Upload to Google Play Console
4. For iOS: `flutter build ios` + Xcode

## Next Steps (Not Implemented Yet)

- [ ] Mentor dashboard screen
- [ ] Availability management UI
- [ ] Session booking functionality
- [ ] Messaging system
- [ ] Student dashboard
- [ ] Notification system
- [ ] Reviews & ratings
- [ ] Admin panel

## Support

For issues:
1. Check this document
2. Review API error responses (they're detailed!)
3. Check CLAUDE.md for project context
4. Review database schema in `scripts/init-db.sql`
