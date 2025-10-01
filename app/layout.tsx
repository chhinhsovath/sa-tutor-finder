import type { Metadata } from 'next'
import './globals.css'

export const metadata: Metadata = {
  title: 'SA Tutor Finder',
  description: 'Find tutors and mentors by availability and English level',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  )
}
