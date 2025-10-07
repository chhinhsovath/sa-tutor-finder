import { PrismaClient } from '@prisma/client';
import * as bcrypt from 'bcryptjs';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Starting database seed...');

  // Hash password for all test accounts
  const passwordHash = await bcrypt.hash('password123', 10);

  // Clear existing data (in reverse order of dependencies)
  console.log('🧹 Clearing existing data...');
  await prisma.notifications.deleteMany();
  await prisma.reviews.deleteMany();
  await prisma.messages.deleteMany();
  await prisma.transactions.deleteMany();
  await prisma.sessions.deleteMany();
  await prisma.availability_slots.deleteMany();
  await prisma.students.deleteMany();
  await prisma.mentors.deleteMany();
  await prisma.counselors.deleteMany();
  await prisma.admins.deleteMany();

  // Create mentors
  console.log('👨‍🏫 Creating mentors...');
  const mentors = await Promise.all([
    prisma.mentors.create({
      data: {
        name: 'Sarah Johnson',
        email: 'sarah@example.com',
        password_hash: passwordHash,
        english_level: 'C2',
        contact: 'telegram.me/sarahj',
        bio: 'Experienced English teacher with 10+ years of teaching experience',
        hourly_rate: 25.00,
        total_sessions: 45,
        average_rating: 4.8
      }
    }),
    prisma.mentors.create({
      data: {
        name: 'Michael Chen',
        email: 'michael@example.com',
        password_hash: passwordHash,
        english_level: 'C1',
        contact: 'telegram.me/michaelc',
        bio: 'TOEFL and IELTS preparation specialist',
        hourly_rate: 30.00,
        total_sessions: 32,
        average_rating: 4.9
      }
    }),
    prisma.mentors.create({
      data: {
        name: 'Emma Wilson',
        email: 'emma@example.com',
        password_hash: passwordHash,
        english_level: 'B2',
        contact: 'telegram.me/emmaw',
        bio: 'Conversational English expert, friendly and patient',
        hourly_rate: 20.00,
        total_sessions: 28,
        average_rating: 4.7
      }
    }),
    prisma.mentors.create({
      data: {
        name: 'David Kim',
        email: 'david@example.com',
        password_hash: passwordHash,
        english_level: 'C1',
        contact: 'telegram.me/davidk',
        bio: 'Business English and professional communication',
        hourly_rate: 28.00,
        total_sessions: 15,
        average_rating: 4.6
      }
    }),
    prisma.mentors.create({
      data: {
        name: 'Lisa Anderson',
        email: 'lisa@example.com',
        password_hash: passwordHash,
        english_level: 'B2',
        contact: 'telegram.me/lisaa',
        bio: 'Kids and teenagers English tutor',
        hourly_rate: 22.00,
        total_sessions: 0,
        average_rating: null
      }
    })
  ]);

  // Create availability slots for mentors
  console.log('📅 Creating availability slots...');
  const availabilityData = [
    // Sarah - Available Mon/Wed/Fri mornings
    { mentor_id: mentors[0].id, day_of_week: 1, start_time: '09:00', end_time: '12:00' },
    { mentor_id: mentors[0].id, day_of_week: 3, start_time: '09:00', end_time: '12:00' },
    { mentor_id: mentors[0].id, day_of_week: 5, start_time: '09:00', end_time: '12:00' },
    // Michael - Available Tue/Thu evenings
    { mentor_id: mentors[1].id, day_of_week: 2, start_time: '18:00', end_time: '21:00' },
    { mentor_id: mentors[1].id, day_of_week: 4, start_time: '18:00', end_time: '21:00' },
    // Emma - Available weekends
    { mentor_id: mentors[2].id, day_of_week: 6, start_time: '10:00', end_time: '16:00' },
    { mentor_id: mentors[2].id, day_of_week: 7, start_time: '10:00', end_time: '16:00' },
    // David - Available Mon-Fri afternoons
    { mentor_id: mentors[3].id, day_of_week: 1, start_time: '14:00', end_time: '17:00' },
    { mentor_id: mentors[3].id, day_of_week: 2, start_time: '14:00', end_time: '17:00' },
    { mentor_id: mentors[3].id, day_of_week: 3, start_time: '14:00', end_time: '17:00' },
    { mentor_id: mentors[3].id, day_of_week: 4, start_time: '14:00', end_time: '17:00' },
    { mentor_id: mentors[3].id, day_of_week: 5, start_time: '14:00', end_time: '17:00' },
    // Lisa - Available Mon/Wed/Fri afternoons
    { mentor_id: mentors[4].id, day_of_week: 1, start_time: '15:00', end_time: '18:00' },
    { mentor_id: mentors[4].id, day_of_week: 3, start_time: '15:00', end_time: '18:00' },
    { mentor_id: mentors[4].id, day_of_week: 5, start_time: '15:00', end_time: '18:00' },
  ];

  for (const slot of availabilityData) {
    await prisma.availability_slots.create({
      data: {
        mentor_id: slot.mentor_id,
        day_of_week: slot.day_of_week,
        start_time: new Date(`1970-01-01T${slot.start_time}:00`),
        end_time: new Date(`1970-01-01T${slot.end_time}:00`)
      }
    });
  }

  // Create students
  console.log('👨‍🎓 Creating students...');
  const students = await Promise.all([
    prisma.students.create({
      data: {
        name: 'John Smith',
        email: 'john@example.com',
        password_hash: passwordHash,
        english_level: 'A2',
        phone_number: '+855123456789',
        learning_goals: 'Improve conversational English for work',
        total_sessions: 12
      }
    }),
    prisma.students.create({
      data: {
        name: 'Maria Garcia',
        email: 'maria@example.com',
        password_hash: passwordHash,
        english_level: 'B1',
        phone_number: '+855987654321',
        learning_goals: 'Prepare for IELTS exam',
        total_sessions: 8
      }
    }),
    prisma.students.create({
      data: {
        name: 'Ahmed Hassan',
        email: 'ahmed@example.com',
        password_hash: passwordHash,
        english_level: 'A1',
        phone_number: '+855111222333',
        learning_goals: 'Learn basic English for travel',
        total_sessions: 3
      }
    }),
    prisma.students.create({
      data: {
        name: 'Yuki Tanaka',
        email: 'yuki@example.com',
        password_hash: passwordHash,
        english_level: 'B2',
        phone_number: '+855444555666',
        learning_goals: 'Business English communication',
        total_sessions: 0
      }
    })
  ]);

  // Create completed sessions
  console.log('📚 Creating sessions...');
  const today = new Date();
  const yesterday = new Date(today);
  yesterday.setDate(yesterday.getDate() - 1);
  const lastWeek = new Date(today);
  lastWeek.setDate(lastWeek.getDate() - 7);
  const nextWeek = new Date(today);
  nextWeek.setDate(nextWeek.getDate() + 7);

  const sessions = await Promise.all([
    // Completed sessions
    prisma.sessions.create({
      data: {
        student_id: students[0].id,
        mentor_id: mentors[0].id,
        session_date: lastWeek,
        start_time: new Date('1970-01-01T09:00:00'),
        end_time: new Date('1970-01-01T10:00:00'),
        duration_minutes: 60,
        status: 'completed',
        notes: 'First session - assessment',
        mentor_feedback: 'Great progress, keep practicing pronunciation'
      }
    }),
    prisma.sessions.create({
      data: {
        student_id: students[1].id,
        mentor_id: mentors[1].id,
        session_date: lastWeek,
        start_time: new Date('1970-01-01T18:00:00'),
        end_time: new Date('1970-01-01T19:30:00'),
        duration_minutes: 90,
        status: 'completed',
        notes: 'IELTS speaking practice',
        mentor_feedback: 'Excellent vocabulary, work on fluency'
      }
    }),
    // Confirmed upcoming session
    prisma.sessions.create({
      data: {
        student_id: students[0].id,
        mentor_id: mentors[0].id,
        session_date: nextWeek,
        start_time: new Date('1970-01-01T09:00:00'),
        end_time: new Date('1970-01-01T10:00:00'),
        duration_minutes: 60,
        status: 'confirmed',
        notes: 'Continue with conversation practice'
      }
    }),
    // Pending session
    prisma.sessions.create({
      data: {
        student_id: students[2].id,
        mentor_id: mentors[2].id,
        session_date: nextWeek,
        start_time: new Date('1970-01-01T10:00:00'),
        end_time: new Date('1970-01-01T11:00:00'),
        duration_minutes: 60,
        status: 'pending',
        notes: 'Beginner lesson - introductions'
      }
    })
  ]);

  // Create reviews
  console.log('⭐ Creating reviews...');
  await Promise.all([
    prisma.reviews.create({
      data: {
        session_id: sessions[0].id,
        student_id: students[0].id,
        mentor_id: mentors[0].id,
        rating: 5,
        comment: 'Excellent teacher! Very patient and helpful.'
      }
    }),
    prisma.reviews.create({
      data: {
        session_id: sessions[1].id,
        student_id: students[1].id,
        mentor_id: mentors[1].id,
        rating: 5,
        comment: 'Great IELTS preparation techniques. Highly recommend!'
      }
    })
  ]);

  // Create messages
  console.log('💬 Creating messages...');
  await Promise.all([
    prisma.messages.create({
      data: {
        sender_id: students[0].id,
        sender_type: 'student',
        recipient_id: mentors[0].id,
        recipient_type: 'mentor',
        content: 'Hi Sarah, looking forward to our next session!',
        is_read: true
      }
    }),
    prisma.messages.create({
      data: {
        sender_id: mentors[0].id,
        sender_type: 'mentor',
        recipient_id: students[0].id,
        recipient_type: 'student',
        content: 'Me too! Please review the vocabulary list I sent.',
        is_read: true
      }
    }),
    prisma.messages.create({
      data: {
        sender_id: students[2].id,
        sender_type: 'student',
        recipient_id: mentors[2].id,
        recipient_type: 'mentor',
        content: 'Can we reschedule to 11am?',
        is_read: false
      }
    })
  ]);

  // Create counselor
  console.log('👨‍💼 Creating counselor...');
  await prisma.counselors.create({
    data: {
      name: 'Dr. Jennifer Lee',
      email: 'jennifer@example.com',
      password_hash: passwordHash,
      phone_number: '+855777888999',
      specialization: 'Educational psychology and career guidance'
    }
  });

  // Create admin
  console.log('👑 Creating admin...');
  await prisma.admins.create({
    data: {
      name: 'Admin User',
      email: 'admin@example.com',
      password_hash: passwordHash,
      role: 'admin'
    }
  });

  console.log('✅ Seed completed successfully!');
  console.log('\n📝 Test Accounts (password: password123):');
  console.log('Mentors:');
  console.log('  - sarah@example.com');
  console.log('  - michael@example.com');
  console.log('  - emma@example.com');
  console.log('  - david@example.com');
  console.log('  - lisa@example.com');
  console.log('Students:');
  console.log('  - john@example.com');
  console.log('  - maria@example.com');
  console.log('  - ahmed@example.com');
  console.log('  - yuki@example.com');
  console.log('Counselor:');
  console.log('  - jennifer@example.com');
  console.log('Admin:');
  console.log('  - admin@example.com');
}

main()
  .catch((e) => {
    console.error('❌ Seed error:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
