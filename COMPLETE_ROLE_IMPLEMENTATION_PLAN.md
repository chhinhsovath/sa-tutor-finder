# Complete Role Implementation Plan - SA Tutor Finder

## 📊 Overview: 4 User Roles

This document provides a systematic plan to build **complete, functional features** for all 4 user roles.

---

## 1️⃣ STUDENT ROLE (4 users)

**Test Accounts:** john@, maria@, ahmed@, yuki@ (all password: `password123`)

### Core User Journey
1. Browse available mentors by schedule/level
2. Book sessions with mentors
3. Attend/manage sessions
4. Chat with mentors
5. Rate/review mentors
6. Track learning progress

### Screens (Student-specific)
| Screen | File | Status | API Endpoint | Notes |
|--------|------|--------|--------------|-------|
| Student Dashboard | `student_dashboard_screen.dart` | ⚠️ Needs API | `GET /api/students/me` | Show upcoming sessions, stats |
| Browse Mentors | `mentor_search_screen.dart` | ✅ Done | `GET /api/mentors` | Filter by time/level |
| Mentor Detail | `mentor_detail_screen.dart` | ⚠️ Needs API | `GET /api/mentors/[id]` | View profile + reviews |
| Book Session | `session_booking_screen.dart` | 🔴 Missing API | `POST /api/sessions` | Calendar booking |
| My Sessions | (in dashboard) | 🔴 Missing API | `GET /api/sessions` | List booked sessions |
| Messaging | `messaging_screen.dart` | 🔴 Missing API | `GET/POST /api/messages` | 1-on-1 chat |
| Rate Mentor | `rate_mentor_screen.dart` | 🔴 Missing API | `POST /api/reviews` | After session |
| Progress Reports | `student_progress_reports_screen.dart` | ✅ Done | `GET /api/students/me/progress` | Learning stats |
| Help/Support | `help_support_screen.dart` | ✅ Done | `GET/POST /api/support/*` | FAQ + tickets |
| Notifications | (shared) | ⚠️ Needs API | `GET /api/notifications` | Session reminders |
| Profile Edit | `profile_editing_screen.dart` | ⚠️ Needs API | `PATCH /api/students/me` | Update profile |

### Required APIs (Status)
- ✅ `GET /api/students/me` - Get profile
- ⚠️ `PATCH /api/students/me` - Update profile (exists)
- ✅ `GET /api/students/me/progress` - Progress report
- ✅ `GET /api/mentors` - Browse mentors
- ✅ `GET /api/mentors/[id]` - Mentor detail
- ✅ `POST /api/sessions` - Book session (created)
- ✅ `GET /api/sessions` - List sessions (created)
- ✅ `GET/POST /api/messages` - Messaging (created)
- ✅ `POST /api/reviews` - Rate mentor (created)
- ✅ `GET /api/notifications` - Notifications (created)

### Implementation Tasks
1. ✅ **API Layer**: All endpoints exist
2. 🔴 **Flutter Integration**: Connect screens to APIs
3. 🔴 **State Management**: Add providers for sessions, messages
4. 🔴 **UI Polish**: Loading states, error handling, empty states

---

## 2️⃣ MENTOR ROLE (5 users)

**Test Accounts:** sarah@, michael@, emma@, david@, lisa@ (all password: `password123`)

### Core User Journey
1. Set weekly availability schedule
2. Receive session booking requests
3. Confirm/decline sessions
4. Conduct sessions
5. Provide feedback after sessions
6. View reviews and ratings

### Screens (Mentor-specific)
| Screen | File | Status | API Endpoint | Notes |
|--------|------|--------|--------------|-------|
| Mentor Dashboard | `mentor_dashboard_screen.dart` | ⚠️ Needs API | Custom aggregation | Show pending/upcoming sessions |
| Availability Management | `availability_management_screen.dart` | ✅ Done | `GET/POST /api/mentors/me/availability` | Weekly schedule |
| Availability Quick Toggle | `availability_setting_screen.dart` | ✅ Done | Same as above | Quick on/off |
| My Sessions | (in dashboard) | 🔴 Missing API | `GET /api/sessions?mentor_id=me` | List all sessions |
| Session Detail | (view session) | 🔴 Missing API | `GET /api/sessions/[id]` | Confirm/complete |
| Session Feedback | `session_feedback_screen.dart` | 🔴 Missing API | `PATCH /api/sessions/[id]` | Add mentor feedback |
| My Reviews | `mentor_reviews_screen.dart` | ✅ Done | `GET /api/mentors/[id]/reviews` | View ratings |
| Messaging | `messaging_screen.dart` | 🔴 Missing API | `GET/POST /api/messages` | Chat with students |
| Profile Edit | `profile_editing_screen.dart` | ✅ Done | `GET/PATCH /api/mentors/me` | Update bio, rate |
| Notifications | (shared) | ⚠️ Needs API | `GET /api/notifications` | Booking alerts |

### Required APIs (Status)
- ✅ `GET /api/mentors/me` - Get profile
- ✅ `PATCH /api/mentors/me` - Update profile
- ✅ `GET/POST /api/mentors/me/availability` - Manage schedule
- ✅ `GET /api/sessions` - List sessions (filter by mentor)
- ✅ `GET /api/sessions/[id]` - Session detail (created)
- ✅ `PATCH /api/sessions/[id]` - Confirm/complete session (created)
- ✅ `GET /api/mentors/[id]/reviews` - View reviews
- ✅ `GET/POST /api/messages` - Messaging (created)
- ✅ `GET /api/notifications` - Notifications (created)

### Implementation Tasks
1. ✅ **API Layer**: All endpoints exist
2. 🔴 **Flutter Integration**: Connect screens to APIs
3. 🔴 **State Management**: Add session confirmation logic
4. 🔴 **UI Polish**: Session status badges, feedback forms

---

## 3️⃣ COUNSELOR ROLE (1 user)

**Test Account:** jennifer@example.com (password: `password123`)

### Core User Journey
1. Monitor platform activity (all sessions/users)
2. View student progress reports
3. View mentor performance
4. Handle support tickets
5. Generate platform statistics

### Screens (Counselor-specific)
| Screen | File | Status | API Endpoint | Notes |
|--------|------|--------|--------------|-------|
| Counselor Dashboard | `guidance_counselor_dashboard_screen.dart` | ✅ Done | `GET /api/counselors/dashboard` | Platform overview |
| View All Sessions | (in dashboard) | ✅ Done | `GET /api/sessions` (all) | Monitor sessions |
| Student Details | (click from dashboard) | 🔴 Missing | `GET /api/students/[id]/progress` | Individual student |
| Mentor Details | (click from dashboard) | ✅ Done | `GET /api/mentors/[id]` | Individual mentor |
| Support Tickets | `help_support_screen.dart` | ⚠️ Needs API | `GET /api/support/tickets` (all) | View all tickets |
| Profile Edit | `profile_editing_screen.dart` | ✅ Done | `GET/PATCH /api/counselors/me` | Update profile |

### Required APIs (Status)
- ✅ `GET /api/counselors/me` - Get profile (created)
- ✅ `PATCH /api/counselors/me` - Update profile (created)
- ✅ `GET /api/counselors/dashboard` - Dashboard stats (created)
- ✅ `GET /api/sessions` - All sessions
- ✅ `GET /api/students/[id]/progress` - Student details (can use existing)
- ✅ `GET /api/mentors/[id]` - Mentor details
- ✅ `GET /api/support/tickets` - All tickets (created)

### Implementation Tasks
1. ✅ **API Layer**: All endpoints exist
2. 🔴 **Flutter Integration**: Connect dashboard to API
3. 🔴 **Add Role Check**: Counselor can view ALL users' data
4. 🔴 **UI Polish**: Statistics charts, ticket management

---

## 4️⃣ ADMIN ROLE (1 user)

**Test Account:** admin@example.com (password: `password123`)

### Core User Journey
1. Manage all users (mentors, students, counselors)
2. View platform analytics
3. Review financial reports
4. Approve/suspend accounts
5. Manage system settings

### Screens (Admin-specific)
| Screen | File | Status | API Endpoint | Notes |
|--------|------|--------|--------------|-------|
| Admin Analytics | `admin_analytics_screen.dart` | ✅ Done | `GET /api/admin/analytics` | Platform stats |
| Manage Mentors | `admin_mentor_management_screen.dart` | ⚠️ Needs API | `GET /api/admin/mentors` | Search/filter/update |
| Manage Students | `admin_student_management_screen.dart` | ⚠️ Needs API | `GET /api/admin/students` | Search/filter/update |
| Manage Counselors | `admin_counselor_management_screen.dart` | ✅ Done | `GET/POST/PATCH/DELETE /api/admin/counselors` | CRUD operations |
| Financial Reports | `admin_financial_reporting_screen.dart` | ✅ Done | `GET /api/admin/transactions/*` | Revenue, transactions |

### Required APIs (Status)
- ✅ `GET /api/admin/analytics` - Platform statistics (created)
- ✅ `GET /api/admin/mentors` - List mentors (created)
- ✅ `PATCH /api/admin/mentors/[id]/status` - Update mentor status
- ✅ `GET /api/admin/students` - List students (created)
- ⚠️ `PATCH /api/admin/students/[id]` - Update student (needs creation)
- ✅ `GET /api/admin/counselors` - List counselors (created)
- ✅ `POST /api/admin/counselors` - Create counselor (created)
- ✅ `PATCH /api/admin/counselors/[id]` - Update counselor (created)
- ✅ `DELETE /api/admin/counselors/[id]` - Delete counselor (created)
- ✅ `GET /api/admin/transactions` - List transactions (created)
- ✅ `GET /api/admin/transactions/summary` - Financial summary (created)

### Implementation Tasks
1. ✅ **API Layer**: Most endpoints exist, need student update
2. 🔴 **Flutter Integration**: Connect management screens to APIs
3. 🔴 **Add CRUD Actions**: Enable/disable users, view details
4. 🔴 **UI Polish**: Data tables, filters, action buttons

---

## 📋 SHARED FEATURES (All Roles)

### Common Screens
| Screen | File | Status | Notes |
|--------|------|--------|-------|
| Login | `login_screen.dart` | ✅ Done | Multi-role login working |
| Registration | `registration_screen.dart` | ✅ Done | Mentor signup only currently |
| Notification Settings | `notification_settings_screen.dart` | ✅ Done | `GET/PATCH /api/notifications/preferences` |
| Help/Support | `help_support_screen.dart` | ✅ Done | FAQ + Support tickets |

---

## 🎯 SYSTEMATIC IMPLEMENTATION ORDER

### Phase 1: Complete Backend APIs (Priority: CRITICAL)
**Status:** ✅ 95% Complete
- ✅ Authentication (login/signup)
- ✅ Student APIs
- ✅ Mentor APIs
- ✅ Sessions APIs
- ✅ Messaging APIs
- ✅ Reviews APIs
- ✅ Counselor APIs
- ✅ Admin APIs (except student update)
- ✅ Notifications APIs
- ✅ Support/FAQ APIs

**Remaining:**
- 🔴 `PATCH /api/admin/students/[id]` - Update student by admin

### Phase 2: Flutter API Integration (Priority: HIGH)
**Status:** 🔴 10% Complete

For each role, connect Flutter screens to backend APIs:

1. **Student Role** (Estimated: 4-6 hours)
   - Student dashboard → API data
   - Session booking → Create session
   - Messaging → Send/receive messages
   - Rate mentor → Submit review
   - Progress → Display API stats

2. **Mentor Role** (Estimated: 3-4 hours)
   - Mentor dashboard → API data
   - Session list → Filter by mentor
   - Session actions → Confirm/complete
   - Reviews display → API pagination

3. **Counselor Role** (Estimated: 2-3 hours)
   - Dashboard → API stats
   - Session monitoring → All sessions
   - Ticket management → View/update tickets

4. **Admin Role** (Estimated: 3-4 hours)
   - Analytics → API stats
   - User management → CRUD operations
   - Financial reports → Transaction data

### Phase 3: State Management (Priority: MEDIUM)
**Status:** 🔴 Not Started

Create providers for:
- `SessionsProvider` - Manage session state
- `MessagesProvider` - Real-time messaging
- `NotificationsProvider` - Push notifications
- `AdminProvider` - User management state

### Phase 4: UI/UX Polish (Priority: LOW)
**Status:** 🔴 Not Started

- Loading states for all API calls
- Error handling with user-friendly messages
- Empty states (no sessions, no messages)
- Success animations
- Pull-to-refresh
- Pagination for long lists

---

## ✅ SUCCESS CRITERIA

Each role is "complete" when:

### Student ✓
- [ ] Can browse and filter mentors
- [ ] Can book sessions via calendar
- [ ] Can see upcoming/past sessions
- [ ] Can chat with mentors
- [ ] Can rate/review after session
- [ ] Can view progress report
- [ ] Can manage notifications

### Mentor ✓
- [ ] Can set weekly availability
- [ ] Can see pending booking requests
- [ ] Can confirm/decline sessions
- [ ] Can provide session feedback
- [ ] Can view own reviews/ratings
- [ ] Can chat with students
- [ ] Can update profile (bio, rate)

### Counselor ✓
- [ ] Can view platform dashboard
- [ ] Can monitor all sessions
- [ ] Can view student progress reports
- [ ] Can view mentor performance
- [ ] Can manage support tickets
- [ ] Can generate reports

### Admin ✓
- [ ] Can view platform analytics
- [ ] Can manage all users (CRUD)
- [ ] Can suspend/activate accounts
- [ ] Can view financial reports
- [ ] Can manage system settings

---

## 🚀 NEXT STEPS

Ready to implement systematically! Which would you like me to start with?

**Recommended Order:**
1. ✅ Complete missing APIs (1 endpoint)
2. 🔴 **Student Role** (highest priority - primary user flow)
3. 🔴 **Mentor Role** (second priority - completes booking flow)
4. 🔴 **Counselor Role** (monitoring role)
5. 🔴 **Admin Role** (management role)
