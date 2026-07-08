import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import '../../controllers/report_controller.dart';
import '../../models/report_model.dart';
import '../../services/pdf_service.dart';
import '../../utils/constants.dart';

class PdfViewerScreen extends StatelessWidget {
  const PdfViewerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final report = context.watch<ReportController>().currentReport;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vista PDF'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Editar reporte',
            onPressed: () => Navigator.pushNamed(context, '/report', arguments: report),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Eliminar reporte',
            onPressed: () => _confirmDelete(context, report),
          ),
        ],
      ),
      body: PdfPreview(
        maxPageWidth: 700,
        build: (format) async {
          final pdfService = PdfService();
          final file = await pdfService.generatePdf(report);
          return file.readAsBytes();
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, ReportModel report) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Reporte'),
        content: const Text('¿Está seguro de eliminar este reporte?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<ReportController>().deleteReport(report.id);
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
