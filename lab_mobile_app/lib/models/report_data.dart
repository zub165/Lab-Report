class ReportData {
  final String? id;
  final String? reportId;
  final String? title;
  final String? content;
  final String? patientId;
  final String? testId;
  final String? templateId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? reportDate;
  final String? status;
  final String? type;
  final String? reportType;
  final String? notes;
  final String? authorizedBy;
  final Map<String, dynamic>? results;

  ReportData({
    this.id,
    this.reportId,
    this.title,
    this.content,
    this.patientId,
    this.testId,
    this.templateId,
    this.createdAt,
    this.updatedAt,
    this.reportDate,
    this.status,
    this.type,
    this.reportType,
    this.notes,
    this.authorizedBy,
    this.results,
  });

  factory ReportData.fromJson(Map<String, dynamic> json) {
    return ReportData(
      id: json['id']?.toString(),
      title: json['title'],
      content: json['content'],
      patientId: json['patient_id']?.toString(),
      testId: json['test_id']?.toString(),
      templateId: json['template_id']?.toString(),
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
      reportDate: json['report_date'] != null 
          ? DateTime.parse(json['report_date']) 
          : null,
      status: json['status'],
      type: json['type'],
      notes: json['notes'],
      authorizedBy: json['authorized_by'],
      results: json['results'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (content != null) 'content': content,
      if (patientId != null) 'patient_id': patientId,
      if (testId != null) 'test_id': testId,
      if (templateId != null) 'template_id': templateId,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      if (reportDate != null) 'report_date': reportDate!.toIso8601String(),
      if (status != null) 'status': status,
      if (type != null) 'type': type,
      if (notes != null) 'notes': notes,
      if (authorizedBy != null) 'authorized_by': authorizedBy,
      if (results != null) 'results': results,
    };
  }
}
