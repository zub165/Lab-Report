-- Create database
CREATE DATABASE IF NOT EXISTS Medi_Lab;
USE Medi_Lab;

-- Create Patients table
CREATE TABLE IF NOT EXISTS Patients (
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

-- Create Tests table
CREATE TABLE IF NOT EXISTS Tests (
    TestID INT AUTO_INCREMENT PRIMARY KEY,
    PatientID INT NOT NULL,
    TestType VARCHAR(50) NOT NULL,
    TestDate DATE NOT NULL,
    Priority ENUM('Normal', 'Urgent', 'Emergency') NOT NULL,
    Notes TEXT,
    Status ENUM('Pending', 'In Progress', 'Completed', 'Cancelled') NOT NULL DEFAULT 'Pending',
    Results TEXT,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID)
);

-- Create TestTypes table
CREATE TABLE IF NOT EXISTS TestTypes (
    TestTypeID INT AUTO_INCREMENT PRIMARY KEY,
    TestName VARCHAR(50) NOT NULL,
    Description TEXT,
    Price DECIMAL(10,2) NOT NULL,
    IsActive BOOLEAN DEFAULT TRUE,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create TestResults table
CREATE TABLE IF NOT EXISTS TestResults (
    ResultID INT AUTO_INCREMENT PRIMARY KEY,
    TestID INT NOT NULL,
    Parameter VARCHAR(50) NOT NULL,
    Value VARCHAR(100) NOT NULL,
    Unit VARCHAR(20),
    ReferenceRange VARCHAR(50),
    IsAbnormal BOOLEAN DEFAULT FALSE,
    Notes TEXT,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (TestID) REFERENCES Tests(TestID)
);

-- Create Users table
CREATE TABLE IF NOT EXISTS Users (
    UserID INT AUTO_INCREMENT PRIMARY KEY,
    Username VARCHAR(50) NOT NULL UNIQUE,
    Password VARCHAR(255) NOT NULL,
    FullName VARCHAR(100) NOT NULL,
    Role ENUM('Admin', 'Doctor', 'Lab Technician', 'Receptionist') NOT NULL,
    IsActive BOOLEAN DEFAULT TRUE,
    LastLogin TIMESTAMP,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Create Appointments table
CREATE TABLE IF NOT EXISTS Appointments (
    AppointmentID INT AUTO_INCREMENT PRIMARY KEY,
    PatientID INT NOT NULL,
    TestID INT,
    AppointmentDate DATE NOT NULL,
    AppointmentTime TIME NOT NULL,
    Status ENUM('Scheduled', 'Completed', 'Cancelled', 'No Show') NOT NULL DEFAULT 'Scheduled',
    Notes TEXT,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID),
    FOREIGN KEY (TestID) REFERENCES Tests(TestID)
);

-- Create Payments table
CREATE TABLE IF NOT EXISTS Payments (
    PaymentID INT AUTO_INCREMENT PRIMARY KEY,
    TestID INT NOT NULL,
    Amount DECIMAL(10,2) NOT NULL,
    PaymentDate TIMESTAMP NOT NULL,
    PaymentMethod ENUM('Cash', 'Card', 'Insurance') NOT NULL,
    Status ENUM('Pending', 'Completed', 'Failed', 'Refunded') NOT NULL,
    TransactionID VARCHAR(100),
    Notes TEXT,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (TestID) REFERENCES Tests(TestID)
);

-- Insert default test types
INSERT INTO TestTypes (TestName, Description, Price) VALUES
('Blood Test', 'Complete Blood Count (CBC)', 50.00),
('Urine Analysis', 'Complete Urine Analysis', 30.00),
('X-Ray', 'Chest X-Ray', 100.00),
('MRI', 'Magnetic Resonance Imaging', 500.00),
('CT Scan', 'Computed Tomography Scan', 400.00),
('Ultrasound', 'Abdominal Ultrasound', 200.00),
('ECG', 'Electrocardiogram', 80.00),
('Lipid Profile', 'Cholesterol and Triglycerides Test', 60.00),
('Diabetes Test', 'Blood Glucose Test', 40.00),
('Thyroid Test', 'Thyroid Function Test', 70.00);

-- Insert default admin user
INSERT INTO Users (Username, Password, FullName, Role) VALUES
('admin', '$2b$10$YourHashedPasswordHere', 'System Administrator', 'Admin'); 