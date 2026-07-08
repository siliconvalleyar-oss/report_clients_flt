import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/report_model.dart';
import '../services/pdf_service.dart';

class ExportController extends ChangeNotifier {
  bool _isExporting = false;

  bool get isExporting => _isExporting;

  Future<void> exportToPdf(ReportModel report) async {
    _isExporting = true;
    notifyListeners();
    try {
      final pdfService = PdfService();
      await pdfService.generatePdf(report);
    } catch (e) {
      debugPrint('Error generating PDF: $e');
      rethrow;
    }
    _isExporting = false;
    notifyListeners();
  }

  Future<void> shareToWhatsApp(ReportModel report) async {
    try {
      final pdfService = PdfService();
      final file = await pdfService.generatePdf(report);
      await Share.shareXFiles([XFile(file.path)], text: 'Reporte Técnico - ${report.client.name}');
    } catch (e) {
      debugPrint('Error sharing to WhatsApp: $e');
      rethrow;
    }
  }

  Future<void> shareToEmail(ReportModel report) async {
    try {
      final uri = Uri(
        scheme: 'mailto',
        path: '',
        queryParameters: {
          'subject': 'Reporte Técnico - ${report.client.name}',
          'body': 'Adjunto reporte técnico de ${report.client.name}',
        },
      );
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (e) {
      debugPrint('Error sending email: $e');
      rethrow;
    }
  }

  Future<void> saveToDrive(ReportModel report) async {
    try {
      final pdfService = PdfService();
      await pdfService.generatePdf(report);
    } catch (e) {
      debugPrint('Error saving to Drive: $e');
      rethrow;
    }
  }
}
