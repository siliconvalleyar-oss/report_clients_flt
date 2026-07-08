enum ServiceType { preventive, corrective, calibration, installation }

class ServiceModel {
  final ServiceType type;
  final String description;
  final DateTime date;
  final bool hasSpareParts;
  final bool hasWarranty;
  final String observations;

  ServiceModel({
    required this.type,
    this.description = '',
    required this.date,
    this.hasSpareParts = false,
    this.hasWarranty = false,
    this.observations = '',
  });

  String get typeName {
    switch (type) {
      case ServiceType.preventive:
        return 'Preventivo';
      case ServiceType.corrective:
        return 'Correctivo';
      case ServiceType.calibration:
        return 'Calibración';
      case ServiceType.installation:
        return 'Instalación';
    }
  }

  factory ServiceModel.fromMap(Map<String, dynamic> map) {
    return ServiceModel(
      type: ServiceType.values[map['type'] ?? 0],
      description: map['description'] ?? '',
      date: DateTime.parse(map['date']),
      hasSpareParts: map['hasSpareParts'] ?? false,
      hasWarranty: map['hasWarranty'] ?? false,
      observations: map['observations'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type.index,
      'description': description,
      'date': date.toIso8601String(),
      'hasSpareParts': hasSpareParts,
      'hasWarranty': hasWarranty,
      'observations': observations,
    };
  }
}
