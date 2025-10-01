export default function Home() {
  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-purple-600 via-purple-700 to-pink-500">
      <div className="text-center text-white p-8">
        <h1 className="text-5xl font-bold mb-4">SA Tutor Finder</h1>
        <p className="text-xl mb-8">API is ready! Use the Flutter app to interact with the platform.</p>
        <div className="bg-white/10 backdrop-blur-sm rounded-lg p-6 max-w-2xl">
          <h2 className="text-2xl font-semibold mb-4">Available API Endpoints:</h2>
          <ul className="text-left space-y-2">
            <li>• POST /api/auth/signup - Create mentor account</li>
            <li>• POST /api/auth/login - Login with email/password</li>
            <li>• GET /api/mentors - List mentors with filters</li>
            <li>• GET /api/mentors/[id] - Get mentor details</li>
            <li>• PATCH /api/mentors/me - Update own profile</li>
            <li>• GET /api/mentors/me/availability - Get own availability</li>
            <li>• POST /api/mentors/me/availability - Update availability</li>
            <li>• PATCH /api/admin/mentors/[id]/status - Update mentor status</li>
          </ul>
        </div>
      </div>
    </div>
  )
}
