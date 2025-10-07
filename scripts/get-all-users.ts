import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function getAllUsers() {
  console.log('📋 Fetching all users from database...\n');

  // Fetch mentors
  const mentors = await prisma.mentors.findMany({
    select: {
      id: true,
      name: true,
      email: true,
      english_level: true,
      status: true,
      total_sessions: true,
      average_rating: true,
      created_at: true
    },
    orderBy: { name: 'asc' }
  });

  // Fetch students
  const students = await prisma.students.findMany({
    select: {
      id: true,
      name: true,
      email: true,
      english_level: true,
      status: true,
      total_sessions: true,
      created_at: true
    },
    orderBy: { name: 'asc' }
  });

  // Fetch counselors
  const counselors = await prisma.counselors.findMany({
    select: {
      id: true,
      name: true,
      email: true,
      specialization: true,
      status: true,
      created_at: true
    },
    orderBy: { name: 'asc' }
  });

  // Fetch admins
  const admins = await prisma.admins.findMany({
    select: {
      id: true,
      name: true,
      email: true,
      role: true,
      status: true,
      created_at: true
    },
    orderBy: { name: 'asc' }
  });

  // Display results
  console.log('👨‍🏫 MENTORS (' + mentors.length + ' total)');
  console.log('═'.repeat(80));
  mentors.forEach((m, i) => {
    console.log(`${i + 1}. ${m.name}`);
    console.log(`   Email: ${m.email}`);
    console.log(`   Level: ${m.english_level} | Status: ${m.status}`);
    console.log(`   Sessions: ${m.total_sessions} | Rating: ${m.average_rating || 'N/A'}`);
    console.log(`   Created: ${m.created_at.toISOString().split('T')[0]}`);
    console.log('');
  });

  console.log('\n👨‍🎓 STUDENTS (' + students.length + ' total)');
  console.log('═'.repeat(80));
  students.forEach((s, i) => {
    console.log(`${i + 1}. ${s.name}`);
    console.log(`   Email: ${s.email}`);
    console.log(`   Level: ${s.english_level} | Status: ${s.status}`);
    console.log(`   Sessions: ${s.total_sessions}`);
    console.log(`   Created: ${s.created_at.toISOString().split('T')[0]}`);
    console.log('');
  });

  console.log('\n👨‍💼 COUNSELORS (' + counselors.length + ' total)');
  console.log('═'.repeat(80));
  counselors.forEach((c, i) => {
    console.log(`${i + 1}. ${c.name}`);
    console.log(`   Email: ${c.email}`);
    console.log(`   Specialization: ${c.specialization || 'N/A'}`);
    console.log(`   Status: ${c.status}`);
    console.log(`   Created: ${c.created_at.toISOString().split('T')[0]}`);
    console.log('');
  });

  console.log('\n👑 ADMINS (' + admins.length + ' total)');
  console.log('═'.repeat(80));
  admins.forEach((a, i) => {
    console.log(`${i + 1}. ${a.name}`);
    console.log(`   Email: ${a.email}`);
    console.log(`   Role: ${a.role} | Status: ${a.status}`);
    console.log(`   Created: ${a.created_at.toISOString().split('T')[0]}`);
    console.log('');
  });

  console.log('\n📊 SUMMARY');
  console.log('═'.repeat(80));
  console.log(`Total Users: ${mentors.length + students.length + counselors.length + admins.length}`);
  console.log(`  - Mentors: ${mentors.length}`);
  console.log(`  - Students: ${students.length}`);
  console.log(`  - Counselors: ${counselors.length}`);
  console.log(`  - Admins: ${admins.length}`);
  console.log('\n🔑 Default password for all test accounts: password123\n');
}

getAllUsers()
  .catch((e) => {
    console.error('Error:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
