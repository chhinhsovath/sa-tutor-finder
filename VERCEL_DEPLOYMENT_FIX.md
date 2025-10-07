# Fix Vercel Database Connection

## Problem
Vercel is still using the old database (157.10.73.52) instead of the new Prisma Cloud database.

## Solution

### 1. Update Vercel Environment Variables

Go to: https://vercel.com/dashboard → Your Project → Settings → Environment Variables

**Add/Update these variables:**

```
DATABASE_URL
postgres://b0139eef4d39aaaae79aafcbd0231526b051c33b651c81e3c223904bb24086e7:sk_HUFSD9xQzdHrBqSOBYfzc@db.prisma.io:5432/postgres?sslmode=require

JWT_SECRET
7ac3701d2f5a7ebe1044f4c64b31f28c6d7c0a97d5509a79d872cc48b7b596ad5d303beb6a3b930ccbac6b1b67a67bcf83c487dc23a510114134fb93add22848

NEXT_PUBLIC_API_URL
https://apitutor.openplp.com/api
```

### 2. Redeploy

Option A: Trigger new deployment
```bash
git commit --allow-empty -m "Trigger Vercel redeploy with new database"
git push origin main
```

Option B: In Vercel Dashboard
- Go to Deployments tab
- Click "Redeploy" on the latest deployment

### 3. Verify

After redeployment, test:
```bash
curl https://apitutor.openplp.com/api/mentors
```

Should return mentor list with bio, hourly_rate, average_rating fields.

### 4. Test Flutter Web App

Open: https://apitutor.openplp.com/app/

Try logging in with:
- Email: sarah@example.com
- Password: password123

---

## Current Status

- ✅ Local: Using NEW Prisma Cloud database
- ❌ Production: Using OLD database (needs update)
- ✅ Flutter Web: Built and deployed (waiting for API fix)

After fixing Vercel environment variables, everything will work!
