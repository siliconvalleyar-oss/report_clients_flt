import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class WhatsAppService {
  Future<void> shareReport(String filePath, String clientName) async {
    try {
      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'Reporte Técnico - $clientName',
      );
    } catch (e) {
      debugPrint('Error sharing via WhatsApp: $e');
      rethrow;
    }
  }
}
