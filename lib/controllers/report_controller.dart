import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/report_model.dart';

class ReportController extends ChangeNotifier {
  ReportModel _currentReport = ReportModel.empty();
  List<ReportModel> _history = [];
  bool _isLoading = false;
  String _searchQuery = '';

  ReportModel get currentReport => _currentReport;
  List<ReportModel> get history => _filteredHistory;
  bool get isLoading => _isLoading;

  List<ReportModel> get _filteredHistory {
    if (_searchQuery.isEmpty) return _history;
    return _history.where((r) =>
      r.client.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      r.equipment.brand.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      r.equipment.model.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  Future<void> loadHistory() async {
    _isLoading = true;
    notifyListeners();
    try {
      final box = await Hive.openBox<Map>('reports');
      final data = box.values.toList();
      _history = data.map((e) => ReportModel.fromMap(Map<String, dynamic>.from(e))).toList();
      _history.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      debugPrint('Error loading history: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveReport() async {
    try {
      final box = await Hive.openBox<Map>('reports');
      await box.put(_currentReport.id, _currentReport.toMap());
      await loadHistory();
    } catch (e) {
      debugPrint('Error saving report: $e');
      rethrow;
    }
  }

  Future<void> deleteReport(String id) async {
    try {
      final box = await Hive.openBox<Map>('reports');
      await box.delete(id);
      await loadHistory();
    } catch (e) {
      debugPrint('Error deleting report: $e');
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void updateClient(String name, String address) {
    _currentReport = _currentReport.copyWith(
      client: _currentReport.client,
    );
    notifyListeners();
  }

  void setReport(ReportModel report) {
    _currentReport = report;
    notifyListeners();
  }

  void resetReport() {
    _currentReport = ReportModel.empty();
    notifyListeners();
  }
}
