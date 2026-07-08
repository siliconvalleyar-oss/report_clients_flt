import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/report_model.dart';

class PdfService {
  Future<File> generatePdf(ReportModel report) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text('Reporte Técnico', style: pw.TextStyle(fontSize: 24)),
          ),
          pw.SizedBox(height: 16),
          pw.Text('Electromedicina Pro', style: pw.TextStyle(fontSize: 18)),
          pw.Divider(),
          pw.SizedBox(height: 16),
          pw.Header(level: 1, child: pw.Text('Datos del Cliente')),
          pw.Text('Nombre: ${report.client.name}'),
          pw.Text('Dirección: ${report.client.address}'),
          pw.SizedBox(height: 16),
          pw.Header(level: 1, child: pw.Text('Datos del Equipo')),
          pw.Text('Marca: ${report.equipment.brand}'),
          pw.Text('Modelo: ${report.equipment.model}'),
          pw.Text('N° Serie: ${report.equipment.serialNumber}'),
          pw.SizedBox(height: 16),
          pw.Header(level: 1, child: pw.Text('Servicio Realizado')),
          for (final service in report.services)
            pw.Text('• ${service.typeName}'),
          pw.SizedBox(height: 16),
          pw.Text('Descripción del problema:'),
          pw.Text(report.problemDescription),
          pw.SizedBox(height: 8),
          pw.Text('Trabajo realizado:'),
          pw.Text(report.workDone),
          pw.SizedBox(height: 16),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Repuestos: ${report.services.any((s) => s.hasSpareParts) ? "Sí" : "No"}'),
              pw.Text('Garantía: ${report.services.any((s) => s.hasWarranty) ? "Sí" : "No"}'),
            ],
          ),
          pw.SizedBox(height: 16),
          pw.Text('Observaciones: ${report.services.isNotEmpty ? report.services.first.observations : ""}'),
          pw.SizedBox(height: 32),
          if (report.clientSignature != null)
            pw.Container(
              height: 80,
              child: pw.Image(pw.MemoryImage(report.clientSignature!)),
            ),
          pw.SizedBox(height: 8),
          pw.Text('Firma del Cliente'),
          pw.SizedBox(height: 32),
          pw.Text('Sello de la Empresa: ${report.companyStamp}'),
        ],
      ),
    );

    final outputDir = Directory('/storage/emulated/0/Download');
    if (!await outputDir.exists()) {
      await outputDir.create(recursive: true);
    }

    final file = File('${outputDir.path}/reporte_${report.client.name.replaceAll(" ", "_")}_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  Future<void> printPdf(ReportModel report) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Text('Reporte Técnico - ${report.client.name}'),
        ],
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'reporte_${report.client.name}.pdf',
    );
  }
}
