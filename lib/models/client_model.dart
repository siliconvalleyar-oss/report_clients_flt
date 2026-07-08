class ClientModel {
  final String name;
  final String address;
  final String phone;
  final String email;

  ClientModel({
    required this.name,
    required this.address,
    this.phone = '',
    this.email = '',
  });

  factory ClientModel.fromMap(Map<String, dynamic> map) {
    return ClientModel(
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'phone': phone,
      'email': email,
    };
  }
}
