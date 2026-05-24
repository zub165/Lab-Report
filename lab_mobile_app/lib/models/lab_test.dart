class LabTest {
  final String id;
  final String name;
  final String category;
  final String description;
  final String normalRange;
  final String unit;
  final double price;
  final String preparation;
  final String collectionMethod;
  final String processingTime;
  final List<LabTestParameter> parameters;

  const LabTest({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.normalRange,
    required this.unit,
    required this.price,
    required this.preparation,
    required this.collectionMethod,
    required this.processingTime,
    required this.parameters,
  });
}

class LabTestParameter {
  final String name;
  final String normalRange;
  final String unit;
  final String criticalLow;
  final String criticalHigh;

  const LabTestParameter({
    required this.name,
    required this.normalRange,
    required this.unit,
    required this.criticalLow,
    required this.criticalHigh,
  });
}
