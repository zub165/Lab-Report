-- Add Comprehensive Metabolic Panel (CMP)
INSERT INTO TestTypes (TestName, Description, Price) VALUES
('Comprehensive Metabolic Panel', 'Complete blood chemistry and liver function tests', 120.00);

SET @cmp_id = LAST_INSERT_ID();

INSERT INTO TestParameters (TestTypeID, ParameterName, Unit, MinValue, MaxValue, ReferenceRange) VALUES
(@cmp_id, 'Albumin', 'g/dL', 3.5, 5.5, '3.5-5.5'),
(@cmp_id, 'ALP', 'U/L', 30, 120, '30-120'),
(@cmp_id, 'ALT', 'U/L', 10, 40, '10-40'),
(@cmp_id, 'AST', 'U/L', 10, 40, '10-40'),
(@cmp_id, 'BUN', 'mg/dL', 8, 20, '8-20'),
(@cmp_id, 'Calcium', 'mg/dL', 8.6, 10.2, '8.6-10.2'),
(@cmp_id, 'Chloride', 'mEq/L', 98, 106, '98-106'),
(@cmp_id, 'CO2', 'mEq/L', 23, 28, '23-28'),
(@cmp_id, 'Creatinine', 'mg/dL', 0.8, 1.3, '0.8-1.3'),
(@cmp_id, 'Glucose', 'mg/dL', 70, 99, '70-99'),
(@cmp_id, 'Potassium', 'mEq/L', 3.5, 5.0, '3.5-5.0'),
(@cmp_id, 'Sodium', 'mEq/L', 136, 145, '136-145'),
(@cmp_id, 'Total Bilirubin', 'mg/dL', 0.3, 1.0, '0.3-1.0'),
(@cmp_id, 'Total Protein', 'g/dL', 6.0, 8.3, '6.0-8.3');

-- Add Cardiac Panel
INSERT INTO TestTypes (TestName, Description, Price) VALUES
('Cardiac Panel', 'Comprehensive cardiac enzyme tests', 150.00);

SET @cardiac_id = LAST_INSERT_ID();

INSERT INTO TestParameters (TestTypeID, ParameterName, Unit, MinValue, MaxValue, ReferenceRange) VALUES
(@cardiac_id, 'Troponin I', 'ng/mL', NULL, 0.04, '≤0.04'),
(@cardiac_id, 'Troponin T', 'ng/mL', NULL, 0.01, '≤0.01'),
(@cardiac_id, 'CK-MB', '%', NULL, 5, '<5% of total CK'),
(@cardiac_id, 'CK Total', 'U/L', 30, 170, 'Female: 30-135, Male: 55-170'),
(@cardiac_id, 'BNP', 'pg/mL', NULL, 100, '<100'),
(@cardiac_id, 'LDH', 'U/L', 60, 160, '60-160');

-- Add Hormone Panel
INSERT INTO TestTypes (TestName, Description, Price) VALUES
('Hormone Panel', 'Complete hormone analysis', 200.00);

SET @hormone_id = LAST_INSERT_ID();

INSERT INTO TestParameters (TestTypeID, ParameterName, Unit, MinValue, MaxValue, ReferenceRange) VALUES
(@hormone_id, 'TSH', 'μU/mL', 0.5, 4.0, '0.5-4.0'),
(@hormone_id, 'Free T3', 'pg/mL', 2.3, 4.2, '2.3-4.2'),
(@hormone_id, 'Free T4', 'ng/dL', 0.8, 1.8, '0.8-1.8'),
(@hormone_id, 'Total T3', 'ng/dL', 80, 180, '80-180'),
(@hormone_id, 'Total T4', 'μg/dL', 5, 12, '5-12'),
(@hormone_id, 'FSH', 'mIU/mL', NULL, NULL, 'Male: 1-7, Female: 2-9'),
(@hormone_id, 'LH', 'mIU/mL', NULL, NULL, 'Male: 2-9, Female: 1-12'),
(@hormone_id, 'Prolactin', 'ng/mL', NULL, 20, '<20'),
(@hormone_id, 'ACTH', 'pg/mL', 10, 60, '10-60');

-- Add Vitamin Panel
INSERT INTO TestTypes (TestName, Description, Price) VALUES
('Vitamin Panel', 'Complete vitamin level analysis', 180.00);

SET @vitamin_id = LAST_INSERT_ID();

INSERT INTO TestParameters (TestTypeID, ParameterName, Unit, MinValue, MaxValue, ReferenceRange) VALUES
(@vitamin_id, 'Vitamin B12', 'pg/mL', 200, 800, '200-800'),
(@vitamin_id, 'Folate', 'ng/mL', 1.8, 9.0, '1.8-9.0'),
(@vitamin_id, 'Vitamin D', 'ng/mL', 30, 60, '30-60'),
(@vitamin_id, 'Vitamin A', 'μg/dL', 32.5, 78.0, '32.5-78.0'),
(@vitamin_id, 'Vitamin C', 'mg/dL', 0.4, 1.5, '0.4-1.5');

-- Add Tumor Marker Panel
INSERT INTO TestTypes (TestName, Description, Price) VALUES
('Tumor Marker Panel', 'Cancer screening markers', 250.00);

SET @tumor_id = LAST_INSERT_ID();

INSERT INTO TestParameters (TestTypeID, ParameterName, Unit, MinValue, MaxValue, ReferenceRange) VALUES
(@tumor_id, 'AFP', 'ng/mL', NULL, 44, '0-44'),
(@tumor_id, 'CEA', 'ng/mL', NULL, 2.5, '<2.5'),
(@tumor_id, 'CA 19-9', 'U/mL', NULL, 37, '0-37'),
(@tumor_id, 'PSA', 'ng/mL', NULL, 4, '<4'),
(@tumor_id, 'CA 125', 'U/mL', NULL, 35, '<35');

-- Add Coagulation Panel
INSERT INTO TestTypes (TestName, Description, Price) VALUES
('Coagulation Panel', 'Complete blood clotting analysis', 110.00);

SET @coag_id = LAST_INSERT_ID();

INSERT INTO TestParameters (TestTypeID, ParameterName, Unit, MinValue, MaxValue, ReferenceRange) VALUES
(@coag_id, 'PT', 'seconds', 11, 13, '11-13'),
(@coag_id, 'INR', NULL, 0.9, 1.2, '0.9-1.2'),
(@coag_id, 'aPTT', 'seconds', 25, 35, '25-35'),
(@coag_id, 'Fibrinogen', 'mg/dL', 150, 350, '150-350'),
(@coag_id, 'D-dimer', 'ng/mL', NULL, 300, '≤300');

-- Add Iron Studies
INSERT INTO TestTypes (TestName, Description, Price) VALUES
('Iron Studies', 'Complete iron metabolism analysis', 130.00);

SET @iron_id = LAST_INSERT_ID();

INSERT INTO TestParameters (TestTypeID, ParameterName, Unit, MinValue, MaxValue, ReferenceRange) VALUES
(@iron_id, 'Serum Iron', 'μg/dL', 50, 150, '50-150'),
(@iron_id, 'TIBC', 'μg/dL', 250, 310, '250-310'),
(@iron_id, 'Ferritin', 'ng/mL', NULL, NULL, 'Female: 24-307, Male: 24-336'),
(@iron_id, 'Transferrin', 'mg/dL', 200, 400, '200-400'),
(@iron_id, 'Transferrin Saturation', '%', 20, 50, '20-50');

-- Add Inflammatory Markers Panel
INSERT INTO TestTypes (TestName, Description, Price) VALUES
('Inflammatory Markers', 'Comprehensive inflammation assessment', 140.00);

SET @inflam_id = LAST_INSERT_ID();

INSERT INTO TestParameters (TestTypeID, ParameterName, Unit, MinValue, MaxValue, ReferenceRange) VALUES
(@inflam_id, 'CRP', 'mg/dL', NULL, 0.5, '<0.5'),
(@inflam_id, 'ESR', 'mm/hr', NULL, NULL, 'Female: 0-20, Male: 0-15'),
(@inflam_id, 'Procalcitonin', 'ng/mL', NULL, 0.10, '≤0.10'),
(@inflam_id, 'IL-6', 'pg/mL', NULL, 7, '<7'),
(@inflam_id, 'Rheumatoid Factor', 'U/mL', NULL, 40, '<40');

-- Add Allergy Panel
INSERT INTO TestTypes (TestName, Description, Price) VALUES
('Allergy Panel', 'Common allergen testing', 220.00);

SET @allergy_id = LAST_INSERT_ID();

INSERT INTO TestParameters (TestTypeID, ParameterName, Unit, MinValue, MaxValue, ReferenceRange) VALUES
(@allergy_id, 'Total IgE', 'IU/mL', NULL, 380, '<380'),
(@allergy_id, 'Specific IgE - Dust Mites', 'kU/L', NULL, 0.35, '<0.35'),
(@allergy_id, 'Specific IgE - Cat Dander', 'kU/L', NULL, 0.35, '<0.35'),
(@allergy_id, 'Specific IgE - Dog Dander', 'kU/L', NULL, 0.35, '<0.35'),
(@allergy_id, 'Specific IgE - Pollen Mix', 'kU/L', NULL, 0.35, '<0.35');

-- Add Autoimmune Panel
INSERT INTO TestTypes (TestName, Description, Price) VALUES
('Autoimmune Panel', 'Comprehensive autoimmune disease screening', 280.00);

SET @autoimmune_id = LAST_INSERT_ID();

INSERT INTO TestParameters (TestTypeID, ParameterName, Unit, MinValue, MaxValue, ReferenceRange) VALUES
(@autoimmune_id, 'ANA', NULL, NULL, NULL, '≤1:40'),
(@autoimmune_id, 'Anti-dsDNA', 'IU/mL', NULL, 7, '0-7'),
(@autoimmune_id, 'Anti-CCP', 'units', NULL, 20, '<20'),
(@autoimmune_id, 'C3 Complement', 'mg/dL', 100, 233, '100-233'),
(@autoimmune_id, 'C4 Complement', 'mg/dL', 14, 48, '14-48');

-- Add Bone Metabolism Panel
INSERT INTO TestTypes (TestName, Description, Price) VALUES
('Bone Metabolism Panel', 'Bone health assessment', 160.00);

SET @bone_id = LAST_INSERT_ID();

INSERT INTO TestParameters (TestTypeID, ParameterName, Unit, MinValue, MaxValue, ReferenceRange) VALUES
(@bone_id, 'Calcium', 'mg/dL', 8.6, 10.2, '8.6-10.2'),
(@bone_id, 'Phosphorus', 'mg/dL', 2.5, 4.5, '2.5-4.5'),
(@bone_id, 'Alkaline Phosphatase', 'U/L', 30, 120, '30-120'),
(@bone_id, 'PTH', 'pg/mL', 10, 65, '10-65'),
(@bone_id, 'Vitamin D 25-OH', 'ng/mL', 30, 60, '30-60');

-- Add Therapeutic Drug Monitoring Panel
INSERT INTO TestTypes (TestName, Description, Price) VALUES
('Drug Monitoring', 'Therapeutic drug level monitoring', 190.00);

SET @drug_id = LAST_INSERT_ID();

INSERT INTO TestParameters (TestTypeID, ParameterName, Unit, MinValue, MaxValue, ReferenceRange) VALUES
(@drug_id, 'Carbamazepine', 'mcg/mL', 4.0, 12.0, '4.0-12.0'),
(@drug_id, 'Digoxin', 'mg/dL', 0.8, 2.0, '0.8-2.0'),
(@drug_id, 'Phenytoin', 'mcg/mL', 10.0, 20.0, '10.0-20.0'),
(@drug_id, 'Valproic Acid', 'mcg/mL', 50, 99, '50-99'),
(@drug_id, 'Vancomycin Trough', 'mcg/mL', 5, 10, '5-10');

-- Add Cerebrospinal Fluid (CSF) Analysis
INSERT INTO TestTypes (TestName, Description, Price) VALUES
('CSF Analysis', 'Complete cerebrospinal fluid examination', 230.00);

SET @csf_id = LAST_INSERT_ID();

INSERT INTO TestParameters (TestTypeID, ParameterName, Unit, MinValue, MaxValue, ReferenceRange) VALUES
(@csf_id, 'Opening Pressure', 'mm H2O', 70, 180, '70-180'),
(@csf_id, 'WBC Count', 'cells/μL', 0, 5, '0-5'),
(@csf_id, 'RBC Count', 'cells/μL', 0, 0, '0'),
(@csf_id, 'Glucose', 'mg/dL', 50, 75, '50-75'),
(@csf_id, 'Protein', 'mg/dL', 15, 45, '15-45'),
(@csf_id, 'Chloride', 'mEq/L', 120, 130, '120-130'); 