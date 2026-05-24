/// One editable row in the lab results table (parameter + value + reference).
class LabResultRow {
  final String? orderItemId;
  final int? savedResultId;
  final String parameter;
  final String unit;
  final String referenceRange;
  String value;
  final String? analyteCode;
  final String? testCode;
  final String? panelTitle;
  final bool isPanelAnalyte;

  LabResultRow({
    this.orderItemId,
    this.savedResultId,
    required this.parameter,
    this.unit = '',
    this.referenceRange = '',
    this.value = '',
    this.analyteCode,
    this.testCode,
    this.panelTitle,
    this.isPanelAnalyte = false,
  });

  LabResultRow copyWith({
    String? value,
    String? referenceRange,
    String? unit,
  }) {
    return LabResultRow(
      orderItemId: orderItemId,
      savedResultId: savedResultId,
      parameter: parameter,
      unit: unit ?? this.unit,
      referenceRange: referenceRange ?? this.referenceRange,
      value: value ?? this.value,
      analyteCode: analyteCode,
      testCode: testCode,
      panelTitle: panelTitle,
      isPanelAnalyte: isPanelAnalyte,
    );
  }

  bool get hasNormalRange {
    final r = referenceRange.trim().toLowerCase();
    return r.isNotEmpty && r != '—' && r != 'see reference';
  }

  String get displayReference =>
      hasNormalRange ? referenceRange.trim() : '—';
}

  /// Builds table rows from Django test-order JSON (SaeedLab web parity).
  class LabResultRowsBuilder {
  static String _resolveSimpleRefRange(
    Map<String, dynamic> item,
    Map<String, dynamic> testMap,
    Map<String, dynamic>? resultObj,
    Map<String, Map<String, dynamic>>? catalogByCode,
  ) {
    final testCode = (item['test_code'] ?? testMap['test_code'] ?? '')
        .toString()
        .trim();
    if (catalogByCode != null && testCode.isNotEmpty) {
      final meta = catalogByCode[testCode] ?? catalogByCode[testCode.toUpperCase()];
      final fromCat = catalogNormalRange(meta);
      if (fromCat != null) return fromCat;
    }
    final raw = (resultObj?['reference_range'] ??
            item['reference_range'] ??
            testMap['normal_range'] ??
            testMap['reference_range'] ??
            '')
        .toString()
        .trim();
    if (raw.isEmpty) return '—';
    final lower = raw.toLowerCase();
    if (lower == 'see reference') return '—';
    return raw;
  }
  static List<dynamic> orderItemsFromJson(Map<String, dynamic> order) {
    final raw = order['test_items'] ?? order['items'] ?? order['order_items'];
    if (raw is List) return raw;
    if (raw != null) return [raw];
    return [];
  }

  static String _refFromAnalyte(Map<String, dynamic> d) {
    final low = d['ref_low'];
    final high = d['ref_high'];
    if (low != null && high != null) {
      return '$low–$high';
    }
    return d['reference_range']?.toString() ??
        d['normal_range']?.toString() ??
        '';
  }

  static List<LabResultRow> buildFromOrder(
    Map<String, dynamic> order,
    Map<String, List<Map<String, dynamic>>> panelDefs, {
    Map<String, Map<String, dynamic>>? catalogByCode,
  }) {
    final items = orderItemsFromJson(order);
    final rows = <LabResultRow>[];

    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      if (item is! Map) continue;
      final map = Map<String, dynamic>.from(item);
      final testObj = map['test'] ?? map['lab_test'] ?? map['test_type'];
      final testMap = testObj is Map
          ? Map<String, dynamic>.from(testObj)
          : <String, dynamic>{};
      final testCode = (map['test_code'] ?? testMap['test_code'] ?? '')
          .toString()
          .trim();
      final testName = (map['test_name'] ??
              testMap['test_name'] ??
              testMap['name'] ??
              'Test ${i + 1}')
          .toString();
      final itemPk = (map['id'] ?? map['pk'])?.toString();
      final resultObj = map['result'] is Map
          ? Map<String, dynamic>.from(map['result'] as Map)
          : (map['results'] is List && (map['results'] as List).isNotEmpty
              ? Map<String, dynamic>.from(
                  (map['results'] as List).first as Map,
                )
              : null);
      final savedId = resultObj?['id'];
      final panelDef = testCode.isNotEmpty ? panelDefs[testCode] : null;

      if (panelDef != null && panelDef.isNotEmpty) {
        final savedAnalytes = resultObj?['panel_analytes'] is List
            ? (resultObj!['panel_analytes'] as List)
                .whereType<Map>()
                .map((e) => Map<String, dynamic>.from(e))
                .toList()
            : <Map<String, dynamic>>[];
        final byCode = <String, Map<String, dynamic>>{};
        for (final s in savedAnalytes) {
          final c = s['code']?.toString();
          if (c != null && c.isNotEmpty) byCode[c] = s;
        }
        for (final def in panelDef) {
          final code = def['code']?.toString() ?? '';
          final saved = code.isNotEmpty ? byCode[code] : null;
          final val = saved?['value']?.toString().trim() ?? '';
          rows.add(LabResultRow(
            orderItemId: itemPk,
            savedResultId: savedId is int ? savedId : int.tryParse('$savedId'),
            parameter: (def['name'] ?? code).toString(),
            unit: (saved?['unit'] ?? def['unit'] ?? '').toString(),
            referenceRange: _refFromAnalyte(saved ?? def),
            value: val.isEmpty || val == '—' ? '' : val,
            analyteCode: code.isEmpty ? null : code,
            testCode: testCode,
            panelTitle: testName,
            isPanelAnalyte: true,
          ));
        }
        continue;
      }

      final refRange = _resolveSimpleRefRange(
        map,
        testMap,
        resultObj,
        catalogByCode,
      );
      final unit = (resultObj?['unit'] ?? map['unit'] ?? testMap['unit'] ?? '')
          .toString();
      final rv = resultObj?['result_value']?.toString().trim() ?? '';
      rows.add(LabResultRow(
        orderItemId: itemPk,
        savedResultId: savedId is int ? savedId : int.tryParse('$savedId'),
        parameter: testName,
        unit: unit,
        referenceRange: refRange,
        value: rv,
        testCode: testCode.isEmpty ? null : testCode,
        isPanelAnalyte: false,
      ));
    }
    return rows;
  }

  static Map<String, Map<String, dynamic>> catalogByCode(
    List<Map<String, dynamic>> catalog,
  ) {
    final out = <String, Map<String, dynamic>>{};
    for (final t in catalog) {
      final code = (t['test_code'] ?? t['code'] ?? '').toString().trim();
      if (code.isNotEmpty) {
        out[code] = t;
        out[code.toUpperCase()] = t;
      }
    }
    return out;
  }

  static String? catalogNormalRange(Map<String, dynamic>? meta) {
    if (meta == null) return null;
    final nr = (meta['normal_range'] ??
            meta['reference_range'] ??
            meta['ref_range'] ??
            '')
        .toString()
        .trim();
    if (nr.isEmpty) return null;
    final lower = nr.toLowerCase();
    if (lower == 'see reference' || lower == '—' || lower == 'n/a') {
      return null;
    }
    return nr;
  }

  /// Fill missing reference ranges from lab test catalog (normal_range).
  static List<LabResultRow> enrichFromCatalog(
    List<LabResultRow> rows,
    List<Map<String, dynamic>> catalog,
  ) {
    final byCode = catalogByCode(catalog);
    final byName = <String, Map<String, dynamic>>{};
    for (final t in catalog) {
      final name = (t['test_name'] ?? t['name'] ?? '').toString().trim().toLowerCase();
      if (name.isNotEmpty) byName[name] = t;
    }
    return rows.map((r) {
      if (r.hasNormalRange) return r;
      Map<String, dynamic>? meta;
      final code = r.testCode?.trim();
      if (code != null && code.isNotEmpty) {
        meta = byCode[code] ?? byCode[code.toUpperCase()];
      }
      meta ??= byName[r.parameter.trim().toLowerCase()];
      if (meta == null) return r;
      final nr = catalogNormalRange(meta);
      if (nr == null) return r;
      return r.copyWith(
        referenceRange: nr,
        unit: r.unit.isEmpty ? (meta['unit'] ?? '').toString() : r.unit,
      );
    }).toList();
  }

  /// Map rows to report preview field keys (snake_case label).
  static Map<String, dynamic> toReportFieldMap(List<LabResultRow> rows) {
    final data = <String, dynamic>{};
    for (final r in rows) {
      final v = r.value.trim();
      if (v.isEmpty || v == '—') continue;
      final key = r.parameter
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
          .replaceAll(RegExp(r'^_|_$'), '');
      if (key.isNotEmpty) data[key] = v;
    }
    return data;
  }

  static List<Map<String, dynamic>> panelAnalytesPayload(
    List<LabResultRow> rows,
    String orderItemId,
    Map<String, List<Map<String, dynamic>>> panelDefs,
  ) {
    final panelRows =
        rows.where((r) => r.orderItemId == orderItemId && r.isPanelAnalyte);
    final code = panelRows.isNotEmpty ? panelRows.first.testCode : null;
    final def = code != null ? panelDefs[code] : null;
    final out = <Map<String, dynamic>>[];
    for (final r in panelRows) {
      final val = r.value.trim();
      if (val.isEmpty || r.analyteCode == null) continue;
      Map<String, dynamic>? defRow;
      if (def != null) {
        for (final d in def) {
          if (d['code']?.toString() == r.analyteCode) {
            defRow = d;
            break;
          }
        }
      }
      out.add({
        'code': r.analyteCode,
        'value': val,
        'unit': r.unit.isNotEmpty ? r.unit : (defRow?['unit'] ?? ''),
        'ref_low': defRow?['ref_low'],
        'ref_high': defRow?['ref_high'],
      });
    }
    return out;
  }
}

class TestResult {
  final int? resultId;
  final int testId;
  final String parameter;
  final String value;
  final String? unit;
  final String? referenceRange;
  final bool isAbnormal;
  final String? notes;
  final DateTime? createdAt;

  TestResult({
    this.resultId,
    required this.testId,
    required this.parameter,
    required this.value,
    this.unit,
    this.referenceRange,
    this.isAbnormal = false,
    this.notes,
    this.createdAt,
  });

  factory TestResult.fromJson(Map<String, dynamic> json) {
    return TestResult(
      resultId: json['ResultID'] ?? json['id'],
      testId: json['TestID'] ?? json['test_id'],
      parameter: json['Parameter'] ?? json['parameter'] ?? '',
      value: json['Value'] ?? json['value'] ?? '',
      unit: json['Unit'] ?? json['unit'],
      referenceRange: json['ReferenceRange'] ?? json['reference_range'],
      isAbnormal: json['IsAbnormal'] ?? json['is_abnormal'] ?? false,
      notes: json['Notes'] ?? json['notes'],
      createdAt: json['CreatedAt'] != null ? DateTime.parse(json['CreatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ResultID': resultId,
      'TestID': testId,
      'Parameter': parameter,
      'Value': value,
      'Unit': unit,
      'ReferenceRange': referenceRange,
      'IsAbnormal': isAbnormal,
      'Notes': notes,
      'CreatedAt': createdAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toApiJson() {
    return {
      'TestID': testId,
      'Parameter': parameter,
      'Value': value,
      'Unit': unit,
      'ReferenceRange': referenceRange,
      'IsAbnormal': isAbnormal,
      'Notes': notes,
    };
  }

  TestResult copyWith({
    int? resultId,
    int? testId,
    String? parameter,
    String? value,
    String? unit,
    String? referenceRange,
    bool? isAbnormal,
    String? notes,
    DateTime? createdAt,
  }) {
    return TestResult(
      resultId: resultId ?? this.resultId,
      testId: testId ?? this.testId,
      parameter: parameter ?? this.parameter,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      referenceRange: referenceRange ?? this.referenceRange,
      isAbnormal: isAbnormal ?? this.isAbnormal,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'TestResult(parameter: $parameter, value: $value, unit: $unit, isAbnormal: $isAbnormal)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TestResult && other.resultId == resultId;
  }

  @override
  int get hashCode => resultId.hashCode;
}
