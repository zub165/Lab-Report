import 'package:flutter/material.dart';

class ReportTemplate {
  final String id;
  final String name;
  final String testType;
  final String description;
  final List<ReportField> fields;
  final String headerTemplate;
  final String footerTemplate;
  final Map<String, dynamic> styling;

  ReportTemplate({
    required this.id,
    required this.name,
    required this.testType,
    required this.description,
    required this.fields,
    required this.headerTemplate,
    required this.footerTemplate,
    this.styling = const {},
  });

  factory ReportTemplate.fromJson(Map<String, dynamic> json) {
    return ReportTemplate(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      testType: json['test_type'] ?? '',
      description: json['description'] ?? '',
      fields: (json['fields'] as List<dynamic>?)
              ?.map((field) => ReportField.fromJson(field))
              .toList() ??
          [],
      headerTemplate: json['header_template'] ?? '',
      footerTemplate: json['footer_template'] ?? '',
      styling: json['styling'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'test_type': testType,
      'description': description,
      'fields': fields.map((field) => field.toJson()).toList(),
      'header_template': headerTemplate,
      'footer_template': footerTemplate,
      'styling': styling,
    };
  }

  ReportTemplate copyWith({
    String? id,
    String? name,
    String? testType,
    String? description,
    List<ReportField>? fields,
    String? headerTemplate,
    String? footerTemplate,
    Map<String, dynamic>? styling,
  }) {
    return ReportTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      testType: testType ?? this.testType,
      description: description ?? this.description,
      fields: fields ?? this.fields,
      headerTemplate: headerTemplate ?? this.headerTemplate,
      footerTemplate: footerTemplate ?? this.footerTemplate,
      styling: styling ?? this.styling,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReportTemplate && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class ReportField {
  final String name;
  final String label;
  final String type;
  final String? unit;
  final String? normalRange;
  final bool isRequired;
  final int order;

  ReportField({
    required this.name,
    required this.label,
    required this.type,
    this.unit,
    this.normalRange,
    this.isRequired = true,
    required this.order,
  });

  factory ReportField.fromJson(Map<String, dynamic> json) {
    return ReportField(
      name: json['name'] ?? '',
      label: json['label'] ?? '',
      type: json['type'] ?? 'text',
      unit: json['unit'],
      normalRange: json['normal_range'],
      isRequired: json['is_required'] ?? true,
      order: json['order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'label': label,
      'type': type,
      'unit': unit,
      'normal_range': normalRange,
      'is_required': isRequired,
      'order': order,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReportField && other.name == name;
  }

  @override
  int get hashCode => name.hashCode;
}


class DefaultReportTemplates {
  static List<ReportTemplate> get templates => [
    // Standard Report Template (as shown in first image)
    ReportTemplate(
      id: 'standard_report',
      name: 'Standard Report',
      testType: 'Blood Test',
      description: 'Standard laboratory report format',
      fields: [
        ReportField(name: 'hemoglobin', label: 'Hemoglobin', type: 'number', unit: 'g/dL', normalRange: '13.5-17.5', order: 1),
        ReportField(name: 'white_blood_cells', label: 'White Blood Cells', type: 'number', unit: '10^9/L', normalRange: '4.5-11.0', order: 2),
        ReportField(name: 'platelets', label: 'Platelets', type: 'number', unit: '10^9/L', normalRange: '150-450', order: 3),
        ReportField(name: 'glucose', label: 'Glucose', type: 'number', unit: 'mg/dL', normalRange: '70-99', order: 4),
        ReportField(name: 'creatinine', label: 'Creatinine', type: 'number', unit: 'mg/dL', normalRange: '0.7-1.3', order: 5),
        ReportField(name: 'comments', label: 'Comments', type: 'textarea', isRequired: false, order: 6),
      ],
      headerTemplate: '''
SAEED LABORATORY
123 Medical Center Dr, Healthcare City
Phone: 555-0126 | Email: info@saeedlab.com

Report No: {report_number} | Date: {report_date}
      ''',
      footerTemplate: '''
Authorized by: {authorized_by}
Report generated on: {generated_date}
      ''',
      styling: {
        'headerFontSize': 18.0,
        'headerFontWeight': 'bold',
        'tableBorderColor': Colors.black,
        'backgroundColor': Colors.white,
      },
    ),

    // Modern Report Template (as shown in second image)
    ReportTemplate(
      id: 'modern_report',
      name: 'Modern Report',
      testType: 'Diabetes Test',
      description: 'Modern laboratory report with enhanced styling',
      fields: [
        ReportField(name: 'fasting_glucose', label: 'Fasting Glucose', type: 'number', unit: 'mg/dL', normalRange: '70-99', order: 1),
        ReportField(name: 'hba1c', label: 'HbA1c', type: 'number', unit: '%', normalRange: '4.0-5.6', order: 2),
        ReportField(name: 'insulin', label: 'Insulin', type: 'number', unit: 'μU/mL', normalRange: '3-25', order: 3),
        ReportField(name: 'c_peptide', label: 'C-Peptide', type: 'number', unit: 'ng/mL', normalRange: '0.8-3.1', order: 4),
        ReportField(name: 'comments', label: 'Clinical Interpretation', type: 'textarea', isRequired: false, order: 5),
      ],
      headerTemplate: '''
SAEED LABORATORY
123 Medical Center Dr, Healthcare City
Phone: 555-0126 | Email: info@saeedlab.com

Report No: {report_number} | Date: {report_date}
      ''',
      footerTemplate: '''
Authorized by: {authorized_by}
Report generated on: {generated_date}
      ''',
      styling: {
        'headerFontSize': 20.0,
        'headerFontWeight': 'bold',
        'tableBorderColor': Colors.blue,
        'backgroundColor': Colors.blue.shade50,
        'headerBackgroundColor': Colors.blue.shade700,
        'headerTextColor': Colors.white,
      },
    ),

    // Quest Diagnostics Style Template (as shown in third image)
    ReportTemplate(
      id: 'quest_diagnostics',
      name: 'Quest Diagnostics',
      testType: 'Comprehensive Panel',
      description: 'Quest Diagnostics style professional report',
      fields: [
        ReportField(name: 'fasting_glucose', label: 'Fasting Glucose', type: 'number', unit: 'mg/dL', normalRange: '70-99', order: 1),
        ReportField(name: 'hba1c', label: 'HbA1c', type: 'number', unit: '%', normalRange: '4.0-5.6', order: 2),
        ReportField(name: 'total_cholesterol', label: 'Total Cholesterol', type: 'number', unit: 'mg/dL', normalRange: '<200', order: 3),
        ReportField(name: 'hdl', label: 'HDL Cholesterol', type: 'number', unit: 'mg/dL', normalRange: '≥40', order: 4),
        ReportField(name: 'ldl', label: 'LDL Cholesterol', type: 'number', unit: 'mg/dL', normalRange: '<100', order: 5),
        ReportField(name: 'triglycerides', label: 'Triglycerides', type: 'number', unit: 'mg/dL', normalRange: '<150', order: 6),
        ReportField(name: 'comments', label: 'Clinical Notes', type: 'textarea', isRequired: false, order: 7),
      ],
      headerTemplate: '''
SAEED LABORATORY
123 Medical Center Dr, Healthcare City
Phone: 555-0126 | Email: info@saeedlab.com

Report No: {report_number} | Date: {report_date}
      ''',
      footerTemplate: '''
Authorized by: {authorized_by}
Report generated on: {generated_date}
      ''',
      styling: {
        'headerFontSize': 22.0,
        'headerFontWeight': 'bold',
        'tableBorderColor': Colors.green.shade700,
        'backgroundColor': Colors.white,
        'headerBackgroundColor': Colors.green.shade700,
        'headerTextColor': Colors.white,
        'resultBarColor': Colors.green,
        'normalResultColor': Colors.green,
        'abnormalResultColor': Colors.red,
      },
    ),

    // Quest Lab Style Template 1: Comprehensive Blood Panel
    ReportTemplate(
      id: 'quest_comprehensive_blood',
      name: 'Quest Lab - Comprehensive Blood Panel',
      testType: 'Blood Test (CBC)',
      description: 'Quest Lab Style Complete Blood Count with Comprehensive Analysis',
      fields: [
        ReportField(name: 'hemoglobin', label: 'Hemoglobin', type: 'number', unit: 'g/dL', normalRange: '12.0-16.0', order: 1),
        ReportField(name: 'hematocrit', label: 'Hematocrit', type: 'number', unit: '%', normalRange: '36-46', order: 2),
        ReportField(name: 'red_blood_cells', label: 'Red Blood Cells', type: 'number', unit: 'M/μL', normalRange: '4.2-5.4', order: 3),
        ReportField(name: 'white_blood_cells', label: 'White Blood Cells', type: 'number', unit: 'K/μL', normalRange: '4.5-11.0', order: 4),
        ReportField(name: 'platelets', label: 'Platelets', type: 'number', unit: 'K/μL', normalRange: '150-450', order: 5),
        ReportField(name: 'mcv', label: 'Mean Corpuscular Volume', type: 'number', unit: 'fL', normalRange: '80-100', order: 6),
        ReportField(name: 'mch', label: 'Mean Corpuscular Hemoglobin', type: 'number', unit: 'pg', normalRange: '27-32', order: 7),
        ReportField(name: 'mchc', label: 'Mean Corpuscular Hemoglobin Concentration', type: 'number', unit: 'g/dL', normalRange: '32-36', order: 8),
        ReportField(name: 'neutrophils', label: 'Neutrophils', type: 'number', unit: '%', normalRange: '40-70', order: 9),
        ReportField(name: 'lymphocytes', label: 'Lymphocytes', type: 'number', unit: '%', normalRange: '20-40', order: 10),
        ReportField(name: 'monocytes', label: 'Monocytes', type: 'number', unit: '%', normalRange: '2-8', order: 11),
        ReportField(name: 'eosinophils', label: 'Eosinophils', type: 'number', unit: '%', normalRange: '1-4', order: 12),
        ReportField(name: 'basophils', label: 'Basophils', type: 'number', unit: '%', normalRange: '0.5-1', order: 13),
        ReportField(name: 'comments', label: 'Clinical Interpretation', type: 'textarea', isRequired: false, order: 14),
      ],
      headerTemplate: 'QUEST LABORATORY\nCOMPREHENSIVE BLOOD COUNT (CBC)\nLaboratory Report\n\nPatient Information:\n{patient_name}\nTest Date: {test_date}\nReport Date: {report_date}',
      footerTemplate: '\n\nReport generated by: Quest Laboratory System\nReviewed by: {doctor}\nTechnician: {technician}\n\nThis report is for medical use only.\nQuest Lab - Excellence in Laboratory Services',
    ),

    // Quest Lab Style Template 2: Advanced Metabolic Panel
    ReportTemplate(
      id: 'quest_metabolic_panel',
      name: 'Quest Lab - Advanced Metabolic Panel',
      testType: 'Metabolic Panel',
      description: 'Quest Lab Style Comprehensive Metabolic Assessment',
      fields: [
        ReportField(name: 'glucose', label: 'Glucose (Fasting)', type: 'number', unit: 'mg/dL', normalRange: '70-100', order: 1),
        ReportField(name: 'bun', label: 'Blood Urea Nitrogen', type: 'number', unit: 'mg/dL', normalRange: '7-20', order: 2),
        ReportField(name: 'creatinine', label: 'Creatinine', type: 'number', unit: 'mg/dL', normalRange: '0.7-1.3', order: 3),
        ReportField(name: 'egfr', label: 'eGFR', type: 'number', unit: 'mL/min/1.73m²', normalRange: '≥60', order: 4),
        ReportField(name: 'sodium', label: 'Sodium', type: 'number', unit: 'mEq/L', normalRange: '135-145', order: 5),
        ReportField(name: 'potassium', label: 'Potassium', type: 'number', unit: 'mEq/L', normalRange: '3.5-5.0', order: 6),
        ReportField(name: 'chloride', label: 'Chloride', type: 'number', unit: 'mEq/L', normalRange: '96-106', order: 7),
        ReportField(name: 'co2', label: 'CO2', type: 'number', unit: 'mEq/L', normalRange: '22-28', order: 8),
        ReportField(name: 'calcium', label: 'Calcium', type: 'number', unit: 'mg/dL', normalRange: '8.5-10.5', order: 9),
        ReportField(name: 'albumin', label: 'Albumin', type: 'number', unit: 'g/dL', normalRange: '3.5-5.0', order: 10),
        ReportField(name: 'total_protein', label: 'Total Protein', type: 'number', unit: 'g/dL', normalRange: '6.0-8.3', order: 11),
        ReportField(name: 'bilirubin_total', label: 'Total Bilirubin', type: 'number', unit: 'mg/dL', normalRange: '0.3-1.2', order: 12),
        ReportField(name: 'alkaline_phosphatase', label: 'Alkaline Phosphatase', type: 'number', unit: 'U/L', normalRange: '44-147', order: 13),
        ReportField(name: 'alt', label: 'ALT', type: 'number', unit: 'U/L', normalRange: '7-56', order: 14),
        ReportField(name: 'comments', label: 'Clinical Interpretation', type: 'textarea', isRequired: false, order: 15),
      ],
      headerTemplate: 'QUEST LABORATORY\nADVANCED METABOLIC PANEL\nLaboratory Report\n\nPatient Information:\n{patient_name}\nTest Date: {test_date}\nReport Date: {report_date}',
      footerTemplate: '\n\nReport generated by: Quest Laboratory System\nReviewed by: {doctor}\nTechnician: {technician}\n\nThis report is for medical use only.\nQuest Lab - Excellence in Laboratory Services',
    ),

    // Quest Lab Style Template 3: Comprehensive Lipid Profile
    ReportTemplate(
      id: 'quest_lipid_profile',
      name: 'Quest Lab - Comprehensive Lipid Profile',
      testType: 'Lipid Profile',
      description: 'Quest Lab Style Advanced Lipid Analysis',
      fields: [
        ReportField(name: 'total_cholesterol', label: 'Total Cholesterol', type: 'number', unit: 'mg/dL', normalRange: '<200', order: 1),
        ReportField(name: 'hdl', label: 'HDL Cholesterol', type: 'number', unit: 'mg/dL', normalRange: '≥40', order: 2),
        ReportField(name: 'ldl', label: 'LDL Cholesterol', type: 'number', unit: 'mg/dL', normalRange: '<100', order: 3),
        ReportField(name: 'triglycerides', label: 'Triglycerides', type: 'number', unit: 'mg/dL', normalRange: '<150', order: 4),
        ReportField(name: 'non_hdl', label: 'Non-HDL Cholesterol', type: 'number', unit: 'mg/dL', normalRange: '<130', order: 5),
        ReportField(name: 'cholesterol_ratio', label: 'Total/HDL Ratio', type: 'number', unit: '', normalRange: '<5.0', order: 6),
        ReportField(name: 'apolipoprotein_a1', label: 'Apolipoprotein A-1', type: 'number', unit: 'mg/dL', normalRange: '110-205', order: 7),
        ReportField(name: 'apolipoprotein_b', label: 'Apolipoprotein B', type: 'number', unit: 'mg/dL', normalRange: '60-130', order: 8),
        ReportField(name: 'lp_a', label: 'Lipoprotein (a)', type: 'number', unit: 'mg/dL', normalRange: '<30', order: 9),
        ReportField(name: 'hs_crp', label: 'High-Sensitivity CRP', type: 'number', unit: 'mg/L', normalRange: '<3.0', order: 10),
        ReportField(name: 'comments', label: 'Cardiovascular Risk Assessment', type: 'textarea', isRequired: false, order: 11),
      ],
      headerTemplate: 'QUEST LABORATORY\nCOMPREHENSIVE LIPID PROFILE\nLaboratory Report\n\nPatient Information:\n{patient_name}\nTest Date: {test_date}\nReport Date: {report_date}',
      footerTemplate: '\n\nReport generated by: Quest Laboratory System\nReviewed by: {doctor}\nTechnician: {technician}\n\nThis report is for medical use only.\nQuest Lab - Excellence in Laboratory Services',
    ),

    // Standard Templates (Urine Analysis remains)
    ReportTemplate(
      id: 'urine_analysis',
      name: 'Urine Analysis',
      testType: 'Urine Analysis',
      description: 'Urine Analysis Test Report',
      fields: [
        ReportField(name: 'appearance', label: 'Appearance', type: 'text', order: 1),
        ReportField(name: 'color', label: 'Color', type: 'text', order: 2),
        ReportField(name: 'specific_gravity', label: 'Specific Gravity', type: 'number', normalRange: '1.005-1.030', order: 3),
        ReportField(name: 'ph', label: 'pH', type: 'number', normalRange: '4.5-8.0', order: 4),
        ReportField(name: 'protein', label: 'Protein', type: 'text', order: 5),
        ReportField(name: 'glucose', label: 'Glucose', type: 'text', order: 6),
        ReportField(name: 'ketones', label: 'Ketones', type: 'text', order: 7),
        ReportField(name: 'blood', label: 'Blood', type: 'text', order: 8),
        ReportField(name: 'leukocytes', label: 'Leukocytes', type: 'text', order: 9),
        ReportField(name: 'nitrites', label: 'Nitrites', type: 'text', order: 10),
        ReportField(name: 'comments', label: 'Comments', type: 'textarea', isRequired: false, order: 11),
      ],
      headerTemplate: 'URINE ANALYSIS\nLaboratory Report',
      footerTemplate: 'Report generated on: {date}\nReviewed by: {doctor}',
    ),
  ];
}
