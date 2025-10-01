-- Create database schema for SA Tutor Finder
-- Run this on PostgreSQL database: sa_tutor_finder

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Drop tables if they exist (for clean re-runs)
DROP TABLE IF EXISTS availability_slots CASCADE;
DROP TABLE IF EXISTS mentors CASCADE;

-- Create mentors table
CREATE TABLE mentors (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    english_level VARCHAR(5) NOT NULL CHECK (english_level IN ('A1', 'A2', 'B1', 'B2', 'C1', 'C2')),
    contact VARCHAR(255),
    timezone VARCHAR(50) DEFAULT 'Asia/Phnom_Penh',
    status VARCHAR(10) DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create availability_slots table
CREATE TABLE availability_slots (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    mentor_id UUID REFERENCES mentors(id) ON DELETE CASCADE,
    day_of_week INT NOT NULL CHECK (day_of_week BETWEEN 1 AND 7),
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    CONSTRAINT valid_time_range CHECK (end_time > start_time)
);

-- Create indexes for faster queries
CREATE INDEX idx_mentors_email ON mentors(email);
CREATE INDEX idx_mentors_status ON mentors(status);
CREATE INDEX idx_mentors_english_level ON mentors(english_level);
CREATE INDEX idx_availability_mentor_id ON availability_slots(mentor_id);
CREATE INDEX idx_availability_day ON availability_slots(day_of_week);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply trigger to mentors table
CREATE TRIGGER update_mentors_updated_at BEFORE UPDATE ON mentors
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Insert sample data for testing
INSERT INTO mentors (name, email, password_hash, english_level, contact) VALUES
('John Doe', 'john@example.com', '$2a$10$example.hash.here', 'B2', 'telegram.me/johndoe'),
('Jane Smith', 'jane@example.com', '$2a$10$example.hash.here', 'C1', 'jane@telegram.com');

-- Insert sample availability
INSERT INTO availability_slots (mentor_id, day_of_week, start_time, end_time)
SELECT id, 1, '18:00'::TIME, '20:00'::TIME FROM mentors WHERE email = 'john@example.com'
UNION ALL
SELECT id, 3, '19:00'::TIME, '21:00'::TIME FROM mentors WHERE email = 'john@example.com'
UNION ALL
SELECT id, 2, '17:00'::TIME, '19:00'::TIME FROM mentors WHERE email = 'jane@example.com'
UNION ALL
SELECT id, 4, '18:30'::TIME, '20:30'::TIME FROM mentors WHERE email = 'jane@example.com';
