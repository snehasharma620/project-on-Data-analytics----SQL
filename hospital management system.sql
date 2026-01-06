-- SQL Code for Hospital Management System (Simplified - MySQL)

-- Drop tables if they exist to allow for re-running the script
DROP TABLE IF EXISTS Appointments;
DROP TABLE IF EXISTS Doctors;
DROP TABLE IF EXISTS Patients;

-- Patients Table
CREATE TABLE Patients (
    patient_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender ENUM('Male', 'Female', 'Other') NOT NULL,
    address VARCHAR(255),
    phone_number VARCHAR(20),
    email VARCHAR(100) UNIQUE,
    registration_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Doctors Table
CREATE TABLE Doctors (
    doctor_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    specialty VARCHAR(100) NOT NULL,
    phone_number VARCHAR(20),
    email VARCHAR(100) UNIQUE
);

-- Appointments Table
CREATE TABLE Appointments (
    appointment_id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    appointment_datetime DATETIME NOT NULL,
    reason_for_visit TEXT,
    status ENUM('Scheduled', 'Completed', 'Cancelled') NOT NULL DEFAULT 'Scheduled',
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id)
);

-- Insert Sample Data

-- Patients
INSERT INTO Patients (first_name, last_name, date_of_birth, gender, address, phone_number, email) VALUES
('Emily', 'White', '1990-03-15', 'Female', '123 Oak Ave, City', '999-888-7777', 'emily.w@example.com'),
('David', 'Green', '1985-11-22', 'Male', '456 Pine St, Town', '777-666-5555', 'david.g@example.com'),
('Sophia', 'Blue', '2000-07-01', 'Female', '789 Elm Rd, Village', '111-222-3333', 'sophia.b@example.com');

-- Doctors
INSERT INTO Doctors (first_name, last_name, specialty, phone_number, email) VALUES
('Dr. Anya', 'Sharma', 'Cardiology', '555-123-4567', 'anya.s@example.com'),
('Dr. Ben', 'Carter', 'Pediatrics', '555-987-6543', 'ben.c@example.com'),
('Dr. Chloe', 'Davis', 'Dermatology', '555-234-5678', 'chloe.d@example.com');

-- Appointments
INSERT INTO Appointments (patient_id, doctor_id, appointment_datetime, reason_for_visit, status) VALUES
(1, 1, '2024-07-10 09:00:00', 'Routine check-up', 'Scheduled'),
(2, 2, '2024-07-10 10:30:00', 'Child vaccination', 'Scheduled'),
(1, 3, '2024-07-11 14:00:00', 'Skin rash', 'Scheduled'),
(3, 1, '2024-07-12 11:00:00', 'Follow-up for heart condition', 'Scheduled');

-- Example Queries

-- 1. List all scheduled appointments for a specific date (e.g., '2024-07-10')
SELECT
    a.appointment_datetime,
    p.first_name AS patient_first_name,
    p.last_name AS patient_last_name,
    d.first_name AS doctor_first_name,
    d.last_name AS doctor_last_name,
    d.specialty,
    a.reason_for_visit,
    a.status
FROM Appointments a
JOIN Patients p ON a.patient_id = p.patient_id
JOIN Doctors d ON a.doctor_id = d.doctor_id
WHERE DATE(a.appointment_datetime) = '2024-07-10'
ORDER BY a.appointment_datetime;

-- 2. Find all patients seen by a specific doctor (e.g., Dr. Anya Sharma)
SELECT DISTINCT
    p.first_name,
    p.last_name,
    p.phone_number
FROM Patients p
JOIN Appointments a ON p.patient_id = a.patient_id
JOIN Doctors d ON a.doctor_id = d.doctor_id
WHERE d.first_name = 'Anya' AND d.last_name = 'Sharma';

-- 3. Count total appointments by doctor's specialty
SELECT
    d.specialty,
    COUNT(a.appointment_id) AS total_appointments
FROM Appointments a
JOIN Doctors d ON a.doctor_id = d.doctor_id
GROUP BY d.specialty
ORDER BY total_appointments DESC;

-- 4. Get a patient's full medical history (simplified - just appointment reasons here)
SELECT
    a.appointment_datetime,
    d.first_name AS doctor_first_name,
    d.last_name AS doctor_last_name,
    d.specialty,
    a.reason_for_visit,
    a.status
FROM Appointments a
JOIN Doctors d ON a.doctor_id = d.doctor_id
WHERE a.patient_id = (SELECT patient_id FROM Patients WHERE first_name = 'Emily' AND last_name = 'White')
ORDER BY a.appointment_datetime DESC;

-- 5. Find doctors with no scheduled appointments in the future
SELECT
    d.first_name,
    d.last_name,
    d.specialty
FROM Doctors d
LEFT JOIN Appointments a ON d.doctor_id = a.doctor_id AND a.appointment_datetime >= CURRENT_TIMESTAMP
WHERE a.appointment_id IS NULL;

-- 6. Cancel an appointment (example: appointment_id = 3)
-- UPDATE Appointments SET status = 'Cancelled' WHERE appointment_id = 3;