import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmailService {
  Future<void> sendReport(String email, String clientName, {String? filePath}) async {
    try {
      final uri = Uri(
        scheme: 'mailto',
        path: email,
        queryParameters: {
          'subject': 'Reporte Técnico - $clientName',
          'body': 'Adjunto reporte técnico de $clientName',
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
}
