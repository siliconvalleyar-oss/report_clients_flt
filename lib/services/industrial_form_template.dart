import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/report_model.dart';
import 'storage_service.dart';

const _mg = 24.0;
const _blue = PdfColors.blue800;
const _ln = 0.3;
const _gap = 2.5;

double get _uw => PdfPageFormat.a4.width - 2 * _mg;
double get _uh => PdfPageFormat.a4.height - 2 * _mg;

pw.Font _f(String family) {
  switch (family) {
    case 'Times-Roman': return pw.Font.times();
    case 'Courier': return pw.Font.courier();
    default: return pw.Font.helvetica();
  }
}
pw.Font _fb(String family) {
  switch (family) {
    case 'Times-Roman': return pw.Font.timesBold();
    case 'Courier': return pw.Font.courierBold();
    default: return pw.Font.helveticaBold();
  }
}

Future<FontConfig> _fc() async {
  try { return await StorageService.getFontConfig(); } catch (_) { return const FontConfig(); }
}

pw.Widget _bar(String t, {pw.Font? fo}) => pw.Container(
  width: _uw, color: _blue,
  padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
  child: pw.Text(t, style: pw.TextStyle(fontSize: 6, color: PdfColors.white, letterSpacing: 2, font: fo)),
);

pw.Widget _fld({double? w, double h = 11, String text = ''}) => pw.Container(
  width: w ?? _uw, height: h,
  decoration: pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey400, width: _ln))),
  child: pw.Text(text, style: const pw.TextStyle(fontSize: 6.5), textAlign: pw.TextAlign.start),
);

pw.Widget _lbl(String t, {double? w, double fs = 5.5, pw.Font? fo}) => pw.Container(
  width: w, padding: const pw.EdgeInsets.only(bottom: 0.5),
  child: pw.Text(t, style: pw.TextStyle(fontSize: fs, color: PdfColors.grey600, letterSpacing: 0.8, font: fo)),
);

pw.Widget _ff(String label, String value, {double? w, double h = 11}) => pw.Column(
  crossAxisAlignment: pw.CrossAxisAlignment.start,
  children: [_lbl(label, w: w), _fld(w: w, h: h, text: value)],
);

pw.Widget _bx(List<pw.Widget> c) => pw.Container(
  width: _uw, padding: const pw.EdgeInsets.fromLTRB(4, 2, 4, 0),
  decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey400, width: _ln)),
  child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: c),
);

Future<File> generateIndustrialForm(ReportModel report) async {
  final pdf = pw.Document();
  final logo = pw.MemoryImage((await rootBundle.load('assets/marca/marca.png')).buffer.asUint8List());
  Uint8List? stamp;
  try { stamp = await StorageService.getStampImage(); } catch (_) {}
  final cf = await _fc();
  final n = _f(cf.contentFamily);
  final b = _fb(cf.contentFamily);

  final w2 = (_uw - 6) / 2;
  final w3 = (_uw - 12) / 3;
  final w4 = (_uw - 18) / 4;

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.all(_mg),
      build: (_) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          /* ===== ENCABEZADO FIJO ===== */
          pw.Container(
            height: 36,
            decoration: pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: _blue, width: 1.2))),
            child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.center, children: [
              pw.Transform.rotate(angle: -0.18, child: pw.Container(width: 30, height: 30, child: pw.Image(logo, fit: pw.BoxFit.contain))),
              pw.SizedBox(width: 8),
              pw.Expanded(child: pw.Center(child: pw.Column(mainAxisAlignment: pw.MainAxisAlignment.center, children: [
                pw.Text('ELECTROMEDICINA PRO', style: pw.TextStyle(fontSize: 10, font: _fb('Helvetica'), letterSpacing: 3, color: _blue)),
                pw.Text('SERVICIO TÉCNICO ESPECIALIZADO', style: pw.TextStyle(fontSize: 5, color: PdfColors.grey500, letterSpacing: 2)),
              ]))),
              pw.SizedBox(width: 8),
              pw.SizedBox(width: 90, child: pw.Column(mainAxisAlignment: pw.MainAxisAlignment.center, crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
                pw.Text('${report.createdAt.day.toString().padLeft(2, '0')}/${report.createdAt.month.toString().padLeft(2, '0')}/${report.createdAt.year}   ${report.createdAt.hour.toString().padLeft(2, '0')}:${report.createdAt.minute.toString().padLeft(2, '0')}', style: const pw.TextStyle(fontSize: 6, color: PdfColors.grey700)),
                pw.Text(report.serviceLocation.isNotEmpty ? report.serviceLocation : 'Bs. As., Argentina', style: const pw.TextStyle(fontSize: 5.5, color: PdfColors.grey500)),
              ])),
            ]),
          ),
          pw.SizedBox(height: 2),

          /* ===== DATOS EMPRESA ===== */
          pw.Container(
            height: 18, width: _uw, padding: const pw.EdgeInsets.symmetric(horizontal: 4),
            decoration: pw.BoxDecoration(border: pw.Border.all(color: _blue, width: 0.6)),
            child: pw.Row(children: [
              pw.Text('Electromedicina Pro', style: pw.TextStyle(fontSize: 6.5, font: b, color: _blue)),
              pw.SizedBox(width: 10),
              pw.Text('Tel: 011-4567-8900', style: pw.TextStyle(fontSize: 6, font: n, color: PdfColors.grey700)),
              pw.SizedBox(width: 10),
              pw.Text('info@electromedicinapro.com', style: pw.TextStyle(fontSize: 6, font: n, color: PdfColors.grey700)),
              pw.SizedBox(width: 10),
              pw.Text('Buenos Aires, Argentina', style: pw.TextStyle(fontSize: 6, font: n, color: PdfColors.grey700)),
            ]),
          ),
          pw.SizedBox(height: 3),

          /* ===== 1. DATOS DEL CLIENTE ===== */
          _bar('1.  DATOS DEL CLIENTE', fo: b),
          pw.SizedBox(height: 1.5),
          pw.Container(
            height: 28, width: _uw, padding: const pw.EdgeInsets.fromLTRB(4, 2, 4, 0),
            decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey400, width: _ln)),
            child: pw.Column(children: [
              pw.Row(children: [
                _ff('CLIENTE', report.client.name, w: w2, h: 9), pw.SizedBox(width: 6),
                _ff('DIRECCIÓN', report.client.address, w: w2, h: 9),
              ]),
              pw.SizedBox(height: 1),
              pw.Row(children: [
                _ff('TÉCNICO', report.technician, w: w2, h: 9), pw.SizedBox(width: 6),
                _ff('CARGO', report.position, w: w2, h: 9),
              ]),
            ]),
          ),
          pw.SizedBox(height: _gap),

          /* ===== 2. EQUIPO ===== */
          _bar('2.  EQUIPO', fo: b),
          pw.SizedBox(height: 1.5),
          pw.Container(
            height: 24, width: _uw, padding: const pw.EdgeInsets.fromLTRB(4, 2, 4, 0),
            decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey400, width: _ln)),
            child: pw.Row(children: [
              _ff('MARCA', report.equipmentBrand, w: w3, h: 9), pw.SizedBox(width: 6),
              _ff('MODELO', report.equipmentModel, w: w3, h: 9), pw.SizedBox(width: 6),
              _ff('N° SERIE', report.serialNumber, w: w3, h: 9),
            ]),
          ),
          pw.SizedBox(height: _gap),

          /* ===== 3. SERVICIO ===== */
          _bar('3.  SERVICIO', fo: b),
          pw.SizedBox(height: 1.5),
          pw.Container(
            height: 24, width: _uw, padding: const pw.EdgeInsets.fromLTRB(4, 2, 4, 0),
            decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey400, width: _ln)),
            child: pw.Row(children: [
              _ff('TIPO DE SERVICIO', report.serviceType, w: w2, h: 9), pw.SizedBox(width: 6),
              _ff('FECHA Y HORA', '${report.createdAt.day.toString().padLeft(2, '0')}/${report.createdAt.month.toString().padLeft(2, '0')}/${report.createdAt.year} ${report.createdAt.hour.toString().padLeft(2, '0')}:${report.createdAt.minute.toString().padLeft(2, '0')}', w: w2, h: 9),
            ]),
          ),
          pw.SizedBox(height: _gap),

          /* ===== 4. PROBLEMA REPORTADO ===== */
          _bar('4.  PROBLEMA REPORTADO', fo: b),
          pw.SizedBox(height: 1.5),
          pw.Container(
            height: 20, width: _uw, padding: const pw.EdgeInsets.fromLTRB(4, 2, 4, 0),
            decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey400, width: _ln)),
            child: _fld(w: _uw, h: 14, text: report.reportedProblem),
          ),
          pw.SizedBox(height: _gap),

          /* ===== 5. ITEMS ===== */
          _bar('5.  ITEMS / REPUESTOS', fo: b),
          pw.SizedBox(height: 1.5),
          pw.Container(
            width: _uw,
            decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey400, width: _ln)),
            child: pw.Column(children: [
              pw.Row(children: [
                pw.Container(width: _uw * 0.06, color: _blue, padding: const pw.EdgeInsets.symmetric(vertical: 1.5), child: pw.Text('#', style: const pw.TextStyle(fontSize: 5, color: PdfColors.white, font: b), textAlign: pw.TextAlign.center)),
                pw.Container(width: _uw * 0.36, color: _blue, padding: const pw.EdgeInsets.symmetric(vertical: 1.5), child: pw.Text('DESCRIPCIÓN', style: const pw.TextStyle(fontSize: 5, color: PdfColors.white, font: b), textAlign: pw.TextAlign.center)),
                pw.Container(width: _uw * 0.24, color: _blue, padding: const pw.EdgeInsets.symmetric(vertical: 1.5), child: pw.Text('MODELO / REF.', style: const pw.TextStyle(fontSize: 5, color: PdfColors.white, font: b), textAlign: pw.TextAlign.center)),
                pw.Container(width: _uw * 0.1, color: _blue, padding: const pw.EdgeInsets.symmetric(vertical: 1.5), child: pw.Text('CANT.', style: const pw.TextStyle(fontSize: 5, color: PdfColors.white, font: b), textAlign: pw.TextAlign.center)),
                pw.Container(width: _uw * 0.12, color: _blue, padding: const pw.EdgeInsets.symmetric(vertical: 1.5), child: pw.Text('PRECIO \$', style: const pw.TextStyle(fontSize: 5, color: PdfColors.white, font: b), textAlign: pw.TextAlign.center)),
                pw.Container(width: _uw * 0.12, color: _blue, padding: const pw.EdgeInsets.symmetric(vertical: 1.5), child: pw.Text('TOTAL \$', style: const pw.TextStyle(fontSize: 5, color: PdfColors.white, font: b), textAlign: pw.TextAlign.center)),
              ]),
              ...List.generate(3, (i) {
                final it = i < report.items.length ? report.items[i] : null;
                return pw.Container(
                  height: 10,
                  decoration: i < 2 ? pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: _ln))) : null,
                  child: pw.Row(children: [
                    pw.Container(width: _uw * 0.06, alignment: pw.Alignment.center, child: pw.Text('${i + 1}', style: pw.TextStyle(fontSize: 5.5, color: PdfColors.grey700, font: n))),
                    pw.Container(width: _uw * 0.36, padding: const pw.EdgeInsets.only(left: 2), child: pw.Text(it?.description ?? '', style: pw.TextStyle(fontSize: 5.5, font: n))),
                    pw.Container(width: _uw * 0.24, padding: const pw.EdgeInsets.only(left: 2), child: pw.Text(it?.model ?? '', style: pw.TextStyle(fontSize: 5.5, font: n))),
                    pw.Container(width: _uw * 0.1, alignment: pw.Alignment.center, child: pw.Text(it != null ? '${it.quantity}' : '', style: pw.TextStyle(fontSize: 5.5, font: n))),
                    pw.Container(width: _uw * 0.12, alignment: pw.Alignment.centerRight, padding: const pw.EdgeInsets.only(right: 2), child: pw.Text(it != null && it.price > 0 ? '\$${it.price.toStringAsFixed(2)}' : '', style: pw.TextStyle(fontSize: 5.5, font: n))),
                    pw.Container(width: _uw * 0.12, alignment: pw.Alignment.centerRight, padding: const pw.EdgeInsets.only(right: 2), child: pw.Text(it != null && it.total > 0 ? '\$${it.total.toStringAsFixed(2)}' : '', style: pw.TextStyle(fontSize: 5.5, font: n))),
                  ]),
                );
              }),
            ]),
          ),
          pw.SizedBox(height: _gap),

          /* ===== 6. PRESUPUESTO ===== */
          _bar('6.  PRESUPUESTO', fo: b),
          pw.SizedBox(height: 1.5),
          pw.Container(
            height: 22, width: _uw, padding: const pw.EdgeInsets.fromLTRB(4, 2, 4, 0),
            decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey400, width: _ln)),
            child: pw.Row(children: [
              _ff('N° PRESUPUESTO', report.budgetNumber, w: w4, h: 9), pw.SizedBox(width: 6),
              _ff('COSTO \$', report.serviceCost > 0 ? '\$${report.serviceCost.toStringAsFixed(2)}' : '', w: w4, h: 9), pw.SizedBox(width: 6),
              _ff('GASTOS \$', report.expenses > 0 ? '\$${report.expenses.toStringAsFixed(2)}' : '', w: w4, h: 9), pw.SizedBox(width: 6),
              _ff('TOTAL \$', report.totalCost > 0 ? '\$${report.totalCost.toStringAsFixed(2)}' : '', w: w4, h: 9),
            ]),
          ),
          pw.SizedBox(height: _gap),

          /* ===== 7. OBSERVACIONES ===== */
          _bar('7.  OBSERVACIONES — DIAGNÓSTICO', fo: b),
          pw.SizedBox(height: 1.5),
          pw.Container(
            width: _uw,
            decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey400, width: _ln)),
            child: pw.Column(children: [
              pw.Container(
                height: 16,
                padding: const pw.EdgeInsets.only(left: 3, top: 1),
                child: pw.Text(report.observations.isNotEmpty ? report.observations : '', style: pw.TextStyle(fontSize: 6, font: n)),
              ),
              pw.Container(
                height: 14,
                decoration: pw.BoxDecoration(border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300, width: _ln))),
                padding: const pw.EdgeInsets.only(left: 3, top: 1),
                child: pw.Text('', style: pw.TextStyle(fontSize: 6, font: n)),
              ),
              pw.Container(
                height: 14,
                decoration: pw.BoxDecoration(border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300, width: _ln))),
                padding: const pw.EdgeInsets.only(left: 3, top: 1),
                child: pw.Text('', style: pw.TextStyle(fontSize: 6, font: n)),
              ),
            ]),
          ),
          pw.SizedBox(height: _gap),

          /* ===== 8. FIRMAS ===== */
          _bar('8.  FIRMAS — CONFORMIDAD', fo: b),
          pw.SizedBox(height: 1.5),
          pw.Container(
            height: 34, width: _uw, padding: const pw.EdgeInsets.fromLTRB(4, 2, 4, 0),
            decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey400, width: _ln)),
            child: pw.Row(children: [
              pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                _lbl('FIRMA DEL TÉCNICO', w: w2, fo: b),
                _fld(w: w2, h: 24),
              ]),
              pw.SizedBox(width: 6),
              pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                _lbl('FIRMA DEL CLIENTE', w: w2, fo: b),
                pw.Row(children: [
                  _fld(w: w2 - 60, h: 24),
                  if (stamp != null) pw.Container(width: 55, height: 24, margin: const pw.EdgeInsets.only(left: 5), child: pw.Image(pw.MemoryImage(stamp), fit: pw.BoxFit.contain)),
                ]),
              ]),
            ]),
          ),
        ],
      ),
    ),
  );

  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/informe_${report.client.name.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf');
  await file.writeAsBytes(await pdf.save(), flush: true);
  return file;
}
