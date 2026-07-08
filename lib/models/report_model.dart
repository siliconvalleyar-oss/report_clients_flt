import 'dart:typed_data';
import 'client_model.dart';
import 'equipment_model.dart';
import 'report_item.dart';
import 'service_model.dart';

class ReportModel {
  final String id;
  final ClientModel client;
  final String serviceLocation;
  final String employeeName;
  final String employeePosition;
  final List<ServiceModel> services;
  final EquipmentModel equipment;
  final String problemDescription;
  final String workDone;
  final Uint8List? clientSignature;
  final String companyStamp;
  final String budgetNumber;
  final double serviceCost;
  final double expenses;
  final List<ReportItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReportModel({
    required this.id,
    required this.client,
    this.serviceLocation = '',
    this.employeeName = '',
    this.employeePosition = '',
    this.services = const [],
    required this.equipment,
    this.problemDescription = '',
    this.workDone = '',
    this.clientSignature,
    this.companyStamp = '',
    this.budgetNumber = '',
    this.serviceCost = 0.0,
    this.expenses = 0.0,
    this.items = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  double get totalCost => serviceCost + expenses;

  ReportModel.empty()
      : id = '',
        client = ClientModel(name: '', address: ''),
        serviceLocation = '',
        employeeName = '',
        employeePosition = '',
        services = [],
        equipment = EquipmentModel(brand: '', model: ''),
        problemDescription = '',
        workDone = '',
        clientSignature = null,
        companyStamp = '',
        budgetNumber = '',
        serviceCost = 0.0,
        expenses = 0.0,
        items = [],
        createdAt = DateTime.now(),
        updatedAt = DateTime.now();

  factory ReportModel.fromMap(Map<String, dynamic> map) {
    return ReportModel(
      id: map['id'] ?? '',
      client: ClientModel.fromMap(Map<String, dynamic>.from(map['client'] ?? {})),
      serviceLocation: map['serviceLocation'] ?? '',
      employeeName: map['employeeName'] ?? '',
      employeePosition: map['employeePosition'] ?? '',
      services: (map['services'] as List<dynamic>?)
              ?.map((s) => ServiceModel.fromMap(Map<String, dynamic>.from(s)))
              .toList() ??
          [],
      equipment: EquipmentModel.fromMap(Map<String, dynamic>.from(map['equipment'] ?? {})),
      problemDescription: map['problemDescription'] ?? '',
      workDone: map['workDone'] ?? '',
      clientSignature: map['clientSignature'] != null
          ? Uint8List.fromList(List<int>.from(map['clientSignature']))
          : null,
      companyStamp: map['companyStamp'] ?? '',
      budgetNumber: map['budgetNumber'] ?? '',
      serviceCost: (map['serviceCost'] ?? 0.0).toDouble(),
      expenses: (map['expenses'] ?? 0.0).toDouble(),
      items: (map['items'] as List<dynamic>?)
              ?.map((e) => ReportItem.fromMap(Map<String, dynamic>.from(e)))
              .toList() ??
          [],
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'client': client.toMap(),
      'serviceLocation': serviceLocation,
      'employeeName': employeeName,
      'employeePosition': employeePosition,
      'services': services.map((s) => s.toMap()).toList(),
      'equipment': equipment.toMap(),
      'problemDescription': problemDescription,
      'workDone': workDone,
      'clientSignature': clientSignature?.toList(),
      'companyStamp': companyStamp,
      'budgetNumber': budgetNumber,
      'serviceCost': serviceCost,
      'expenses': expenses,
      'items': items.map((e) => e.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  ReportModel copyWith({
    String? id,
    ClientModel? client,
    String? serviceLocation,
    String? employeeName,
    String? employeePosition,
    List<ServiceModel>? services,
    EquipmentModel? equipment,
    String? problemDescription,
    String? workDone,
    Uint8List? clientSignature,
    String? companyStamp,
    String? budgetNumber,
    double? serviceCost,
    double? expenses,
    List<ReportItem>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReportModel(
      id: id ?? this.id,
      client: client ?? this.client,
      serviceLocation: serviceLocation ?? this.serviceLocation,
      employeeName: employeeName ?? this.employeeName,
      employeePosition: employeePosition ?? this.employeePosition,
      services: services ?? this.services,
      equipment: equipment ?? this.equipment,
      problemDescription: problemDescription ?? this.problemDescription,
      workDone: workDone ?? this.workDone,
      clientSignature: clientSignature ?? this.clientSignature,
      companyStamp: companyStamp ?? this.companyStamp,
      budgetNumber: budgetNumber ?? this.budgetNumber,
      serviceCost: serviceCost ?? this.serviceCost,
      expenses: expenses ?? this.expenses,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
