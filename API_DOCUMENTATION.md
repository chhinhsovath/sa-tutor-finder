# SA Tutor Finder - API Documentation

## Overview

SA Tutor Finder is a complete tutor/mentor discovery and session booking platform with:
- **Frontend**: Flutter mobile app
- **Backend**: Next.js 14 App Router with REST API
- **Database**: PostgreSQL (Prisma Cloud)
- **Authentication**: JWT-based with bcrypt password hashing

**Production API URL**: https://apitutor.openplp.com

---

## 🔐 Authentication

All authenticated endpoints require a JWT token in the `Authorization` header:
```
Authorization: Bearer <jwt_token>
```

### POST /api/auth/signup
Create a new account (mentor, student, or counselor).

**Request Body:**
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123",
  "user_type": "student",
  "english_level": "B1",
  "phone_number": "+855123456789",
  "learning_goals": "Improve conversation skills"
}
```

**Response (201):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "uuid",
    "name": "John Doe",
    "email": "john@example.com",
    "user_type": "student",
    ...
  }
}
```

### POST /api/auth/login
Login with email and password.

**Request Body:**
```json
{
  "email": "john@example.com",
  "password": "password123",
  "user_type": "student"
}
```

**Response (200):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "uuid",
    "name": "John Doe",
    "email": "john@example.com",
    "user_type": "student",
    ...
  }
}
```

---

## 👨‍🏫 Mentors

### GET /api/mentors
List active mentors with optional filters.

**Query Parameters:**
- `day` (1-7 for Mon-Sun)
- `from` & `to` (time range, e.g., `from=09:00&to=12:00`)
- `level` (English level: A1, A2, B1, B2, C1, C2)

**Example:**
```
GET /api/mentors?day=1&from=09:00&to=12:00&level=C1
```

**Response (200):**
```json
{
  "mentors": [
    {
      "id": "uuid",
      "name": "Sarah Johnson",
      "email": "sarah@example.com",
      "english_level": "C2",
      "bio": "Experienced English teacher...",
      "hourly_rate": 25.00,
      "average_rating": 4.8,
      "total_sessions": 45,
      "availability_slots": [...]
    }
  ],
  "count": 1
}
```

### GET /api/mentors/[id]
Get detailed mentor profile including reviews and availability.

**Response (200):**
```json
{
  "mentor": {
    "id": "uuid",
    "name": "Sarah Johnson",
    "bio": "Experienced teacher...",
    "average_rating": 4.8,
    "availability_slots": [...],
    "reviews": [
      {
        "id": "uuid",
        "rating": 5,
        "comment": "Excellent teacher!",
        "student": { "name": "John Doe" }
      }
    ]
  }
}
```

### GET /api/mentors/me
Get authenticated mentor's own profile. **[Auth: Mentor]**

### PATCH /api/mentors/me
Update mentor profile. **[Auth: Mentor]**

**Request Body:**
```json
{
  "name": "Sarah Johnson",
  "bio": "Updated bio...",
  "hourly_rate": 30.00,
  "english_level": "C2"
}
```

### GET /api/mentors/me/availability
Get mentor's availability slots. **[Auth: Mentor]**

### POST /api/mentors/me/availability
Replace all availability slots (atomic operation). **[Auth: Mentor]**

**Request Body:**
```json
{
  "slots": [
    {
      "day_of_week": 1,
      "start_time": "09:00",
      "end_time": "12:00"
    },
    {
      "day_of_week": 3,
      "start_time": "09:00",
      "end_time": "12:00"
    }
  ]
}
```

---

## 📚 Sessions

### GET /api/sessions
List user's sessions (student sees their bookings, mentor sees their sessions). **[Auth Required]**

**Query Parameters:**
- `status` (pending, confirmed, completed, cancelled, no_show)

**Response (200):**
```json
{
  "sessions": [
    {
      "id": "uuid",
      "session_date": "2025-10-15",
      "start_time": "09:00:00",
      "end_time": "10:00:00",
      "duration_minutes": 60,
      "status": "confirmed",
      "student": { "name": "John Doe" },
      "mentor": { "name": "Sarah Johnson" }
    }
  ],
  "count": 1
}
```

### POST /api/sessions
Book a new session. **[Auth: Student]**

**Request Body:**
```json
{
  "mentor_id": "uuid",
  "session_date": "2025-10-15",
  "start_time": "09:00",
  "end_time": "10:00",
  "duration_minutes": 60,
  "notes": "First session"
}
```

**Response (201):**
```json
{
  "session": {
    "id": "uuid",
    "status": "pending",
    "session_date": "2025-10-15",
    ...
  }
}
```

### GET /api/sessions/[id]
Get session details. **[Auth: Student or Mentor of this session]**

### PATCH /api/sessions/[id]
Update session status or add feedback. **[Auth: Student or Mentor of this session]**

**Request Body (Mentor confirms):**
```json
{
  "status": "confirmed"
}
```

**Request Body (Mark completed with feedback):**
```json
{
  "status": "completed",
  "mentor_feedback": "Great progress today!"
}
```

**Request Body (Cancel):**
```json
{
  "status": "cancelled",
  "cancellation_reason": "Schedule conflict"
}
```

---

## ⭐ Reviews

### POST /api/reviews
Create a review for a completed session. **[Auth: Student]**

**Request Body:**
```json
{
  "session_id": "uuid",
  "rating": 5,
  "comment": "Excellent teacher! Very patient and helpful."
}
```

**Response (201):**
```json
{
  "review": {
    "id": "uuid",
    "rating": 5,
    "comment": "Excellent teacher!",
    "student": { "name": "John Doe" },
    "mentor": { "name": "Sarah Johnson" }
  }
}
```

---

## 💬 Messages

### GET /api/messages
Get conversation with specific user. **[Auth Required]**

**Query Parameters:**
- `user_id` (required) - ID of the other user

**Response (200):**
```json
{
  "messages": [
    {
      "id": "uuid",
      "sender_id": "uuid",
      "sender_type": "student",
      "recipient_id": "uuid",
      "recipient_type": "mentor",
      "content": "Hi, looking forward to our session!",
      "is_read": true,
      "created_at": "2025-10-07T12:00:00Z"
    }
  ],
  "count": 1
}
```

### POST /api/messages
Send a message. **[Auth Required]**

**Request Body:**
```json
{
  "recipient_id": "uuid",
  "recipient_type": "mentor",
  "content": "Hi, can we reschedule?"
}
```

---

## 👨‍🎓 Students

### GET /api/students/me
Get student's own profile. **[Auth: Student]**

**Response (200):**
```json
{
  "student": {
    "id": "uuid",
    "name": "John Doe",
    "email": "john@example.com",
    "english_level": "B1",
    "learning_goals": "Improve conversation skills",
    "total_sessions": 12
  }
}
```

### PATCH /api/students/me
Update student profile. **[Auth: Student]**

**Request Body:**
```json
{
  "name": "John Doe",
  "english_level": "B2",
  "learning_goals": "Prepare for IELTS"
}
```

---

## 🔔 Notifications

### GET /api/notifications
List user's notifications. **[Auth Required]**

**Query Parameters:**
- `unread_only` (boolean)

**Response (200):**
```json
{
  "notifications": [
    {
      "id": "uuid",
      "type": "session_confirmed",
      "title": "Session Confirmed",
      "content": "Your session with Sarah Johnson has been confirmed",
      "is_read": false,
      "created_at": "2025-10-07T12:00:00Z"
    }
  ],
  "count": 1
}
```

### PATCH /api/notifications/[id]
Mark notification as read. **[Auth Required]**

---

## 👑 Admin

### GET /api/admin/mentors
List all mentors. **[Auth: Admin]**

**Query Parameters:**
- `status` (active, inactive, suspended)

### GET /api/admin/students
List all students. **[Auth: Admin]**

### GET /api/admin/analytics
Get platform analytics. **[Auth: Admin]**

**Response (200):**
```json
{
  "analytics": {
    "mentors": { "total": 5, "active": 4 },
    "students": { "total": 10, "active": 8 },
    "sessions": { "total": 50, "completed": 30, "pending": 5 },
    "reviews": { "total": 25, "average_rating": 4.7 }
  }
}
```

---

## 🗄️ Database Schema

### Key Tables:
- **mentors** - Mentor profiles with bio, hourly_rate, average_rating
- **students** - Student profiles with learning_goals
- **counselors** - Guidance counselor accounts
- **admins** - Admin accounts
- **availability_slots** - Weekly recurring availability (day_of_week + time)
- **sessions** - Booked sessions (pending → confirmed → completed)
- **messages** - 1-on-1 messaging (polymorphic)
- **reviews** - Session reviews (1-5 stars)
- **notifications** - System notifications
- **transactions** - Financial records

### Key Relationships:
- One mentor has many availability_slots, sessions, reviews
- One student has many sessions, reviews, notifications
- Each session can have one review
- Messages are polymorphic (sender/recipient can be student/mentor/counselor)

---

## 🧪 Test Accounts

All test accounts use password: **password123**

**Mentors:**
- sarah@example.com (C2, 45 sessions, 4.8 rating)
- michael@example.com (C1, 32 sessions, 4.9 rating)
- emma@example.com (B2, 28 sessions, 4.7 rating)
- david@example.com (C1, 15 sessions, 4.6 rating)
- lisa@example.com (B2, new mentor)

**Students:**
- john@example.com (A2, 12 sessions)
- maria@example.com (B1, 8 sessions)
- ahmed@example.com (A1, 3 sessions)
- yuki@example.com (B2, new student)

**Counselor:**
- jennifer@example.com

**Admin:**
- admin@example.com

---

## 🚀 Development Commands

```bash
# Install dependencies
npm install

# Generate Prisma Client
npx prisma generate

# Push schema to database
npx prisma db push

# Seed database with test data
npx prisma db seed

# Run development server
npm run dev

# Build for production
npm run build

# Start production server
npm start

# Open Prisma Studio (database GUI)
npx prisma studio
```

---

## 📱 Flutter App Integration

The Flutter app is configured to connect to:
- Production: `https://apitutor.openplp.com/api`
- Development: `http://localhost:3000/api`

API responses use strict **snake_case** convention for all field names to ensure compatibility with Flutter models.

---

## ✅ Implementation Status

### Completed Features:
✅ Complete database schema (10 tables)  
✅ JWT authentication with bcrypt  
✅ Mentor discovery with filters (day, time, level)  
✅ Session booking and management  
✅ Messaging system  
✅ Review and rating system  
✅ Student profiles  
✅ Mentor profiles with availability management  
✅ Notifications system  
✅ Admin analytics and user management  
✅ Comprehensive seed data  

### Production Ready:
- All API routes migrated to Prisma ORM
- Snake_case naming convention enforced
- Detailed error responses
- JWT authentication and authorization
- Transaction support for atomic operations
- Database deployed on Prisma Cloud
