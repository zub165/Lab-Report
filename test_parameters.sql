-- Create TestParameters table
CREATE TABLE IF NOT EXISTS TestParameters (
    ParameterID INT AUTO_INCREMENT PRIMARY KEY,
    TestTypeID INT NOT NULL,
    ParameterName VARCHAR(100) NOT NULL,
    Unit VARCHAR(20),
    MinValue DECIMAL(10,3),
    MaxValue DECIMAL(10,3),
    ReferenceRange VARCHAR(100),
    Description TEXT,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (TestTypeID) REFERENCES TestTypes(TestTypeID)
);

-- Clear existing test types
TRUNCATE TABLE TestTypes;

-- Insert Complete Blood Count (CBC) test type and parameters
INSERT INTO TestTypes (TestName, Description, Price) VALUES
('Complete Blood Count', 'CBC with differential count', 80.00);

SET @cbc_id = LAST_INSERT_ID();

INSERT INTO TestParameters (TestTypeID, ParameterName, Unit, MinValue, MaxValue, ReferenceRange) VALUES
(@cbc_id, 'Hemoglobin', 'g/dL', 13.0, 17.0, '13.0-17.0'),
(@cbc_id, 'RBC Count', 'million/µL', 4.5, 5.9, '4.5-5.9'),
(@cbc_id, 'WBC Count', 'K/µL', 4.5, 11.0, '4.5-11.0'),
(@cbc_id, 'Platelets', 'K/µL', 150, 450, '150-450'),
(@cbc_id, 'Hematocrit', '%', 38.8, 50.0, '38.8-50.0'),
(@cbc_id, 'MCV', 'fL', 80, 96, '80-96'),
(@cbc_id, 'MCH', 'pg', 27, 33, '27-33'),
(@cbc_id, 'MCHC', 'g/dL', 33, 36, '33-36');

-- Insert Lipid Profile test type and parameters
INSERT INTO TestTypes (TestName, Description, Price) VALUES
('Lipid Profile', 'Complete lipid panel test', 90.00);

SET @lipid_id = LAST_INSERT_ID();

INSERT INTO TestParameters (TestTypeID, ParameterName, Unit, MinValue, MaxValue, ReferenceRange) VALUES
(@lipid_id, 'Total Cholesterol', 'mg/dL', NULL, 200, '<200'),
(@lipid_id, 'HDL Cholesterol', 'mg/dL', 40, NULL, '>40'),
(@lipid_id, 'LDL Cholesterol', 'mg/dL', NULL, 100, '<100'),
(@lipid_id, 'Triglycerides', 'mg/dL', NULL, 150, '<150');

-- Insert Liver Function Test (LFT) type and parameters
INSERT INTO TestTypes (TestName, Description, Price) VALUES
('Liver Function Test', 'Complete liver panel', 100.00);

SET @lft_id = LAST_INSERT_ID();

INSERT INTO TestParameters (TestTypeID, ParameterName, Unit, MinValue, MaxValue, ReferenceRange) VALUES
(@lft_id, 'Total Bilirubin', 'mg/dL', 0.3, 1.2, '0.3-1.2'),
(@lft_id, 'Direct Bilirubin', 'mg/dL', 0.0, 0.3, '0.0-0.3'),
(@lft_id, 'SGOT (AST)', 'U/L', 5, 40, '5-40'),
(@lft_id, 'SGPT (ALT)', 'U/L', 7, 56, '7-56'),
(@lft_id, 'Alkaline Phosphatase', 'U/L', 44, 147, '44-147'),
(@lft_id, 'Total Proteins', 'g/dL', 6.0, 8.3, '6.0-8.3'),
(@lft_id, 'Albumin', 'g/dL', 3.5, 5.0, '3.5-5.0'),
(@lft_id, 'Globulin', 'g/dL', 2.3, 3.5, '2.3-3.5');

-- Insert Kidney Function Test (KFT) type and parameters
INSERT INTO TestTypes (TestName, Description, Price) VALUES
('Kidney Function Test', 'Complete kidney panel', 95.00);

SET @kft_id = LAST_INSERT_ID();

INSERT INTO TestParameters (TestTypeID, ParameterName, Unit, MinValue, MaxValue, ReferenceRange) VALUES
(@kft_id, 'Blood Urea', 'mg/dL', 17, 43, '17-43'),
(@kft_id, 'Creatinine', 'mg/dL', 0.7, 1.3, '0.7-1.3'),
(@kft_id, 'Uric Acid', 'mg/dL', 3.4, 7.0, '3.4-7.0'),
(@kft_id, 'Sodium', 'mEq/L', 136, 145, '136-145'),
(@kft_id, 'Potassium', 'mEq/L', 3.5, 5.1, '3.5-5.1'),
(@kft_id, 'Chloride', 'mEq/L', 98, 107, '98-107');

-- Insert Thyroid Function Test type and parameters
INSERT INTO TestTypes (TestName, Description, Price) VALUES
('Thyroid Function Test', 'Complete thyroid panel', 85.00);

SET @tft_id = LAST_INSERT_ID();

INSERT INTO TestParameters (TestTypeID, ParameterName, Unit, MinValue, MaxValue, ReferenceRange) VALUES
(@tft_id, 'T3', 'ng/dL', 80, 200, '80-200'),
(@tft_id, 'T4', 'µg/dL', 5.1, 14.1, '5.1-14.1'),
(@tft_id, 'TSH', 'µIU/mL', 0.27, 4.2, '0.27-4.2'),
(@tft_id, 'Free T3', 'pg/mL', 2.3, 4.2, '2.3-4.2'),
(@tft_id, 'Free T4', 'ng/dL', 0.9, 1.7, '0.9-1.7');

-- Insert Blood Sugar Test type and parameters
INSERT INTO TestTypes (TestName, Description, Price) VALUES
('Blood Sugar Test', 'Diabetes screening and monitoring', 40.00);

SET @sugar_id = LAST_INSERT_ID();

INSERT INTO TestParameters (TestTypeID, ParameterName, Unit, MinValue, MaxValue, ReferenceRange) VALUES
(@sugar_id, 'Fasting Blood Sugar', 'mg/dL', 70, 100, '70-100'),
(@sugar_id, 'PP Blood Sugar', 'mg/dL', NULL, 140, '<140'),
(@sugar_id, 'Random Blood Sugar', 'mg/dL', 70, 140, '70-140'),
(@sugar_id, 'HbA1c', '%', NULL, 5.7, '<5.7');

-- Insert Urine Analysis test type and parameters
INSERT INTO TestTypes (TestName, Description, Price) VALUES
('Urine Analysis', 'Complete urine examination', 35.00);

SET @urine_id = LAST_INSERT_ID();

INSERT INTO TestParameters (TestTypeID, ParameterName, Unit, ReferenceRange) VALUES
(@urine_id, 'Color', NULL, 'Pale Yellow to Yellow'),
(@urine_id, 'Appearance', NULL, 'Clear'),
(@urine_id, 'pH', NULL, '4.6-8.0'),
(@urine_id, 'Specific Gravity', NULL, '1.005-1.030'),
(@urine_id, 'Protein', NULL, 'Negative'),
(@urine_id, 'Glucose', NULL, 'Negative'),
(@urine_id, 'Ketones', NULL, 'Negative'),
(@urine_id, 'Blood', NULL, 'Negative'),
(@urine_id, 'Bilirubin', NULL, 'Negative'),
(@urine_id, 'Urobilinogen', NULL, 'Normal'),
(@urine_id, 'Nitrite', NULL, 'Negative'),
(@urine_id, 'Leukocyte Esterase', NULL, 'Negative');

-- Insert Electrolytes test type and parameters
INSERT INTO TestTypes (TestName, Description, Price) VALUES
('Electrolytes', 'Complete electrolyte panel', 70.00);

SET @electrolytes_id = LAST_INSERT_ID();

INSERT INTO TestParameters (TestTypeID, ParameterName, Unit, MinValue, MaxValue, ReferenceRange) VALUES
(@electrolytes_id, 'Sodium', 'mEq/L', 136, 145, '136-145'),
(@electrolytes_id, 'Potassium', 'mEq/L', 3.5, 5.1, '3.5-5.1'),
(@electrolytes_id, 'Chloride', 'mEq/L', 98, 107, '98-107'),
(@electrolytes_id, 'Bicarbonate', 'mEq/L', 22, 29, '22-29'),
(@electrolytes_id, 'Calcium', 'mg/dL', 8.6, 10.3, '8.6-10.3'),
(@electrolytes_id, 'Phosphorus', 'mg/dL', 2.5, 4.5, '2.5-4.5'),
(@electrolytes_id, 'Magnesium', 'mg/dL', 1.7, 2.2, '1.7-2.2'); 