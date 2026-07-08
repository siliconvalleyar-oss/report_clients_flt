import 'dart:io';
import 'package:printing/printing.dart';
import '../models/report_model.dart';
import 'industrial_form_template.dart' as form_template;

class PdfService {
  Future<File> generatePdf(ReportModel report) async {
    return form_template.generateIndustrialForm(report);
  }

  Future<void> printPdf(ReportModel report) async {
    final file = await generatePdf(report);
    await Printing.sharePdf(
      bytes: await file.readAsBytes(),
      filename: 'reporte_${report.client.name}.pdf',
    );
  }
}
