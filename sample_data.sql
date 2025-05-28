-- Insert sample patients
INSERT INTO patients (name, dob, gender, contact_number, email, address) VALUES
('John Smith', '1985-03-15', 'male', '+92-300-1234567', 'john.smith@email.com', 'House 123, Street 4, Islamabad'),
('Sarah Khan', '1990-07-22', 'female', '+92-321-9876543', 'sarah.k@email.com', 'Flat 45, Block B, Lahore'),
('Ali Ahmed', '1978-11-30', 'male', '+92-333-5557777', 'ali.ahmed@email.com', 'Plot 78, Sector F, Karachi');

-- Insert sample tests
INSERT INTO tests (patient_id, test_type, date, priority, status, notes) VALUES
(1, 'Complete Blood Count', CURDATE(), 'normal', 'pending', 'Routine checkup'),
(1, 'Blood Sugar Fasting', CURDATE(), 'urgent', 'pending', 'Patient is diabetic'),
(2, 'Thyroid Profile', CURDATE(), 'normal', 'pending', 'Follow-up test'),
(3, 'Lipid Profile', CURDATE(), 'emergency', 'pending', 'Chest pain complaint'); 