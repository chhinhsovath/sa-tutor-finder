# User Role Testing Guide - SA Tutor Finder

## ✅ All User Roles Configured

The Flutter app now correctly routes users to their role-specific dashboards based on the `user_type` field returned from the login API.

---

## 🔐 Test Accounts

All accounts use the same password: **`password123`**

### 👨‍🏫 MENTORS (5 users)

| Email                | Name          | Dashboard Screen         | Expected Features                        |
|----------------------|---------------|-------------------------|------------------------------------------|
| sarah@example.com    | Sarah Johnson | MentorDashboardScreen   | Sessions, Availability, Reviews, Profile |
| michael@example.com  | Michael Chen  | MentorDashboardScreen   | Sessions, Availability, Reviews, Profile |
| emma@example.com     | Emma Wilson   | MentorDashboardScreen   | Sessions, Availability, Reviews, Profile |
| david@example.com    | David Kim     | MentorDashboardScreen   | Sessions, Availability, Reviews, Profile |
| lisa@example.com     | Lisa Anderson | MentorDashboardScreen   | Sessions, Availability, Reviews, Profile |

### 👨‍🎓 STUDENTS (4 users)

| Email             | Name         | Dashboard Screen         | Expected Features                     |
|-------------------|--------------|-------------------------|---------------------------------------|
| john@example.com  | John Smith   | StudentDashboardScreen  | Browse Mentors, Book Sessions, Chat   |
| maria@example.com | Maria Garcia | StudentDashboardScreen  | Browse Mentors, Book Sessions, Chat   |
| ahmed@example.com | Ahmed Hassan | StudentDashboardScreen  | Browse Mentors, Book Sessions, Chat   |
| yuki@example.com  | Yuki Tanaka  | StudentDashboardScreen  | Browse Mentors, Book Sessions, Chat   |

### 👨‍💼 COUNSELOR (1 user)

| Email                 | Name             | Dashboard Screen                     | Expected Features                 |
|-----------------------|------------------|-------------------------------------|-----------------------------------|
| jennifer@example.com  | Dr. Jennifer Lee | GuidanceCounselorDashboardScreen    | Monitor All Sessions, User Stats  |

### 👑 ADMIN (1 user)

| Email             | Name       | Dashboard Screen         | Expected Features                           |
|-------------------|------------|-------------------------|---------------------------------------------|
| admin@example.com | Admin User | AdminAnalyticsScreen    | Manage Users, Financial Reports, Analytics  |

---

## 🧪 Testing Steps

### 1. Test Each User Role Login

```bash
# Start Flutter web server (if not already running)
cd /Users/chhinhsovath/Documents/GitHub/sa-tutor-finder
flutter run -d web-server --web-port 8080
```

Open browser: **http://localhost:8080**

### 2. Test Login & Dashboard Routing

For each user type, perform these steps:

#### A. Test Mentor (sarah@example.com)
1. Login with `sarah@example.com` / `password123`
2. ✅ Should redirect to **MentorDashboardScreen**
3. ✅ Should see: My Sessions, Availability Management, Reviews

#### B. Test Student (john@example.com)
1. Logout (if logged in)
2. Login with `john@example.com` / `password123`
3. ✅ Should redirect to **StudentDashboardScreen**
4. ✅ Should see: Browse Mentors, My Sessions, Messages

#### C. Test Counselor (jennifer@example.com)
1. Logout
2. Login with `jennifer@example.com` / `password123`
3. ✅ Should redirect to **GuidanceCounselorDashboardScreen**
4. ✅ Should see: Platform Overview, User Statistics

#### D. Test Admin (admin@example.com)
1. Logout
2. Login with `admin@example.com` / `password123`
3. ✅ Should redirect to **AdminAnalyticsScreen**
4. ✅ Should see: User Management, Financial Reports, Analytics

---

## 🔍 Verification Checklist

For each login test, verify:

- [ ] Login succeeds (receives JWT token)
- [ ] User info appears in API response with correct `user_type`
- [ ] App redirects to correct dashboard screen
- [ ] Dashboard shows role-appropriate content
- [ ] Navigation menu matches user role
- [ ] Restricted features are hidden for non-authorized roles

---

## 🛠️ Technical Details

### API Login Response Format

All successful logins return:
```json
{
  "token": "eyJhbGci...",
  "user": {
    "id": "uuid",
    "name": "User Name",
    "email": "user@example.com",
    "user_type": "student|mentor|counselor|admin",
    ...
  }
}
```

### Dashboard Routing Logic

File: `lib/screens/main_dashboard_screen.dart`

```dart
switch (user.userType) {
  case 'student':
    return const StudentDashboardScreen();
  case 'mentor':
    return const MentorDashboardScreen();
  case 'counselor':
    return const GuidanceCounselorDashboardScreen();
  case 'admin':
    return const AdminAnalyticsScreen();
  default:
    return const MentorDashboardScreen();
}
```

---

## 🐛 Troubleshooting

### Issue: All users see MentorDashboardScreen
**Cause:** Flutter app not reloaded after code changes
**Fix:** Hard refresh browser (Ctrl+Shift+R) or restart `flutter run`

### Issue: Login succeeds but doesn't redirect
**Cause:** `user_type` field missing in API response
**Fix:** Verify API returns `user_type` in login response (check browser DevTools Network tab)

### Issue: "Invalid token" error
**Cause:** Token storage not working on web
**Fix:** Clear browser localStorage and try again

---

## 📊 Expected Results Summary

| User Type  | Count | Dashboard Screen                     | Login Works | Routing Correct |
|------------|-------|-------------------------------------|-------------|-----------------|
| Mentor     | 5     | MentorDashboardScreen               | ✅          | ✅              |
| Student    | 4     | StudentDashboardScreen              | ✅          | ✅              |
| Counselor  | 1     | GuidanceCounselorDashboardScreen    | ✅          | ✅              |
| Admin      | 1     | AdminAnalyticsScreen                | ✅          | ✅              |

**Total Test Accounts:** 11
**All Roles Configured:** ✅ YES
