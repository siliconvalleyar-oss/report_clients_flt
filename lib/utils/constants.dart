import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'Electromedicina Pro';
  static const String version = '1.1.1';
  static const String companyName = 'Electromedicina Pro';
  static const String companyStamp = 'ELECTROMEDICINA PRO S.A.';

  static const Color primaryColor = Color(0xFF1A5276);
  static const Color accentColor = Color(0xFFF39C12);

  static const List<String> employeeNames = [
    'Carlos Méndez',
    'Ana López',
    'Pedro García',
    'María Rodríguez',
  ];

  static const List<String> equipmentBrands = [
    'GE', 'Philips', 'Siemens', 'Mindray', 'Medtronic',
    'Abbott', 'BD', 'Stryker', 'Zimmer', 'Boston Scientific',
  ];

  static const Map<String, List<String>> modelsByBrand = {
    'GE': ['GE Model A', 'GE Model B', 'GE Model C'],
    'Philips': ['Philips X1', 'Philips X2', 'Philips X3'],
    'Siemens': ['Siemens S1', 'Siemens S2'],
    'Mindray': ['Mindray M1', 'Mindray M2'],
    'Medtronic': ['Medtronic D1', 'Medtronic D2'],
    'Abbott': ['Abbott A1', 'Abbott A2'],
    'BD': ['BD B1', 'BD B2'],
    'Stryker': ['Stryker K1', 'Stryker K2'],
    'Zimmer': ['Zimmer Z1', 'Zimmer Z2'],
    'Boston Scientific': ['BS B1', 'BS B2'],
  };

  static const List<String> serviceTypes = [
    'Preventivo',
    'Correctivo',
    'Calibración',
    'Instalación',
  ];
}
