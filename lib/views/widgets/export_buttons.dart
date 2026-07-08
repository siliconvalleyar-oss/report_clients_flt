import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/export_controller.dart';
import '../../models/report_model.dart';
import '../../services/pdf_service.dart';

class ExportButtons extends StatelessWidget {
  final ReportModel report;

  const ExportButtons({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final exportController = context.watch<ExportController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _button(
          icon: Icons.picture_as_pdf,
          label: 'Generar y Exportar PDF',
          color: const Color(0xFFD32F2F),
          onTap: () => _exportPdf(context, exportController),
        ),
        const SizedBox(height: 12),
        _button(
          icon: Icons.share,
          label: 'Compartir por WhatsApp',
          color: const Color(0xFF25D366),
          onTap: () => _shareWhatsApp(context, exportController),
        ),
        const SizedBox(height: 12),
        _button(
          icon: Icons.email,
          label: 'Enviar por Email',
          color: const Color(0xFFEA4335),
          onTap: () => _shareEmail(context, exportController),
        ),
        const SizedBox(height: 12),
        _button(
          icon: Icons.cloud_upload,
          label: 'Guardar en Google Drive',
          color: const Color(0xFF4285F4),
          onTap: () => _saveDrive(context, exportController),
        ),
        const SizedBox(height: 12),
        _button(
          icon: Icons.print,
          label: 'Imprimir',
          color: Colors.blueGrey,
          onTap: () => _printReport(context),
        ),
      ],
    );
  }

  Future<void> _exportPdf(BuildContext context, ExportController controller) async {
    try {
      await controller.exportToPdf(report);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF generado correctamente'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al generar PDF: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _shareWhatsApp(BuildContext context, ExportController controller) async {
    try {
      await controller.shareToWhatsApp(report);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al compartir: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _shareEmail(BuildContext context, ExportController controller) async {
    try {
      await controller.shareToEmail(report);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al enviar email: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _saveDrive(BuildContext context, ExportController controller) async {
    try {
      await controller.saveToDrive(report);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF guardado en la carpeta de la aplicación'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _printReport(BuildContext context) async {
    try {
      final pdfService = PdfService();
      await pdfService.printPdf(report);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al imprimir: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _button({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
