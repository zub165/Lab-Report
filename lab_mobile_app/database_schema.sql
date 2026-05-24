-- Lab Mobile App Database Schema
-- Complete SQL schema based on the data structure

-- Enable foreign key constraints
PRAGMA foreign_keys = ON;

-- Create Users table
CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id VARCHAR(20) UNIQUE NOT NULL,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    hashed_password VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL CHECK (role IN ('admin', 'doctor', 'technician', 'receptionist')),
    is_active BOOLEAN DEFAULT TRUE,
    last_login TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create Patients table
CREATE TABLE patients (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    patient_id VARCHAR(20) UNIQUE NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender VARCHAR(10) NOT NULL CHECK (gender IN ('Male', 'Female', 'Other')),
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(100),
    address TEXT,
    emergency_contact VARCHAR(20),
    medical_history TEXT,
    blood_type VARCHAR(5),
    insurance_info TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create Tests table
CREATE TABLE tests (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    test_id VARCHAR(20) UNIQUE NOT NULL,
    patient_id VARCHAR(20) NOT NULL,
    test_type VARCHAR(50) NOT NULL,
    test_name VARCHAR(100) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'Pending' CHECK (status IN ('Pending', 'In Progress', 'Completed', 'Cancelled')),
    priority VARCHAR(20) NOT NULL DEFAULT 'Normal' CHECK (priority IN ('Normal', 'Urgent', 'Emergency')),
    ordered_by VARCHAR(100),
    ordered_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_date TIMESTAMP,
    results TEXT,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE
);

-- Create Test Results table
CREATE TABLE test_results (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    result_id VARCHAR(20) UNIQUE NOT NULL,
    test_id VARCHAR(20) NOT NULL,
    parameter VARCHAR(100) NOT NULL,
    value VARCHAR(50) NOT NULL,
    unit VARCHAR(20),
    reference_range VARCHAR(50),
    is_abnormal BOOLEAN DEFAULT FALSE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (test_id) REFERENCES tests(test_id) ON DELETE CASCADE
);

-- Create Appointments table
CREATE TABLE appointments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    appointment_id VARCHAR(20) UNIQUE NOT NULL,
    patient_id VARCHAR(20) NOT NULL,
    appointment_date DATE NOT NULL,
    appointment_time TIME NOT NULL,
    test_type VARCHAR(50) NOT NULL,
    doctor_name VARCHAR(100),
    status VARCHAR(20) NOT NULL DEFAULT 'Scheduled' CHECK (status IN ('Scheduled', 'Completed', 'Cancelled', 'No Show')),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE
);

-- Create Payments table
CREATE TABLE payments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    payment_id VARCHAR(20) UNIQUE NOT NULL,
    test_id VARCHAR(20) NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_method VARCHAR(20) NOT NULL CHECK (payment_method IN ('Cash', 'Card', 'Insurance', 'Bank Transfer')),
    status VARCHAR(20) NOT NULL DEFAULT 'Pending' CHECK (status IN ('Pending', 'Completed', 'Failed', 'Refunded')),
    transaction_id VARCHAR(50),
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (test_id) REFERENCES tests(test_id) ON DELETE CASCADE
);

-- Create Report Templates table
CREATE TABLE report_templates (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    template_id VARCHAR(20) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    test_type VARCHAR(50) NOT NULL,
    description TEXT,
    header_template TEXT,
    footer_template TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create Report Fields table
CREATE TABLE report_fields (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    field_id VARCHAR(20) UNIQUE NOT NULL,
    template_id VARCHAR(20) NOT NULL,
    name VARCHAR(50) NOT NULL,
    label VARCHAR(100) NOT NULL,
    type VARCHAR(20) NOT NULL CHECK (type IN ('text', 'number', 'textarea', 'select', 'date')),
    unit VARCHAR(20),
    normal_range VARCHAR(50),
    default_value VARCHAR(50),
    is_required BOOLEAN DEFAULT TRUE,
    field_order INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (template_id) REFERENCES report_templates(template_id) ON DELETE CASCADE
);

-- Create Reports table
CREATE TABLE reports (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    report_id VARCHAR(20) UNIQUE NOT NULL,
    test_id VARCHAR(20) NOT NULL,
    template_id VARCHAR(20) NOT NULL,
    patient_name VARCHAR(100) NOT NULL,
    test_type VARCHAR(50) NOT NULL,
    test_date DATE NOT NULL,
    field_values TEXT NOT NULL, -- JSON format
    doctor_name VARCHAR(100),
    technician_name VARCHAR(100),
    status VARCHAR(20) NOT NULL DEFAULT 'Draft' CHECK (status IN ('Draft', 'Completed', 'Reviewed')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (test_id) REFERENCES tests(test_id) ON DELETE CASCADE,
    FOREIGN KEY (template_id) REFERENCES report_templates(template_id) ON DELETE CASCADE
);

-- Create Settings table
CREATE TABLE settings (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    setting_id VARCHAR(20) UNIQUE NOT NULL,
    setting_key VARCHAR(100) UNIQUE NOT NULL,
    setting_value TEXT NOT NULL,
    setting_type VARCHAR(20) NOT NULL CHECK (setting_type IN ('string', 'number', 'boolean', 'json')),
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create Audit Logs table
CREATE TABLE audit_logs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    log_id VARCHAR(20) UNIQUE NOT NULL,
    user_id VARCHAR(20),
    action VARCHAR(50) NOT NULL CHECK (action IN ('CREATE', 'UPDATE', 'DELETE', 'LOGIN', 'LOGOUT')),
    table_name VARCHAR(50) NOT NULL,
    record_id VARCHAR(20) NOT NULL,
    old_values TEXT, -- JSON format
    new_values TEXT, -- JSON format
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL
);

-- Create Notifications table
CREATE TABLE notifications (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    notification_id VARCHAR(20) UNIQUE NOT NULL,
    user_id VARCHAR(20) NOT NULL,
    title VARCHAR(100) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(20) NOT NULL DEFAULT 'info' CHECK (type IN ('info', 'warning', 'error', 'success')),
    is_read BOOLEAN DEFAULT FALSE,
    related_id VARCHAR(20),
    related_type VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    read_at TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Create indexes for better performance
CREATE INDEX idx_patients_patient_id ON patients(patient_id);
CREATE INDEX idx_patients_full_name ON patients(full_name);
CREATE INDEX idx_patients_phone ON patients(phone);
CREATE INDEX idx_patients_email ON patients(email);

CREATE INDEX idx_tests_test_id ON tests(test_id);
CREATE INDEX idx_tests_patient_id ON tests(patient_id);
CREATE INDEX idx_tests_status ON tests(status);
CREATE INDEX idx_tests_test_type ON tests(test_type);
CREATE INDEX idx_tests_ordered_date ON tests(ordered_date);

CREATE INDEX idx_test_results_result_id ON test_results(result_id);
CREATE INDEX idx_test_results_test_id ON test_results(test_id);
CREATE INDEX idx_test_results_parameter ON test_results(parameter);

CREATE INDEX idx_appointments_appointment_id ON appointments(appointment_id);
CREATE INDEX idx_appointments_patient_id ON appointments(patient_id);
CREATE INDEX idx_appointments_date ON appointments(appointment_date);
CREATE INDEX idx_appointments_status ON appointments(status);

CREATE INDEX idx_payments_payment_id ON payments(payment_id);
CREATE INDEX idx_payments_test_id ON payments(test_id);
CREATE INDEX idx_payments_status ON payments(status);
CREATE INDEX idx_payments_payment_date ON payments(payment_date);

CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);

CREATE INDEX idx_reports_report_id ON reports(report_id);
CREATE INDEX idx_reports_test_id ON reports(test_id);
CREATE INDEX idx_reports_status ON reports(status);

CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_table_name ON audit_logs(table_name);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at);

CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);
CREATE INDEX idx_notifications_created_at ON notifications(created_at);

-- Insert default settings
INSERT INTO settings (setting_id, setting_key, setting_value, setting_type, description) VALUES
('SET001', 'lab_name', 'Saied Laboratory', 'string', 'Laboratory name'),
('SET002', 'lab_address', '123 Medical Center, City, Country', 'string', 'Laboratory address'),
('SET003', 'lab_phone', '+1234567890', 'string', 'Laboratory phone number'),
('SET004', 'lab_email', 'info@saiedlab.com', 'string', 'Laboratory email'),
('SET005', 'currency', 'USD', 'string', 'Default currency'),
('SET006', 'timezone', 'UTC', 'string', 'Default timezone'),
('SET007', 'auto_generate_ids', 'true', 'boolean', 'Auto-generate IDs for new records'),
('SET008', 'max_file_size', '10485760', 'number', 'Maximum file upload size in bytes'),
('SET009', 'session_timeout', '3600', 'number', 'Session timeout in seconds'),
('SET010', 'enable_notifications', 'true', 'boolean', 'Enable system notifications');

-- Insert default report templates
INSERT INTO report_templates (template_id, name, test_type, description, header_template, footer_template) VALUES
('TEMP001', 'Blood Test (CBC)', 'Blood Test (CBC)', 'Complete Blood Count Test Report', 'COMPLETE BLOOD COUNT (CBC)\nLaboratory Report', 'Report generated on: {date}\nReviewed by: {doctor}'),
('TEMP002', 'Urine Analysis', 'Urine Analysis', 'Urine Analysis Test Report', 'URINE ANALYSIS\nLaboratory Report', 'Report generated on: {date}\nReviewed by: {doctor}'),
('TEMP003', 'Lipid Profile', 'Lipid Profile', 'Lipid Profile Test Report', 'LIPID PROFILE\nLaboratory Report', 'Report generated on: {date}\nReviewed by: {doctor}');

-- Insert default report fields for CBC template
INSERT INTO report_fields (field_id, template_id, name, label, type, unit, normal_range, default_value, is_required, field_order) VALUES
('FIELD001', 'TEMP001', 'hemoglobin', 'Hemoglobin', 'number', 'g/dL', '12.0-16.0', '0', true, 1),
('FIELD002', 'TEMP001', 'wbc', 'White Blood Cells', 'number', 'cells/μL', '4,500-11,000', '0', true, 2),
('FIELD003', 'TEMP001', 'rbc', 'Red Blood Cells', 'number', 'million/μL', '4.5-5.5', '0', true, 3),
('FIELD004', 'TEMP001', 'platelets', 'Platelets', 'number', 'cells/μL', '150,000-450,000', '0', true, 4),
('FIELD005', 'TEMP001', 'hematocrit', 'Hematocrit', 'number', '%', '36-46', '0', true, 5),
('FIELD006', 'TEMP001', 'mcv', 'Mean Corpuscular Volume', 'number', 'fL', '80-100', '0', true, 6),
('FIELD007', 'TEMP001', 'mch', 'Mean Corpuscular Hemoglobin', 'number', 'pg', '27-32', '0', true, 7),
('FIELD008', 'TEMP001', 'mchc', 'Mean Corpuscular Hemoglobin Concentration', 'number', 'g/dL', '32-36', '0', true, 8),
('FIELD009', 'TEMP001', 'comments', 'Comments', 'textarea', NULL, NULL, NULL, false, 9);

-- Insert default report fields for Urine Analysis template
INSERT INTO report_fields (field_id, template_id, name, label, type, unit, normal_range, default_value, is_required, field_order) VALUES
('FIELD010', 'TEMP002', 'color', 'Color', 'text', NULL, 'Yellow', 'Yellow', true, 1),
('FIELD011', 'TEMP002', 'appearance', 'Appearance', 'text', NULL, 'Clear', 'Clear', true, 2),
('FIELD012', 'TEMP002', 'ph', 'pH', 'number', NULL, '4.5-8.0', '0', true, 3),
('FIELD013', 'TEMP002', 'specific_gravity', 'Specific Gravity', 'number', NULL, '1.005-1.030', '0', true, 4),
('FIELD014', 'TEMP002', 'protein', 'Protein', 'text', NULL, 'Negative', 'Negative', true, 5),
('FIELD015', 'TEMP002', 'glucose', 'Glucose', 'text', NULL, 'Negative', 'Negative', true, 6),
('FIELD016', 'TEMP002', 'ketones', 'Ketones', 'text', NULL, 'Negative', 'Negative', true, 7),
('FIELD017', 'TEMP002', 'blood', 'Blood', 'text', NULL, 'Negative', 'Negative', true, 8),
('FIELD018', 'TEMP002', 'leukocytes', 'Leukocytes', 'text', NULL, 'Negative', 'Negative', true, 9),
('FIELD019', 'TEMP002', 'nitrites', 'Nitrites', 'text', NULL, 'Negative', 'Negative', true, 10),
('FIELD020', 'TEMP002', 'comments', 'Comments', 'textarea', NULL, NULL, NULL, false, 11);

-- Insert default report fields for Lipid Profile template
INSERT INTO report_fields (field_id, template_id, name, label, type, unit, normal_range, default_value, is_required, field_order) VALUES
('FIELD021', 'TEMP003', 'total_cholesterol', 'Total Cholesterol', 'number', 'mg/dL', '<200', '0', true, 1),
('FIELD022', 'TEMP003', 'hdl', 'HDL Cholesterol', 'number', 'mg/dL', '>40', '0', true, 2),
('FIELD023', 'TEMP003', 'ldl', 'LDL Cholesterol', 'number', 'mg/dL', '<100', '0', true, 3),
('FIELD024', 'TEMP003', 'triglycerides', 'Triglycerides', 'number', 'mg/dL', '<150', '0', true, 4),
('FIELD025', 'TEMP003', 'vldl', 'VLDL Cholesterol', 'number', 'mg/dL', '<30', '0', true, 5),
('FIELD026', 'TEMP003', 'comments', 'Comments', 'textarea', NULL, NULL, NULL, false, 6);

-- Create default admin user (password: admin123)
INSERT INTO users (user_id, username, email, full_name, hashed_password, role) VALUES
('U001', 'admin', 'admin@saiedlab.com', 'System Administrator', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj4J/HS.i8mG', 'admin');

-- Create triggers for updated_at timestamps
CREATE TRIGGER update_patients_updated_at 
    AFTER UPDATE ON patients
    BEGIN
        UPDATE patients SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
    END;

CREATE TRIGGER update_tests_updated_at 
    AFTER UPDATE ON tests
    BEGIN
        UPDATE tests SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
    END;

CREATE TRIGGER update_appointments_updated_at 
    AFTER UPDATE ON appointments
    BEGIN
        UPDATE appointments SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
    END;

CREATE TRIGGER update_payments_updated_at 
    AFTER UPDATE ON payments
    BEGIN
        UPDATE payments SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
    END;

CREATE TRIGGER update_users_updated_at 
    AFTER UPDATE ON users
    BEGIN
        UPDATE users SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
    END;

CREATE TRIGGER update_report_templates_updated_at 
    AFTER UPDATE ON report_templates
    BEGIN
        UPDATE report_templates SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
    END;

CREATE TRIGGER update_reports_updated_at 
    AFTER UPDATE ON reports
    BEGIN
        UPDATE reports SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
    END;

CREATE TRIGGER update_settings_updated_at 
    AFTER UPDATE ON settings
    BEGIN
        UPDATE settings SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
    END;

-- Create view for test summary
CREATE VIEW test_summary AS
SELECT 
    t.test_id,
    t.test_name,
    t.test_type,
    t.status,
    t.priority,
    t.ordered_date,
    t.completed_date,
    p.patient_id,
    p.full_name as patient_name,
    p.phone as patient_phone,
    u.full_name as ordered_by_doctor
FROM tests t
JOIN patients p ON t.patient_id = p.patient_id
LEFT JOIN users u ON t.ordered_by = u.username;

-- Create view for payment summary
CREATE VIEW payment_summary AS
SELECT 
    p.payment_id,
    p.amount,
    p.payment_method,
    p.status,
    p.payment_date,
    t.test_id,
    t.test_name,
    t.test_type,
    pat.patient_id,
    pat.full_name as patient_name
FROM payments p
JOIN tests t ON p.test_id = t.test_id
JOIN patients pat ON t.patient_id = pat.patient_id;

-- Create view for appointment summary
CREATE VIEW appointment_summary AS
SELECT 
    a.appointment_id,
    a.appointment_date,
    a.appointment_time,
    a.test_type,
    a.status,
    a.doctor_name,
    p.patient_id,
    p.full_name as patient_name,
    p.phone as patient_phone
FROM appointments a
JOIN patients p ON a.patient_id = p.patient_id;
