class ReportItem {
  final String description;
  final String model;
  final int quantity;
  final double price;

  const ReportItem({
    this.description = '',
    this.model = '',
    this.quantity = 1,
    this.price = 0.0,
  });

  double get total => quantity * price;

  factory ReportItem.fromMap(Map<String, dynamic> map) => ReportItem(
    description: map['description'] ?? '',
    model: map['model'] ?? '',
    quantity: (map['quantity'] ?? 1).toInt(),
    price: (map['price'] ?? 0.0).toDouble(),
  );

  Map<String, dynamic> toMap() => {
    'description': description,
    'model': model,
    'quantity': quantity,
    'price': price,
  };

  ReportItem copyWith({
    String? description,
    String? model,
    int? quantity,
    double? price,
  }) => ReportItem(
    description: description ?? this.description,
    model: model ?? this.model,
    quantity: quantity ?? this.quantity,
    price: price ?? this.price,
  );
}
