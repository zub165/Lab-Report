# Graph Report - lib  (2026-04-27)

## Corpus Check
- 87 files · ~80,527 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1130 nodes · 1393 edges · 29 communities detected
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- [[_COMMUNITY_Community 0|Community 0]]
- [[_COMMUNITY_Community 1|Community 1]]
- [[_COMMUNITY_Community 2|Community 2]]
- [[_COMMUNITY_Community 3|Community 3]]
- [[_COMMUNITY_Community 4|Community 4]]
- [[_COMMUNITY_Community 5|Community 5]]
- [[_COMMUNITY_Community 6|Community 6]]
- [[_COMMUNITY_Community 7|Community 7]]
- [[_COMMUNITY_Community 8|Community 8]]
- [[_COMMUNITY_Community 9|Community 9]]
- [[_COMMUNITY_Community 10|Community 10]]
- [[_COMMUNITY_Community 11|Community 11]]
- [[_COMMUNITY_Community 12|Community 12]]
- [[_COMMUNITY_Community 13|Community 13]]
- [[_COMMUNITY_Community 14|Community 14]]
- [[_COMMUNITY_Community 15|Community 15]]
- [[_COMMUNITY_Community 16|Community 16]]
- [[_COMMUNITY_Community 17|Community 17]]
- [[_COMMUNITY_Community 18|Community 18]]
- [[_COMMUNITY_Community 19|Community 19]]
- [[_COMMUNITY_Community 20|Community 20]]
- [[_COMMUNITY_Community 21|Community 21]]
- [[_COMMUNITY_Community 22|Community 22]]
- [[_COMMUNITY_Community 23|Community 23]]
- [[_COMMUNITY_Community 24|Community 24]]
- [[_COMMUNITY_Community 25|Community 25]]
- [[_COMMUNITY_Community 26|Community 26]]
- [[_COMMUNITY_Community 27|Community 27]]
- [[_COMMUNITY_Community 28|Community 28]]

## God Nodes (most connected - your core abstractions)
1. `package:flutter/material.dart` - 54 edges
2. `../services/simple_hybrid_storage_service.dart` - 38 edges
3. `../models/patient.dart` - 27 edges
4. `../models/test.dart` - 26 edges
5. `../utils/constants.dart` - 23 edges
6. `package:provider/provider.dart` - 21 edges
7. `../providers/test_provider.dart` - 20 edges
8. `../providers/patient_provider.dart` - 18 edges
9. `../providers/report_provider.dart` - 18 edges
10. `../providers/appointment_provider.dart` - 17 edges

## Surprising Connections (you probably didn't know these)
- `../providers/auth_provider.dart` --defines--> `AuthProvider`  [EXTRACTED]
  lib/screens/splash_screen.dart → lib/providers/auth_provider.dart
- `../providers/auth_provider.dart` --defines--> `clearError`  [EXTRACTED]
  lib/screens/splash_screen.dart → lib/providers/auth_provider.dart
- `../providers/patient_provider.dart` --defines--> `PatientProvider`  [EXTRACTED]
  lib/screens/home_screen.dart → lib/providers/patient_provider.dart
- `../providers/patient_provider.dart` --defines--> `selectPatient`  [EXTRACTED]
  lib/screens/home_screen.dart → lib/providers/patient_provider.dart
- `../providers/patient_provider.dart` --defines--> `clearSelection`  [EXTRACTED]
  lib/screens/home_screen.dart → lib/providers/patient_provider.dart

## Communities

### Community 0 - "Community 0"
Cohesion: 0.02
Nodes (112): package:flutter/foundation.dart, package:flutter/material.dart, package:flutter/services.dart, package:provider/provider.dart, ../providers/auth_provider.dart, ../providers/language_provider.dart, ../providers/theme_provider.dart, build (+104 more)

### Community 1 - "Community 1"
Cohesion: 0.04
Nodes (61): dart:io, dart:typed_data, ../models/patient.dart, ../models/test.dart, ../models/test_result.dart, package:path_provider/path_provider.dart, package:pdf/pdf.dart, package:pdf/widgets.dart (+53 more)

### Community 2 - "Community 2"
Cohesion: 0.03
Nodes (57): advanced_report_screen.dart, api_connection_screen.dart, appointment_scheduling_screen.dart, comprehensive_patient_details_screen.dart, comprehensive_test_details_screen.dart, database_excel_screen.dart, enhanced_add_patient_screen.dart, lab_test_selection_screen.dart (+49 more)

### Community 3 - "Community 3"
Cohesion: 0.04
Nodes (54): ../models/user_create_request.dart, ../models/user.dart, ../models/user_update_request.dart, ../providers/patient_provider.dart, ../providers/user_provider.dart, UserCreateRequest, copyWith, toString (+46 more)

### Community 4 - "Community 4"
Cohesion: 0.04
Nodes (55): dart:math, ../models/payment.dart, ../providers/payment_provider.dart, copyWith, Payment, toString, clearError, clearSelectedPayment (+47 more)

### Community 5 - "Community 5"
Cohesion: 0.04
Nodes (51): delete_account_screen.dart, package:path/path.dart, package:sqflite/sqflite.dart, ../services/simple_hybrid_storage_service.dart, build, _buildBasicInfoSection, _buildContactInfoSection, _buildLicenseInfoSection (+43 more)

### Community 6 - "Community 6"
Cohesion: 0.04
Nodes (52): ../models/report_template.dart, ../providers/report_provider.dart, copyWith, DefaultReportTemplates, ReportField, ReportTemplate, clearError, clearSelectedReport (+44 more)

### Community 7 - "Community 7"
Cohesion: 0.04
Nodes (47): django_api_service.dart, location_selection_screen.dart, ../models/appointment.dart, ../providers/appointment_provider.dart, Appointment, copyWith, AppointmentProvider, clearError (+39 more)

### Community 8 - "Community 8"
Cohesion: 0.04
Nodes (47): package:image_picker/image_picker.dart, ../providers/test_provider.dart, clearError, clearSelectedTest, selectTest, TestProvider, AdvancedReportScreen, _AdvancedReportScreenState (+39 more)

### Community 9 - "Community 9"
Cohesion: 0.05
Nodes (42): edit_report_screen.dart, edit_test_screen.dart, report_preview_screen.dart, build, _buildActionButtons, _buildInfoRow, _buildPatientInfoCard, _buildReportContentCard (+34 more)

### Community 10 - "Community 10"
Cohesion: 0.05
Nodes (37): constants.dart, dart:convert, package:http/http.dart, package:shared_preferences/shared_preferences.dart, copyWith, Doctor, LabSettings, Technician (+29 more)

### Community 11 - "Community 11"
Cohesion: 0.05
Nodes (41): ../models/report_data.dart, ReportData, build, _buildAuthorizedBySection, _buildBasicInfoSection, _buildContentSection, _buildDateSection, _buildInfoRow (+33 more)

### Community 12 - "Community 12"
Cohesion: 0.05
Nodes (37): ../models/lab_test.dart, LabTest, LabTestParameter, build, _buildCategoryChip, _buildParameterCard, _buildSearchAndFilterSection, _buildStatCard (+29 more)

### Community 13 - "Community 13"
Cohesion: 0.06
Nodes (34): analytics_dashboard_screen.dart, package:fl_chart/fl_chart.dart, BarChartGroupData, BarTooltipItem, build, _buildActionCard, _buildActivityBarChart, _buildSettingsSection (+26 more)

### Community 14 - "Community 14"
Cohesion: 0.06
Nodes (33): _addNewPatient, build, _buildAnalyticsCard, _buildDetailRow, _buildPatientDetails, Card, Center, Column (+25 more)

### Community 15 - "Community 15"
Cohesion: 0.06
Nodes (33): build, _buildActionButtons, _buildBasicInfoCard, _buildContentCard, _buildEditTab, _buildLabDataTab, _buildNormalRangesCard, _buildOnlineReferenceCard (+25 more)

### Community 16 - "Community 16"
Cohesion: 0.06
Nodes (31): build, _buildAppointmentsTab, _buildInfoRow, _buildPatientInfoCard, _buildPaymentsTab, _buildProfileTab, _buildSummaryCard, _buildSummaryCards (+23 more)

### Community 17 - "Community 17"
Cohesion: 0.06
Nodes (28): ApiTestScreen, _ApiTestScreenState, build, _buildTestResults, _buildTroubleshootingGuide, _buildTroubleshootingItem, Column, Container (+20 more)

### Community 18 - "Community 18"
Cohesion: 0.07
Nodes (28): _applyFilters, build, _buildDetailRow, _buildFilters, _buildPatientSelector, _buildTestCard, _buildTestsList, Card (+20 more)

### Community 19 - "Community 19"
Cohesion: 0.07
Nodes (27): edit_patient_screen.dart, build, _buildActionButtons, _buildInfoRow, _buildPatientInfoCard, _buildTestItem, _buildTestsCard, Card (+19 more)

### Community 20 - "Community 20"
Cohesion: 0.08
Nodes (24): build, _buildActionButtons, _buildAIRecommendationsSection, _buildSearchAndFilterSection, _buildTestDetailsSection, _buildTestInfoCard, _buildTestSelectionSection, Card (+16 more)

### Community 21 - "Community 21"
Cohesion: 0.09
Nodes (22): build, _buildAccountInfoSection, _buildActionButtons, _buildInfoRow, _buildPersonalInfoSection, _buildProfessionalInfoSection, _buildProfileHeader, _cancelEdit (+14 more)

### Community 22 - "Community 22"
Cohesion: 0.09
Nodes (21): build, _buildDateSection, _buildInfoRow, _buildNotesSection, _buildStatusSection, _buildTestInfoSection, _buildUpdateButton, Card (+13 more)

### Community 23 - "Community 23"
Cohesion: 0.1
Nodes (19): build, _buildContactInfoSection, _buildInsuranceInfoSection, _buildMedicalInfoSection, _buildPersonalInfoSection, _buildUpdateButton, Card, dispose (+11 more)

### Community 24 - "Community 24"
Cohesion: 0.11
Nodes (18): build, _buildActionBar, _buildPatientsTable, _buildTableSelector, _buildTestsTable, Container, DatabaseExcelScreen, _DatabaseExcelScreenState (+10 more)

### Community 25 - "Community 25"
Cohesion: 0.12
Nodes (16): ApiConnectionScreen, _ApiConnectionScreenState, build, _buildActionButtons, _buildConnectionStatusCard, _buildDatabaseStatusCard, _buildInfoRow, _buildSyncStatusCard (+8 more)

### Community 26 - "Community 26"
Cohesion: 0.12
Nodes (16): build, _buildAppointmentInfoCard, _buildInfoRow, _buildPatientInfoCard, _buildPaymentInfoCard, _buildTestInfoCard, Card, Chip (+8 more)

### Community 27 - "Community 27"
Cohesion: 0.12
Nodes (15): build, _buildAppointmentInfoCard, _buildInfoRow, _buildPatientInfoCard, _buildTestInfoCard, Card, Chip, ComprehensiveAppointmentDetailsScreen (+7 more)

### Community 28 - "Community 28"
Cohesion: 0.2
Nodes (9): build, Card, Function, _getLocationDescription, initState, LocationSelectionScreen, _LocationSelectionScreenState, Scaffold (+1 more)

## Knowledge Gaps
- **1025 isolated node(s):** `LabManagementApp`, `main`, `SimpleHybridStorageService`, `build`, `MultiProvider` (+1020 more)
  These have ≤1 connection - possible missing edges or undocumented components.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `package:flutter/material.dart` connect `Community 0` to `Community 1`, `Community 2`, `Community 3`, `Community 4`, `Community 5`, `Community 6`, `Community 7`, `Community 8`, `Community 9`, `Community 10`, `Community 11`, `Community 12`, `Community 13`, `Community 14`, `Community 15`, `Community 16`, `Community 17`, `Community 18`, `Community 19`, `Community 20`, `Community 21`, `Community 22`, `Community 23`, `Community 24`, `Community 25`, `Community 26`, `Community 27`, `Community 28`?**
  _High betweenness centrality (0.522) - this node is a cross-community bridge._
- **Why does `../services/simple_hybrid_storage_service.dart` connect `Community 5` to `Community 0`, `Community 1`, `Community 3`, `Community 7`, `Community 8`, `Community 9`, `Community 11`, `Community 18`, `Community 19`, `Community 21`, `Community 22`, `Community 23`, `Community 24`, `Community 25`?**
  _High betweenness centrality (0.072) - this node is a cross-community bridge._
- **Why does `../models/test.dart` connect `Community 1` to `Community 2`, `Community 3`, `Community 4`, `Community 5`, `Community 7`, `Community 8`, `Community 9`, `Community 11`, `Community 13`, `Community 18`, `Community 19`, `Community 20`, `Community 22`, `Community 24`?**
  _High betweenness centrality (0.072) - this node is a cross-community bridge._
- **What connects `LabManagementApp`, `main`, `SimpleHybridStorageService` to the rest of the system?**
  _1025 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Community 0` be split into smaller, more focused modules?**
  _Cohesion score 0.02 - nodes in this community are weakly interconnected._
- **Should `Community 1` be split into smaller, more focused modules?**
  _Cohesion score 0.04 - nodes in this community are weakly interconnected._
- **Should `Community 2` be split into smaller, more focused modules?**
  _Cohesion score 0.03 - nodes in this community are weakly interconnected._