'use client';

import { useEffect } from 'react';
import { useRouter } from 'next/navigation';

export default function Home() {
  const router = useRouter();

  useEffect(() => {
    // Redirect to Flutter web app
    router.push('/app');
  }, [router]);

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-purple-600 via-purple-700 to-pink-500">
      <div className="text-center text-white p-8">
        <h1 className="text-5xl font-bold mb-4">SA Tutor Finder</h1>
        <p className="text-xl mb-8">Redirecting to app...</p>
        <p className="text-sm">If not redirected, <a href="/app" className="underline">click here</a></p>
      </div>
    </div>
  )
}
