import 'package:flutter/material.dart';

class ValidationController extends ChangeNotifier {
  final Map<String, String?> _errors = {};

  Map<String, String?> get errors => _errors;

  bool validateRequired(String field, String? value) {
    if (value == null || value.trim().isEmpty) {
      _errors[field] = 'Este campo es obligatorio';
      notifyListeners();
      return false;
    }
    _errors.remove(field);
    notifyListeners();
    return true;
  }

  bool validateEmail(String field, String? value) {
    if (value == null || value.trim().isEmpty) {
      _errors[field] = 'Este campo es obligatorio';
      notifyListeners();
      return false;
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      _errors[field] = 'Email no válido';
      notifyListeners();
      return false;
    }
    _errors.remove(field);
    notifyListeners();
    return true;
  }

  void clearErrors() {
    _errors.clear();
    notifyListeners();
  }

  bool get hasErrors => _errors.isNotEmpty;

  String? getError(String field) => _errors[field];
}
