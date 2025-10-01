# SA Tutor Finder - Complete API Documentation

**Production API**: https://apitutor.openplp.com

All API endpoints use JSON format. Protected routes require JWT token in `Authorization: Bearer <token>` header.

---

## Table of Contents
1. [Authentication](#authentication)
2. [Mentors](#mentors)
3. [Students](#students)
4. [Sessions (Bookings)](#sessions-bookings)
5. [Messages](#messages)
6. [Reviews & Ratings](#reviews--ratings)
7. [Notifications](#notifications)
8. [Student Progress](#student-progress)
9. [Admin](#admin)

---

## Authentication

### Sign Up (Mentor)
`POST /api/auth/signup`

**Body:**
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123",
  "english_level": "B2",
  "contact": "telegram.me/johndoe"
}
```

**Response:**
```json
{
  "token": "eyJhbGci...",
  "mentor": { "id": "uuid", "name": "John Doe", ... }
}
```

### Login
`POST /api/auth/login`

**Body:**
```json
{
  "email": "john@example.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "token": "eyJhbGci...",
  "mentor": { "id": "uuid", "name": "John Doe", ... }
}
```

---

## Mentors

### List Mentors (Public)
`GET /api/mentors`

**Query Parameters:**
- `day` (1-7): Filter by availability day (1=Monday, 7=Sunday)
- `from`, `to` (HH:MM): Filter by time range
- `level` (A1-C2): Filter by English level

**Example:**
```
GET /api/mentors?day=1&from=09:00&to=12:00&level=B2
```

**Response:**
```json
{
  "mentors": [
    {
      "id": "uuid",
      "name": "Sarah Johnson",
      "email": "sarah@example.com",
      "english_level": "C1",
      "contact": "telegram.me/sarahj",
      "status": "active",
      "created_at": "2025-10-01T12:00:00Z"
    }
  ],
  "count": 1
}
```

### Get Mentor Detail
`GET /api/mentors/[id]`

**Response:**
```json
{
  "mentor": {
    "id": "uuid",
    "name": "Sarah Johnson",
    "english_level": "C1",
    ...
  }
}
```

### Get Mentor Reviews
`GET /api/mentors/[id]/reviews`

**Response:**
```json
{
  "reviews": [
    {
      "id": "uuid",
      "student_name": "Alice",
      "rating": 5,
      "comment": "Great mentor!",
      "created_at": "2025-10-01T..."
    }
  ],
  "stats": {
    "total_reviews": 10,
    "average_rating": "4.8",
    "distribution": { "5": 8, "4": 2, "3": 0, "2": 0, "1": 0 }
  }
}
```

### Update Own Profile
`PATCH /api/mentors/me` 🔒

**Headers:** `Authorization: Bearer <token>`

**Body:**
```json
{
  "name": "John Updated",
  "contact": "new_contact",
  "english_level": "C1"
}
```

### Get Own Availability
`GET /api/mentors/me/availability` 🔒

**Headers:** `Authorization: Bearer <token>`

**Response:**
```json
{
  "availability": [
    {
      "id": "uuid",
      "day_of_week": 1,
      "start_time": "09:00:00",
      "end_time": "12:00:00"
    }
  ]
}
```

### Update Own Availability
`POST /api/mentors/me/availability` 🔒

**Note:** This replaces ALL existing availability slots

**Body:**
```json
{
  "slots": [
    { "day_of_week": 1, "start_time": "09:00", "end_time": "12:00" },
    { "day_of_week": 3, "start_time": "14:00", "end_time": "17:00" }
  ]
}
```

---

## Students

### List Students (Mentors/Counselors only)
`GET /api/students` 🔒

**Query Parameters:**
- `status`: Filter by status (active/inactive)
- `grade_level`: Filter by grade level

**Response:**
```json
{
  "students": [
    {
      "id": "uuid",
      "name": "Alice Student",
      "email": "alice@example.com",
      "grade_level": "Grade 10",
      "status": "active"
    }
  ],
  "count": 1
}
```

---

## Sessions (Bookings)

### List Sessions
`GET /api/sessions` 🔒

**Query Parameters:**
- `user_type`: 'student' or 'mentor'
- `status`: Filter by status (scheduled, completed, cancelled, no-show)

**Response:**
```json
{
  "sessions": [
    {
      "id": "uuid",
      "student_id": "uuid",
      "student_name": "Alice",
      "mentor_id": "uuid",
      "mentor_name": "Sarah",
      "session_date": "2025-10-15",
      "start_time": "09:00:00",
      "end_time": "10:00:00",
      "status": "scheduled",
      "notes": "Focus on grammar"
    }
  ],
  "count": 1
}
```

### Book a Session (Student)
`POST /api/sessions` 🔒

**Body:**
```json
{
  "mentor_id": "uuid",
  "session_date": "2025-10-15",
  "start_time": "09:00",
  "end_time": "10:00",
  "notes": "Need help with grammar"
}
```

**Response:**
```json
{
  "session": { "id": "uuid", "status": "scheduled", ... },
  "message": "Session booked successfully"
}
```

### Get Session Detail
`GET /api/sessions/[id]` 🔒

### Update Session
`PATCH /api/sessions/[id]` 🔒

**Body:**
```json
{
  "status": "completed",
  "notes": "Updated notes"
}
```

### Cancel Session
`DELETE /api/sessions/[id]` 🔒

Sets status to 'cancelled'

### Submit Session Feedback (Mentor)
`POST /api/sessions/[id]/feedback` 🔒

**Body:**
```json
{
  "rating": 4,
  "student_performance": "Good progress in speaking",
  "notes": "Continue practicing pronunciation"
}
```

### Get Session Feedback
`GET /api/sessions/[id]/feedback` 🔒

---

## Messages

### Get Conversation Messages
`GET /api/messages` 🔒

**Query Parameters:**
- `other_user_id`: UUID of other person
- `other_user_type`: 'student', 'mentor', or 'counselor'

**Example:**
```
GET /api/messages?other_user_id=uuid&other_user_type=mentor
```

**Response:**
```json
{
  "messages": [
    {
      "id": "uuid",
      "sender_id": "uuid",
      "sender_type": "student",
      "receiver_id": "uuid",
      "receiver_type": "mentor",
      "message": "Hello, I have a question",
      "is_read": true,
      "created_at": "2025-10-01T12:00:00Z"
    }
  ],
  "count": 1
}
```

### Send Message
`POST /api/messages` 🔒

**Body:**
```json
{
  "receiver_id": "uuid",
  "receiver_type": "mentor",
  "message": "Hello, I have a question about today's session"
}
```

---

## Reviews & Ratings

### Submit Review (Student)
`POST /api/reviews` 🔒

**Body:**
```json
{
  "mentor_id": "uuid",
  "session_id": "uuid",
  "rating": 5,
  "comment": "Excellent mentor! Very patient and helpful."
}
```

**Constraints:**
- Rating: 1-5 (integer)
- Cannot review same session twice
- session_id is optional

---

## Notifications

### Get Notifications
`GET /api/notifications` 🔒

**Query Parameters:**
- `unread_only=true`: Get only unread notifications

**Response:**
```json
{
  "notifications": [
    {
      "id": "uuid",
      "user_id": "uuid",
      "user_type": "student",
      "title": "Session Reminder",
      "message": "Your session with Sarah starts in 1 hour",
      "type": "session",
      "is_read": false,
      "created_at": "2025-10-01T08:00:00Z"
    }
  ],
  "count": 1
}
```

### Mark Notifications as Read
`PATCH /api/notifications` 🔒

**Body:**
```json
{
  "notification_ids": ["uuid1", "uuid2"]
}
```

Or mark all as read:
```json
{
  "mark_all": true
}
```

### Get Notification Settings
`GET /api/notifications/settings` 🔒

**Response:**
```json
{
  "settings": {
    "email_notifications": true,
    "push_notifications": true,
    "sms_notifications": false,
    "session_reminders": true,
    "message_notifications": true,
    "review_notifications": true
  }
}
```

### Update Notification Settings
`PATCH /api/notifications/settings` 🔒

**Body:**
```json
{
  "email_notifications": false,
  "push_notifications": true,
  "session_reminders": true
}
```

---

## Student Progress

### Get Student Progress Reports
`GET /api/students/[id]/progress` 🔒

**Response:**
```json
{
  "progress_reports": [
    {
      "id": "uuid",
      "student_id": "uuid",
      "recorder_id": "uuid",
      "recorder_type": "mentor",
      "recorder_name": "Sarah Johnson",
      "progress_notes": "Great improvement in speaking",
      "skills_improved": "Pronunciation, fluency",
      "areas_for_improvement": "Grammar tenses",
      "created_at": "2025-10-01T12:00:00Z"
    }
  ],
  "count": 1
}
```

### Add Progress Report (Mentor/Counselor)
`POST /api/students/[id]/progress` 🔒

**Body:**
```json
{
  "progress_notes": "Student showed great improvement this week",
  "skills_improved": "Speaking confidence, vocabulary",
  "areas_for_improvement": "Past tense usage"
}
```

---

## Admin

### List All Students
`GET /api/admin/students` 🔒🔑

**Query Parameters:**
- `status`: Filter by status
- `grade_level`: Filter by grade level
- `search`: Search by name or email

**Response:**
```json
{
  "students": [
    {
      "id": "uuid",
      "name": "Alice",
      "email": "alice@example.com",
      "grade_level": "Grade 10",
      "status": "active",
      "total_sessions": "15",
      "completed_sessions": "12"
    }
  ],
  "count": 1
}
```

### Update Student
`PATCH /api/admin/students/[id]` 🔒🔑

**Body:**
```json
{
  "status": "inactive",
  "grade_level": "Grade 11"
}
```

### Update Mentor Status
`PATCH /api/admin/mentors/[id]/status` 🔒🔑

**Body:**
```json
{
  "status": "inactive"
}
```

### List All Counselors
`GET /api/admin/counselors` 🔒🔑

**Query Parameters:**
- `status`: Filter by status
- `search`: Search by name or email

### Platform Analytics
`GET /api/admin/analytics` 🔒🔑

**Response:**
```json
{
  "users": {
    "active_mentors": "45",
    "total_mentors": "50",
    "active_students": "120",
    "total_students": "135",
    "active_counselors": "5",
    "total_counselors": "6"
  },
  "sessions": {
    "total_sessions": "450",
    "scheduled": "50",
    "completed": "350",
    "cancelled": "40",
    "no_show": "10"
  },
  "session_trend": [
    { "date": "2025-10-01", "count": "15" },
    { "date": "2025-09-30", "count": "18" }
  ],
  "ratings": {
    "average_rating": "4.7",
    "total_reviews": "280"
  },
  "top_mentors": [
    {
      "id": "uuid",
      "name": "Sarah Johnson",
      "english_level": "C1",
      "average_rating": "4.9",
      "review_count": "45"
    }
  ],
  "engagement": {
    "messages_last_7_days": "350",
    "sessions_last_7_days": "45",
    "reviews_last_7_days": "12"
  }
}
```

### Financial Reports
`GET /api/admin/financial` 🔒🔑

**Query Parameters:**
- `start_date`: YYYY-MM-DD
- `end_date`: YYYY-MM-DD

**Response:**
```json
{
  "summary": {
    "total_sessions": 450,
    "completed_sessions": 350,
    "total_revenue": 7000,
    "average_session_rate": 20
  },
  "monthly_revenue": [
    {
      "month": "2025-10-01T00:00:00Z",
      "completed_sessions": 120,
      "cancelled_sessions": 15,
      "revenue": 2400
    }
  ],
  "top_earning_mentors": [
    {
      "id": "uuid",
      "name": "Sarah Johnson",
      "email": "sarah@example.com",
      "completed_sessions": "45",
      "total_earnings": "900"
    }
  ]
}
```

---

## Error Responses

All errors follow this format:

```json
{
  "error": {
    "message": "Detailed error message",
    "code": "ERROR_CODE",
    "meta": { "additional": "context" }
  }
}
```

**Common Error Codes:**
- `UNAUTHORIZED` (401): Missing or invalid token
- `FORBIDDEN` (403): Valid token but insufficient permissions
- `VALIDATION_ERROR` (400): Invalid input data
- `MENTOR_NOT_FOUND` (404): Mentor doesn't exist
- `STUDENT_NOT_FOUND` (404): Student doesn't exist
- `SESSION_NOT_FOUND` (404): Session doesn't exist
- `TIME_SLOT_CONFLICT` (400): Session time slot already booked
- `MENTOR_NOT_AVAILABLE` (400): Mentor not available at selected time
- `REVIEW_EXISTS` (400): Already reviewed this session
- `INTERNAL_ERROR` (500): Server error

---

## Legend
- 🔒 = Requires authentication (JWT token)
- 🔑 = Requires admin role (not yet implemented)

---

## Testing with curl

**Login:**
```bash
curl -X POST https://apitutor.openplp.com/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"sarah.johnson@example.com","password":"password123"}'
```

**List mentors:**
```bash
curl https://apitutor.openplp.com/api/mentors?level=C1
```

**Get own availability (with token):**
```bash
curl https://apitutor.openplp.com/api/mentors/me/availability \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

---

**Total API Routes: 28+**

All routes are fully functional and ready for integration with the Flutter mobile app.
