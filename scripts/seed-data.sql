-- Seed realistic data for SA Tutor Finder
-- Password for all accounts: "password123"
-- Bcrypt hash: $2b$10$VD7v1hJ3.WKZbNFZBe5vS.y21U3VZPhhzUHp7v0Cpkod0qF.QTt3G

-- Clear existing data
DELETE FROM availability_slots;
DELETE FROM mentors;

-- Insert mentors with realistic data
INSERT INTO mentors (name, email, password_hash, english_level, contact, status) VALUES
('Sarah Johnson', 'sarah.johnson@example.com', '$2b$10$VD7v1hJ3.WKZbNFZBe5vS.y21U3VZPhhzUHp7v0Cpkod0qF.QTt3G', 'C1', 'telegram.me/sarahj', 'active'),
('Michael Chen', 'michael.chen@example.com', '$2b$10$VD7v1hJ3.WKZbNFZBe5vS.y21U3VZPhhzUHp7v0Cpkod0qF.QTt3G', 'B2', 'michael@telegram.com', 'active'),
('Emily Rodriguez', 'emily.r@example.com', '$2b$10$VD7v1hJ3.WKZbNFZBe5vS.y21U3VZPhhzUHp7v0Cpkod0qF.QTt3G', 'C2', '+855 12 345 678', 'active'),
('David Park', 'david.park@example.com', '$2b$10$VD7v1hJ3.WKZbNFZBe5vS.y21U3VZPhhzUHp7v0Cpkod0qF.QTt3G', 'B1', 'telegram.me/davidp', 'active'),
('Lisa Anderson', 'lisa.anderson@example.com', '$2b$10$VD7v1hJ3.WKZbNFZBe5vS.y21U3VZPhhzUHp7v0Cpkod0qF.QTt3G', 'C1', 'lisa@whatsapp.com', 'active'),
('James Wilson', 'james.w@example.com', '$2b$10$VD7v1hJ3.WKZbNFZBe5vS.y21U3VZPhhzUHp7v0Cpkod0qF.QTt3G', 'B2', '+855 98 765 432', 'inactive'),
('Maria Garcia', 'maria.garcia@example.com', '$2b$10$VD7v1hJ3.WKZbNFZBe5vS.y21U3VZPhhzUHp7v0Cpkod0qF.QTt3G', 'A2', 'telegram.me/mariag', 'active'),
('Robert Taylor', 'robert.t@example.com', '$2b$10$VD7v1hJ3.WKZbNFZBe5vS.y21U3VZPhhzUHp7v0Cpkod0qF.QTt3G', 'B2', 'robert@telegram.com', 'active'),
('Jennifer Lee', 'jennifer.lee@example.com', '$2b$10$VD7v1hJ3.WKZbNFZBe5vS.y21U3VZPhhzUHp7v0Cpkod0qF.QTt3G', 'C1', '+855 77 888 999', 'active'),
('Thomas Brown', 'thomas.brown@example.com', '$2b$10$VD7v1hJ3.WKZbNFZBe5vS.y21U3VZPhhzUHp7v0Cpkod0qF.QTt3G', 'B1', 'telegram.me/tombrown', 'active');

-- Insert availability slots for mentors
-- Sarah Johnson (C1) - Available Mon, Wed, Fri mornings
INSERT INTO availability_slots (mentor_id, day_of_week, start_time, end_time)
SELECT id, 1, '09:00'::TIME, '12:00'::TIME FROM mentors WHERE email = 'sarah.johnson@example.com'
UNION ALL
SELECT id, 3, '09:00'::TIME, '12:00'::TIME FROM mentors WHERE email = 'sarah.johnson@example.com'
UNION ALL
SELECT id, 5, '09:00'::TIME, '12:00'::TIME FROM mentors WHERE email = 'sarah.johnson@example.com';

-- Michael Chen (B2) - Available Tue, Thu evenings
INSERT INTO availability_slots (mentor_id, day_of_week, start_time, end_time)
SELECT id, 2, '18:00'::TIME, '21:00'::TIME FROM mentors WHERE email = 'michael.chen@example.com'
UNION ALL
SELECT id, 4, '18:00'::TIME, '21:00'::TIME FROM mentors WHERE email = 'michael.chen@example.com';

-- Emily Rodriguez (C2) - Available Mon-Fri afternoons
INSERT INTO availability_slots (mentor_id, day_of_week, start_time, end_time)
SELECT id, 1, '14:00'::TIME, '17:00'::TIME FROM mentors WHERE email = 'emily.r@example.com'
UNION ALL
SELECT id, 2, '14:00'::TIME, '17:00'::TIME FROM mentors WHERE email = 'emily.r@example.com'
UNION ALL
SELECT id, 3, '14:00'::TIME, '17:00'::TIME FROM mentors WHERE email = 'emily.r@example.com'
UNION ALL
SELECT id, 4, '14:00'::TIME, '17:00'::TIME FROM mentors WHERE email = 'emily.r@example.com'
UNION ALL
SELECT id, 5, '14:00'::TIME, '17:00'::TIME FROM mentors WHERE email = 'emily.r@example.com';

-- David Park (B1) - Available weekends
INSERT INTO availability_slots (mentor_id, day_of_week, start_time, end_time)
SELECT id, 6, '10:00'::TIME, '16:00'::TIME FROM mentors WHERE email = 'david.park@example.com'
UNION ALL
SELECT id, 7, '10:00'::TIME, '16:00'::TIME FROM mentors WHERE email = 'david.park@example.com';

-- Lisa Anderson (C1) - Available Mon, Wed, Fri evenings
INSERT INTO availability_slots (mentor_id, day_of_week, start_time, end_time)
SELECT id, 1, '18:30'::TIME, '20:30'::TIME FROM mentors WHERE email = 'lisa.anderson@example.com'
UNION ALL
SELECT id, 3, '18:30'::TIME, '20:30'::TIME FROM mentors WHERE email = 'lisa.anderson@example.com'
UNION ALL
SELECT id, 5, '18:30'::TIME, '20:30'::TIME FROM mentors WHERE email = 'lisa.anderson@example.com';

-- Robert Taylor (B2) - Available Tue, Thu mornings
INSERT INTO availability_slots (mentor_id, day_of_week, start_time, end_time)
SELECT id, 2, '08:00'::TIME, '11:00'::TIME FROM mentors WHERE email = 'robert.t@example.com'
UNION ALL
SELECT id, 4, '08:00'::TIME, '11:00'::TIME FROM mentors WHERE email = 'robert.t@example.com';

-- Jennifer Lee (C1) - Available Mon-Wed afternoons
INSERT INTO availability_slots (mentor_id, day_of_week, start_time, end_time)
SELECT id, 1, '13:00'::TIME, '16:00'::TIME FROM mentors WHERE email = 'jennifer.lee@example.com'
UNION ALL
SELECT id, 2, '13:00'::TIME, '16:00'::TIME FROM mentors WHERE email = 'jennifer.lee@example.com'
UNION ALL
SELECT id, 3, '13:00'::TIME, '16:00'::TIME FROM mentors WHERE email = 'jennifer.lee@example.com';

-- Thomas Brown (B1) - Available Thu, Fri evenings
INSERT INTO availability_slots (mentor_id, day_of_week, start_time, end_time)
SELECT id, 4, '19:00'::TIME, '21:00'::TIME FROM mentors WHERE email = 'thomas.brown@example.com'
UNION ALL
SELECT id, 5, '19:00'::TIME, '21:00'::TIME FROM mentors WHERE email = 'thomas.brown@example.com';

-- Display summary
SELECT
    'Total Mentors: ' || COUNT(*) as summary
FROM mentors
UNION ALL
SELECT
    'Active Mentors: ' || COUNT(*) as summary
FROM mentors WHERE status = 'active'
UNION ALL
SELECT
    'Total Availability Slots: ' || COUNT(*) as summary
FROM availability_slots;
