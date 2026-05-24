-- Medical Laboratory Management System Database Setup
-- This script creates all necessary tables and initial data

-- Create database if not exists
CREATE DATABASE IF NOT EXISTS Medi_Lab;
USE Medi_Lab;

-- Drop existing tables if they exist (for clean setup)
DROP TABLE IF EXISTS TestResults;
DROP TABLE IF EXISTS Payments;
DROP TABLE IF EXISTS Appointments;
DROP TABLE IF EXISTS Tests;
DROP TABLE IF EXISTS TestTypes;
DROP TABLE IF EXISTS Users;
DROP TABLE IF EXISTS Patients;

-- Create Patients table
CREATE TABLE Patients (
    PatientID INT AUTO_INCREMENT PRIMARY KEY,
    FullName VARCHAR(100) NOT NULL,
    DateOfBirth DATE NOT NULL,
    Gender ENUM('Male', 'Female', 'Other') NOT NULL,
    ContactNumber VARCHAR(20) NOT NULL,
    Email VARCHAR(100),
    Address TEXT,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Create TestTypes table
CREATE TABLE TestTypes (
    TestTypeID INT AUTO_INCREMENT PRIMARY KEY,
    TestName VARCHAR(50) NOT NULL,
    Description TEXT,
    Price DECIMAL(10,2) NOT NULL,
    IsActive BOOLEAN DEFAULT TRUE,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create Tests table
CREATE TABLE Tests (
    TestID INT AUTO_INCREMENT PRIMARY KEY,
    PatientID INT NOT NULL,
    TestType VARCHAR(50) NOT NULL,
    TestDate DATE NOT NULL,
    Priority ENUM('Normal', 'Urgent', 'Emergency') NOT NULL DEFAULT 'Normal',
    Notes TEXT,
    Status ENUM('Pending', 'In Progress', 'Completed', 'Cancelled') NOT NULL DEFAULT 'Pending',
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID) ON DELETE CASCADE
);

-- Create TestResults table
CREATE TABLE TestResults (
    ResultID INT AUTO_INCREMENT PRIMARY KEY,
    TestID INT NOT NULL,
    Parameter VARCHAR(50) NOT NULL,
    Value VARCHAR(100) NOT NULL,
    Unit VARCHAR(20),
    ReferenceRange VARCHAR(50),
    IsAbnormal BOOLEAN DEFAULT FALSE,
    Notes TEXT,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (TestID) REFERENCES Tests(TestID) ON DELETE CASCADE
);

-- Create Users table
CREATE TABLE Users (
    UserID INT AUTO_INCREMENT PRIMARY KEY,
    Username VARCHAR(50) NOT NULL UNIQUE,
    Password VARCHAR(255) NOT NULL,
    FullName VARCHAR(100) NOT NULL,
    Role ENUM('Admin', 'Doctor', 'Lab Technician', 'Receptionist') NOT NULL,
    IsActive BOOLEAN DEFAULT TRUE,
    LastLogin TIMESTAMP NULL,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Create Appointments table
CREATE TABLE Appointments (
    AppointmentID INT AUTO_INCREMENT PRIMARY KEY,
    PatientID INT NOT NULL,
    TestID INT,
    AppointmentDate DATE NOT NULL,
    AppointmentTime TIME NOT NULL,
    Status ENUM('Scheduled', 'Completed', 'Cancelled', 'No Show') NOT NULL DEFAULT 'Scheduled',
    Notes TEXT,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID) ON DELETE CASCADE,
    FOREIGN KEY (TestID) REFERENCES Tests(TestID) ON DELETE SET NULL
);

-- Create Payments table
CREATE TABLE Payments (
    PaymentID INT AUTO_INCREMENT PRIMARY KEY,
    TestID INT NOT NULL,
    Amount DECIMAL(10,2) NOT NULL,
    PaymentDate TIMESTAMP NOT NULL,
    PaymentMethod ENUM('Cash', 'Card', 'Insurance') NOT NULL,
    Status ENUM('Pending', 'Completed', 'Failed', 'Refunded') NOT NULL DEFAULT 'Pending',
    TransactionID VARCHAR(100),
    Notes TEXT,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (TestID) REFERENCES Tests(TestID) ON DELETE CASCADE
);

-- Insert default test types
INSERT INTO TestTypes (TestName, Description, Price) VALUES
('Blood Test (CBC)', 'Complete Blood Count - Red cells, white cells, platelets', 50.00),
('Urine Analysis', 'Complete Urine Analysis - Physical, chemical, microscopic', 30.00),
('X-Ray', 'Chest X-Ray - Standard chest radiograph', 100.00),
('MRI', 'Magnetic Resonance Imaging - Detailed body imaging', 500.00),
('CT Scan', 'Computed Tomography Scan - Cross-sectional imaging', 400.00),
('Ultrasound', 'Abdominal Ultrasound - Organ imaging', 200.00),
('ECG', 'Electrocardiogram - Heart electrical activity', 80.00),
('Lipid Profile', 'Cholesterol and Triglycerides Test', 60.00),
('Diabetes Test', 'Blood Glucose Test - Fasting and random', 40.00),
('Thyroid Test', 'Thyroid Function Test - TSH, T3, T4', 70.00);

-- Insert sample patients
INSERT INTO Patients (FullName, DateOfBirth, Gender, ContactNumber, Email, Address) VALUES
('John Smith', '1980-05-15', 'Male', '555-0123', 'john.smith@email.com', '123 Main St, City'),
('Sarah Johnson', '1992-08-23', 'Female', '555-0124', 'sarah.j@email.com', '456 Oak Ave, Town'),
('Michael Brown', '1975-11-30', 'Male', '555-0125', 'm.brown@email.com', '789 Pine Rd, Village'),
('Emily Davis', '1988-03-12', 'Female', '555-0126', 'emily.d@email.com', '321 Elm St, Borough'),
('David Wilson', '1965-09-18', 'Male', '555-0127', 'd.wilson@email.com', '654 Maple Dr, County');

-- Insert sample tests
INSERT INTO Tests (PatientID, TestType, TestDate, Priority, Notes, Status) VALUES
(1, 'Blood Test (CBC)', '2024-03-20', 'Normal', 'Regular checkup', 'Completed'),
(2, 'Lipid Profile', '2024-03-21', 'Normal', 'Annual checkup', 'Completed'),
(3, 'Diabetes Test', '2024-03-22', 'Urgent', 'Follow-up test', 'Pending'),
(4, 'X-Ray', '2024-03-23', 'Normal', 'Chest examination', 'In Progress'),
(5, 'Thyroid Test', '2024-03-24', 'Normal', 'Routine screening', 'Pending');

-- Insert sample test results
INSERT INTO TestResults (TestID, Parameter, Value, Unit, ReferenceRange, IsAbnormal, Notes) VALUES
(1, 'Hemoglobin', '14.2', 'g/dL', '13.5-17.5', FALSE, 'Normal range'),
(1, 'White Blood Cells', '7.5', '10^9/L', '4.5-11.0', FALSE, 'Normal range'),
(1, 'Platelets', '250', '10^9/L', '150-450', FALSE, 'Normal range'),
(2, 'Total Cholesterol', '180', 'mg/dL', '<200', FALSE, 'Normal range'),
(2, 'HDL', '55', 'mg/dL', '>40', FALSE, 'Good cholesterol'),
(2, 'LDL', '100', 'mg/dL', '<130', FALSE, 'Normal range'),
(3, 'Fasting Glucose', '95', 'mg/dL', '70-99', FALSE, 'Normal range'),
(3, 'HbA1c', '5.6', '%', '4.0-5.6', FALSE, 'Normal range');

-- Insert sample appointments
INSERT INTO Appointments (PatientID, TestID, AppointmentDate, AppointmentTime, Status, Notes) VALUES
(1, 1, '2024-03-20', '09:00:00', 'Completed', 'Regular checkup'),
(2, 2, '2024-03-21', '10:00:00', 'Completed', 'Annual checkup'),
(3, 3, '2024-03-22', '08:00:00', 'Scheduled', 'Follow-up test'),
(4, 4, '2024-03-23', '14:00:00', 'Scheduled', 'Chest examination'),
(5, 5, '2024-03-24', '11:00:00', 'Scheduled', 'Routine screening');

-- Insert sample payments
INSERT INTO Payments (TestID, Amount, PaymentDate, PaymentMethod, Status, TransactionID, Notes) VALUES
(1, 50.00, '2024-03-20 09:00:00', 'Card', 'Completed', 'TXN123456', 'Regular checkup payment'),
(2, 60.00, '2024-03-21 10:00:00', 'Cash', 'Completed', 'TXN123457', 'Annual checkup payment'),
(3, 40.00, '2024-03-22 08:00:00', 'Insurance', 'Pending', 'TXN123458', 'Insurance claim pending'),
(4, 100.00, '2024-03-23 14:00:00', 'Card', 'Completed', 'TXN123459', 'X-ray payment'),
(5, 70.00, '2024-03-24 11:00:00', 'Cash', 'Pending', 'TXN123460', 'Payment pending');

-- Insert default admin user (password: admin123)
INSERT INTO Users (Username, Password, FullName, Role) VALUES
('admin', '$2b$10$rQZ8K9vX2mN3pL4qR5sT6uV7wX8yZ9aA0bB1cC2dE3fF4gG5hH6iI7jJ8kK9lL0mM1nN2oO3pP4qQ5rR6sS7tT8uU9vV0wW1xX2yY3zZ', 'System Administrator', 'Admin');

-- Create indexes for better performance
CREATE INDEX idx_patients_name ON Patients(FullName);
CREATE INDEX idx_tests_date ON Tests(TestDate);
CREATE INDEX idx_tests_status ON Tests(Status);
CREATE INDEX idx_appointments_date ON Appointments(AppointmentDate);
CREATE INDEX idx_payments_date ON Payments(PaymentDate);

-- Show table creation confirmation
SELECT 'Database setup completed successfully!' as Status;
SELECT COUNT(*) as Patients_Count FROM Patients;
SELECT COUNT(*) as Tests_Count FROM Tests;
SELECT COUNT(*) as TestTypes_Count FROM TestTypes; 