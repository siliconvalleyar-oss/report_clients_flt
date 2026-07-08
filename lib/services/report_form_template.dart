import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/report_model.dart';
import 'storage_service.dart';

const _margin = 36.0;
double get _usableW => PdfPageFormat.a4.width - 2 * _margin;
const _colGap = 10.0;
const _rowH = 18.0;
const _fieldH = 14.0;
const _lineW = 0.5;
const _accent = PdfColors.grey700;

pw.Font _font(String f) {
  switch (f) {
    case 'Times-Roman': return pw.Font.times();
    case 'Courier': return pw.Font.courier();
    default: return pw.Font.helvetica();
  }
}
pw.Font _fontBold(String f) {
  switch (f) {
    case 'Times-Roman': return pw.Font.timesBold();
    case 'Courier': return pw.Font.courierBold();
    default: return pw.Font.helveticaBold();
  }
}

Future<FontConfig> _fc() async {
  try { return await StorageService.getFontConfig(); } catch (_) { return const FontConfig(); }
}

pw.Widget _cell(String text, {double? w, double? h, pw.Font? font, double fontSize = 6, PdfColor? color, pw.TextAlign align = pw.TextAlign.left, bool border = true}) =>
    pw.Container(
      width: w, height: h,
      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: border ? pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey400, width: 0.3)) : null,
      child: pw.Text(text, style: pw.TextStyle(fontSize: fontSize, font: font, color: color ?? PdfColors.grey800), textAlign: align),
    );

pw.Widget _label(String text, {double? w, double fontSize = 7, pw.Font? font}) =>
    pw.Container(
      width: w,
      padding: const pw.EdgeInsets.only(bottom: 1),
      child: pw.Text(text, style: pw.TextStyle(fontSize: fontSize, font: font, color: PdfColors.grey500, letterSpacing: 1.1)),
    );

pw.Widget _field({double? w, double h = _fieldH}) =>
    pw.Container(
      width: w, height: h,
      decoration: pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey400, width: 0.3)),
      ),
    );

pw.Widget _fieldRow(List<double> widths) =>
    pw.Row(children: widths.map((w) => _field(w: w)).toList());

pw.Widget _boxLabel(String text, {double fontSize = 6}) =>
    pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 1),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey500, width: 0.4),
        color: PdfColors.grey100,
      ),
      child: pw.Text(text, style: pw.TextStyle(fontSize: fontSize, color: PdfColors.grey700)),
    );

Future<File> generateFormPdf(ReportModel report) async {
  final pdf = pw.Document();
  final logo = pw.MemoryImage((await rootBundle.load('assets/marca/marca.png')).buffer.asUint8List());
  Uint8List? stamp;
  try { stamp = await StorageService.getStampImage(); } catch (_) {}
  final cf = await _fc();

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.all(_margin),
      build: (ctx) {
        final t = _font(cf.titleFamily);
        final b = _fontBold(cf.titleFamily);
        final l = _font(cf.labelFamily);
        final c = _font(cf.contentFamily);
        final ts = cf.titleSize + 3.0;
        final ls = cf.labelSize;
        final cs = cf.contentSize;

        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            /* ========== ZONA 1: ENCABEZADO (10%) ========== */
            pw.Container(
              height: _rowH * 4.2,
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Transform.rotate(
                    angle: -0.18,
                    child: pw.Container(width: 44, height: 44, child: pw.Image(logo, fit: pw.BoxFit.contain)),
                  ),
                  pw.SizedBox(width: 12),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        pw.Text('ELECTROMEDICINA PRO', style: pw.TextStyle(fontSize: ts - 2, font: b, letterSpacing: 3, color: _accent)),
                        pw.Text('SERVICIO TÉCNICO ESPECIALIZADO', style: pw.TextStyle(fontSize: 7, font: t, letterSpacing: 2.5, color: PdfColors.grey500)),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 60, child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      _label('N° DE ORDEN', fontSize: 6, font: t),
                      pw.Text(report.id, style: pw.TextStyle(fontSize: cs, font: c, color: PdfColors.grey800)),
                      pw.SizedBox(height: 4),
                      _label('FECHA', fontSize: 6, font: t),
                      pw.Text('${report.createdAt.day.toString().padLeft(2, '0')}/${report.createdAt.month.toString().padLeft(2, '0')}/${report.createdAt.year}',
                          style: pw.TextStyle(fontSize: cs, font: c, color: PdfColors.grey800)),
                    ],
                  )),
                ],
              ),
            ),
            pw.Divider(height: 1, thickness: 0.8, color: _accent),
            pw.SizedBox(height: 6),

            /* ========== ZONA 2: DATOS GENERALES (15%) ========== */
            pw.Container(
              height: _rowH * 6.5,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _boxLabel('DATOS DEL CLIENTE Y SERVICIO', fontSize: 7),
                  pw.SizedBox(height: 4),
                  pw.Row(children: [
                    _label('Cliente', w: (_usableW - _colGap) * 0.5, fontSize: ls, font: t),
                    _label('Dirección', w: (_usableW - _colGap) * 0.5, fontSize: ls, font: t),
                  ]),
                  pw.Row(children: [
                    _field(w: (_usableW - _colGap) * 0.5),
                    _field(w: (_usableW - _colGap) * 0.5),
                  ]),
                  pw.SizedBox(height: 3),
                  pw.Row(children: [
                    _label('Teléfono', w: (_usableW - _colGap) * 0.5, fontSize: ls, font: t),
                    _label('Email', w: (_usableW - _colGap) * 0.5, fontSize: ls, font: t),
                  ]),
                  pw.Row(children: [
                    _field(w: (_usableW - _colGap) * 0.5),
                    _field(w: (_usableW - _colGap) * 0.5),
                  ]),
                  pw.SizedBox(height: 3),
                  pw.Row(children: [
                    _label('Lugar de servicio', w: (_usableW - _colGap) * 0.5, fontSize: ls, font: t),
                    _label('Técnico asignado', w: (_usableW - _colGap) * 0.5, fontSize: ls, font: t),
                  ]),
                  pw.Row(children: [
                    _field(w: (_usableW - _colGap) * 0.5),
                    _field(w: (_usableW - _colGap) * 0.5),
                  ]),
                ],
              ),
            ),
            pw.SizedBox(height: 6),

            /* ========== ZONA 3: IDENTIFICACIÓN DEL EQUIPO (10%) ========== */
            pw.Container(
              height: _rowH * 4.5,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _boxLabel('IDENTIFICACIÓN DEL EQUIPO', fontSize: 7),
                  pw.SizedBox(height: 4),
                  pw.Row(children: [
                    _label('Marca', w: (_usableW - 2 * _colGap) / 3, fontSize: ls, font: t),
                    _label('Modelo', w: (_usableW - 2 * _colGap) / 3, fontSize: ls, font: t),
                    _label('N° de serie', w: (_usableW - 2 * _colGap) / 3, fontSize: ls, font: t),
                  ]),
                  pw.Row(children: [
                    _field(w: (_usableW - 2 * _colGap) / 3),
                    _field(w: (_usableW - 2 * _colGap) / 3),
                    _field(w: (_usableW - 2 * _colGap) / 3),
                  ]),
                  pw.SizedBox(height: 5),
                  pw.Row(children: [
                    _label('Problema reportado', w: _usableW, fontSize: ls, font: t),
                  ]),
                  _field(w: _usableW, h: _fieldH * 1.8),
                ],
              ),
            ),
            pw.SizedBox(height: 6),

            /* ========== ZONA 4: TABLA TÉCNICA (18%) ========== */
            pw.Container(
              height: _rowH * 7.5,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _boxLabel('REGISTRO TÉCNICO — ITEMS / REPUESTOS / COSTOS', fontSize: 7),
                  pw.SizedBox(height: 4),
                  pw.Container(
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
                    ),
                    child: pw.Table(
                      border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.3),
                      columnWidths: {
                        0: const pw.FlexColumnWidth(0.8),
                        1: const pw.FlexColumnWidth(3),
                        2: const pw.FlexColumnWidth(2.5),
                        3: const pw.FlexColumnWidth(1.5),
                        4: const pw.FlexColumnWidth(1.5),
                      },
                      children: [
                        pw.TableRow(
                          decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                          children: ['#', 'Descripción', 'Modelo / Referencia', 'Cant.', 'Costo \u0024'].map((h) =>
                            _cell(h, font: b, fontSize: 6.5, color: _accent, align: pw.TextAlign.center, h: _fieldH)
                          ).toList(),
                        ),
                        ...List.generate(5, (i) => pw.TableRow(
                          children: [
                            _cell('${i + 1}', font: c, fontSize: 6.5, align: pw.TextAlign.center, h: _fieldH - 1),
                            _cell('', font: c, fontSize: 6.5, h: _fieldH - 1),
                            _cell('', font: c, fontSize: 6.5, h: _fieldH - 1),
                            _cell('', font: c, fontSize: 6.5, align: pw.TextAlign.center, h: _fieldH - 1),
                            _cell('', font: c, fontSize: 6.5, align: pw.TextAlign.center, h: _fieldH - 1),
                          ],
                        )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 6),

            /* ========== ZONA 5: INFORMACIÓN OPERATIVA (15%) ========== */
            pw.Container(
              height: _rowH * 6,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _boxLabel('INFORMACIÓN OPERATIVA', fontSize: 7),
                  pw.SizedBox(height: 4),
                  pw.Row(children: [
                    _label('Tipo de servicio', w: (_usableW - 2 * _colGap) / 3, fontSize: ls, font: t),
                    _label('Repuestos', w: (_usableW - 2 * _colGap) / 3, fontSize: ls, font: t),
                    _label('Garantía', w: (_usableW - 2 * _colGap) / 3, fontSize: ls, font: t),
                  ]),
                  pw.Row(children: [
                    _field(w: (_usableW - 2 * _colGap) / 3),
                    _field(w: (_usableW - 2 * _colGap) / 3),
                    _field(w: (_usableW - 2 * _colGap) / 3),
                  ]),
                  pw.SizedBox(height: 5),
                  pw.Row(children: [
                    _label('Presupuesto N°', w: (_usableW - 3 * _colGap) / 4, fontSize: ls, font: t),
                    _label('Costo del servicio \u0024', w: (_usableW - 3 * _colGap) / 4, fontSize: ls, font: t),
                    _label('Gastos \u0024', w: (_usableW - 3 * _colGap) / 4, fontSize: ls, font: t),
                    _label('Total \u0024', w: (_usableW - 3 * _colGap) / 4, fontSize: ls, font: t),
                  ]),
                  pw.Row(children: [
                    _field(w: (_usableW - 3 * _colGap) / 4),
                    _field(w: (_usableW - 3 * _colGap) / 4),
                    _field(w: (_usableW - 3 * _colGap) / 4),
                    _field(w: (_usableW - 3 * _colGap) / 4),
                  ]),
                  pw.SizedBox(height: 5),
                  pw.Row(children: [
                    _label('Servicio realizado', w: _usableW, fontSize: ls, font: t),
                  ]),
                  _field(w: _usableW, h: _fieldH * 2),
                ],
              ),
            ),
            pw.SizedBox(height: 6),

            /* ========== ZONA 6: OBSERVACIONES / DIAGNÓSTICO (22–25%) ========== */
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _boxLabel('OBSERVACIONES — DIAGNÓSTICO — REPARACIONES', fontSize: 7),
                  pw.SizedBox(height: 4),
                  pw.Expanded(
                    child: pw.Container(
                      width: _usableW,
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey400, width: 0.3),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _cell('', font: c, fontSize: 6.5, h: _fieldH * 1.5, border: true),
                          pw.Divider(height: 0.3, color: PdfColors.grey300),
                          _cell('', font: c, fontSize: 6.5, h: _fieldH * 1.5, border: true),
                          pw.Divider(height: 0.3, color: PdfColors.grey300),
                          _cell('', font: c, fontSize: 6.5, h: _fieldH * 1.5, border: true),
                          pw.Divider(height: 0.3, color: PdfColors.grey300),
                          _cell('', font: c, fontSize: 6.5, h: _fieldH * 1.5, border: true),
                          pw.Divider(height: 0.3, color: PdfColors.grey300),
                          _cell('', font: c, fontSize: 6.5, h: _fieldH * 1.5, border: true),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 6),

            /* ========== ZONA 7: CIERRE ADMINISTRATIVO ========== */
            pw.Container(
              height: _rowH * 4.5,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _boxLabel('CIERRE Y CONFORMIDAD', fontSize: 7),
                  pw.SizedBox(height: 4),
                  pw.Row(children: [
                    _label('Estado final del servicio', w: (_usableW - _colGap) * 0.5, fontSize: ls, font: t),
                    _label('Conformidad del cliente', w: (_usableW - _colGap) * 0.5, fontSize: ls, font: t),
                  ]),
                  pw.Row(children: [
                    _field(w: (_usableW - _colGap) * 0.5),
                    _field(w: (_usableW - _colGap) * 0.5),
                  ]),
                  pw.SizedBox(height: 5),
                  pw.Row(children: [
                    _label('Firma del técnico', w: (_usableW - _colGap) * 0.5, fontSize: ls, font: t),
                    _label('Firma del cliente', w: (_usableW - _colGap) * 0.5, fontSize: ls, font: t),
                  ]),
                  pw.Row(children: [
                    _field(w: (_usableW - _colGap) * 0.5, h: _rowH * 1.5),
                    _field(w: (_usableW - _colGap) * 0.5, h: _rowH * 1.5),
                  ]),
                  pw.SizedBox(height: 4),
                  pw.Row(mainAxisAlignment: pw.MainAxisAlignment.end, children: [
                    if (stamp != null)
                      pw.Container(width: 60, height: 30, child: pw.Image(pw.MemoryImage(stamp), fit: pw.BoxFit.contain)),
                  ]),
                ],
              ),
            ),
          ],
        );
      },
    ),
  );

  final dir = await getApplicationDocumentsDirectory();
  final file = File(
    '${dir.path}/formulario_${report.client.name.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf',
  );
  await file.writeAsBytes(await pdf.save(), flush: true);
  return file;
}
