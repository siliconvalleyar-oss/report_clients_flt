class EquipmentModel {
  final String brand;
  final String model;
  final String serialNumber;

  EquipmentModel({
    required this.brand,
    required this.model,
    this.serialNumber = '',
  });

  factory EquipmentModel.fromMap(Map<String, dynamic> map) {
    return EquipmentModel(
      brand: map['brand'] ?? '',
      model: map['model'] ?? '',
      serialNumber: map['serialNumber'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'brand': brand,
      'model': model,
      'serialNumber': serialNumber,
    };
  }
}
