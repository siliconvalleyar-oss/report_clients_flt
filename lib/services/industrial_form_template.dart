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
const _gap = 6.0;
const _pw = 547.0;

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

String _san(String s) => String.fromCharCodes(s.runes.where((r) => r >= 0x20 && r <= 0x7E || r >= 0xA0 && r <= 0xFF));

pw.Widget _bar(String t, {pw.Font? fo}) => pw.Container(
  width: _pw, color: _blue,
  padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
  child: pw.Text(t, style: pw.TextStyle(fontSize: 6, color: PdfColors.white, letterSpacing: 2, font: fo)),
);

pw.Widget _fld({double? w, double h = 11, String text = ''}) => pw.Container(
  width: w ?? _pw, height: h,
  decoration: pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey400, width: _ln))),
  child: pw.Text(_san(text), style: const pw.TextStyle(fontSize: 6.5), textAlign: pw.TextAlign.start),
);

pw.Widget _lbl(String t, {double? w, double fs = 5.5, pw.Font? fo}) => pw.Container(
  width: w, padding: const pw.EdgeInsets.only(bottom: 0.5),
  child: pw.Text(t, style: pw.TextStyle(fontSize: fs, color: PdfColors.grey600, letterSpacing: 0.8, font: fo)),
);

pw.Widget _ff(String label, String value, {double? w, double h = 11}) => pw.Column(
  crossAxisAlignment: pw.CrossAxisAlignment.start,
  children: [_lbl(label, w: w), _fld(w: w, h: h, text: value)],
);

pw.Widget _sec(String t, pw.Widget box, {pw.Font? fo}) => pw.Column(
  crossAxisAlignment: pw.CrossAxisAlignment.start,
  children: [_bar(t, fo: fo), pw.SizedBox(height: 1.5), box, pw.SizedBox(height: _gap)],
);

Future<File> generateIndustrialForm(ReportModel report) async {
  final pdf = pw.Document();

  Uint8List watermarkBytes;
  try {
    watermarkBytes = (await rootBundle.load('assets/fondo/fondo.png')).buffer.asUint8List();
  } catch (_) {
    watermarkBytes = Uint8List(0);
  }

  Uint8List? stamp;
  try { stamp = await StorageService.getStampImage(); } catch (_) {}
  Uint8List? customLogo;
  try { customLogo = await StorageService.getLogoImage(); } catch (_) {}
  final companyData = await StorageService.loadCompanyData();
  final wmSettings = await StorageService.loadWatermarkSettings();
  final wmEnabled = wmSettings['enabled'] as bool;
  final wmOpacity = (wmSettings['opacity'] as num).toDouble();
  final cName = companyData['name'] ?? 'Electromedicina Pro';
  final cAddress = companyData['address'] ?? 'Buenos Aires, Argentina';
  final cPhone = companyData['phone'] ?? '';
  final cEmail = companyData['email'] ?? '';
  final cSubtitle = companyData['subtitle'] ?? 'SERVICIO TÉCNICO ESPECIALIZADO';

  pw.ImageProvider logo;
  if (customLogo != null) {
    logo = pw.MemoryImage(customLogo);
  } else {
    logo = pw.MemoryImage((await rootBundle.load('assets/marca/marca.png')).buffer.asUint8List());
  }

  final cf = await _fc();
  final n = _f(cf.contentFamily);
  final b = _fb(cf.contentFamily);

  final w2 = (_pw - 6) / 2;
  final w3 = (_pw - 12) / 3;
  final w4 = (_pw - 18) / 4;

  final srvTypes = report.services.map((s) => s.typeName).join(', ');
  final srvDate = '${report.createdAt.day.toString().padLeft(2, '0')}/${report.createdAt.month.toString().padLeft(2, '0')}/${report.createdAt.year}';
  final observations = report.services.isNotEmpty ? report.services.first.observations : '';

  /* ---- QR company data ---- */
  final companyQrData = 'EMPRESA: $cName\nDIRECCIÓN: $cAddress\nTEL: $cPhone\nEMAIL: $cEmail';

  /* ---- QR report data ---- */
  final reportQrData =
    'REPORTE N°: ${report.id}\n'
    'CLIENTE: ${report.client.name}\n'
    'EMAIL: ${report.client.email}\n'
    'TEL: ${report.client.phone}\n'
    'FECHA: $srvDate\n'
    'EQUIPO: ${report.equipment.brand} ${report.equipment.model}\n'
    'TÉCNICO: ${report.employeeName}';

  /* ---- header ---- */
  final header = pw.Container(
    height: 52,
    decoration: pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: _blue, width: 1.2))),
    child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.center, children: [
      pw.Expanded(child: pw.Center(child: pw.Column(mainAxisAlignment: pw.MainAxisAlignment.center, children: [
        pw.Text(cName.toUpperCase(), style: pw.TextStyle(fontSize: 10, font: _fb('Helvetica'), letterSpacing: 3, color: _blue)),
        pw.Text(cSubtitle, style: pw.TextStyle(fontSize: 5, color: PdfColors.grey500, letterSpacing: 2)),
        pw.SizedBox(height: 2),
        pw.Text(srvDate, style: const pw.TextStyle(fontSize: 5.5, color: PdfColors.grey600)),
      ]))),
      pw.SizedBox(width: 8),
      pw.Container(width: 98, height: 48, child: pw.Image(logo, fit: pw.BoxFit.contain)),
      pw.SizedBox(width: 4),
      pw.Container(
        width: 28, height: 28,
        child: pw.BarcodeWidget(
          barcode: pw.Barcode.qrCode(),
          data: companyQrData,
          width: 28, height: 28,
        ),
      ),
    ]),
  );

  /* ---- company data ---- */
  final company = pw.Container(
    width: _pw, padding: const pw.EdgeInsets.fromLTRB(4, 2, 4, 2),
    decoration: pw.BoxDecoration(border: pw.Border.all(color: _blue, width: 0.6)),
    child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Row(children: [
        pw.Text(cName, style: pw.TextStyle(fontSize: 6.5, font: b, color: _blue)),
        if (cPhone.isNotEmpty) ...[pw.SizedBox(width: 10), pw.Text('Tel: $cPhone', style: pw.TextStyle(fontSize: 6, font: n, color: PdfColors.grey700))],
        if (cEmail.isNotEmpty) ...[pw.SizedBox(width: 10), pw.Text(cEmail, style: pw.TextStyle(fontSize: 6, font: n, color: PdfColors.grey700))],
      ]),
      if (cAddress.isNotEmpty) pw.Text('Dirección: $cAddress', style: pw.TextStyle(fontSize: 6, font: n, color: PdfColors.grey600)),
    ]),
  );

  /* ---- 1. CLIENTE ---- */
  final s1 = _sec('1.  DATOS DEL CLIENTE',
    pw.Container(
      height: 72, width: _pw, padding: const pw.EdgeInsets.fromLTRB(4, 2, 4, 0),
      decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey400, width: _ln)),
      child: pw.Column(children: [
        pw.Row(children: [
          _ff('CLIENTE', report.client.name, w: w2, h: 12), pw.SizedBox(width: 6),
          _ff('TELÉFONO', report.client.phone, w: w2, h: 12),
        ]),
        pw.SizedBox(height: 1),
        pw.Row(children: [
          _ff('DIRECCIÓN', report.client.address, w: w2, h: 12), pw.SizedBox(width: 6),
          _ff('EMAIL / CONTACTO', report.client.email, w: w2, h: 12),
        ]),
        pw.SizedBox(height: 1),
        pw.Row(children: [
          _ff('TÉCNICO', report.employeeName, w: w2, h: 12), pw.SizedBox(width: 6),
          _ff('CARGO', report.employeePosition, w: w2, h: 12),
        ]),
        pw.SizedBox(height: 1),
        _ff('LUGAR DE SERVICIO', report.serviceLocation.isNotEmpty ? report.serviceLocation : cAddress, w: _pw - 8, h: 12),
      ]),
    ), fo: b,
  );

  /* ---- 2. EQUIPO ---- */
  final s2 = _sec('2.  EQUIPO',
    pw.Container(
      height: 24, width: _pw, padding: const pw.EdgeInsets.fromLTRB(4, 2, 4, 0),
      decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey400, width: _ln)),
      child: pw.Row(children: [
        _ff('MARCA', report.equipment.brand, w: w3, h: 9), pw.SizedBox(width: 6),
        _ff('MODELO', report.equipment.model, w: w3, h: 9), pw.SizedBox(width: 6),
        _ff('N° SERIE', report.equipment.serialNumber, w: w3, h: 9),
      ]),
    ), fo: b,
  );

  /* ---- 3. SERVICIO ---- */
  final s3 = _sec('3.  SERVICIO',
    pw.Container(
      width: _pw, padding: const pw.EdgeInsets.fromLTRB(4, 2, 4, 0),
      decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey400, width: _ln)),
      child: pw.Column(children: [
        pw.Row(children: [
          _ff('TIPO DE SERVICIO', srvTypes, w: w2, h: 9), pw.SizedBox(width: 6),
          _ff('FECHA', srvDate, w: w2, h: 9),
        ]),
        pw.SizedBox(height: 1),
        pw.Row(children: [
          _ff('HORA ENTRADA', report.entryTime, w: w2, h: 9), pw.SizedBox(width: 6),
          _ff('HORA SALIDA', report.exitTime, w: w2, h: 9),
        ]),
        pw.SizedBox(height: 3),
        pw.Container(
          width: _pw - 8, height: 8, color: PdfColors.grey100,
          padding: const pw.EdgeInsets.only(left: 2),
          child: pw.Text('PARTE/S AFECTADA/S', style: pw.TextStyle(fontSize: 5.5, font: b, color: _blue, letterSpacing: 1)),
        ),
        pw.SizedBox(height: 2),
        pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Text(' TUBE RX [   ]', style: pw.TextStyle(fontSize: 5.5, font: n)),
          pw.SizedBox(width: 4),
          pw.Text('Disparos:', style: pw.TextStyle(fontSize: 5, color: PdfColors.grey600, font: n)),
          pw.SizedBox(width: 1),
          pw.Container(width: 28, decoration: pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey400, width: _ln)))),
          pw.SizedBox(width: 4),
          pw.Text('Hs uso:', style: pw.TextStyle(fontSize: 5, color: PdfColors.grey600, font: n)),
          pw.SizedBox(width: 1),
          pw.Container(width: 28, decoration: pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey400, width: _ln)))),
          pw.SizedBox(width: 4),
          pw.Text('Pacientes:', style: pw.TextStyle(fontSize: 5, color: PdfColors.grey600, font: n)),
          pw.SizedBox(width: 1),
          pw.Container(width: 28, decoration: pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey400, width: _ln)))),
        ]),
        pw.SizedBox(height: 2),
        pw.Row(children: [
          pw.Text(' HV TANK [   ]', style: pw.TextStyle(fontSize: 5.5, font: n)),
          pw.Text(' Cant:', style: pw.TextStyle(fontSize: 5, color: PdfColors.grey600, font: n)),
          pw.Container(width: 24, decoration: pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey400, width: _ln)))),
          pw.SizedBox(width: 10),
          pw.Text('DAS [   ]', style: pw.TextStyle(fontSize: 5.5, font: n)),
          pw.SizedBox(width: 10),
          pw.Text('GANTRY [   ]', style: pw.TextStyle(fontSize: 5.5, font: n)),
        ]),
        pw.SizedBox(height: 2),
        pw.Row(children: [
          pw.Text(' PWR SUPPLY [   ]', style: pw.TextStyle(fontSize: 5.5, font: n)),
          pw.SizedBox(width: 8),
          pw.Text('COLIMADOR [   ]', style: pw.TextStyle(fontSize: 5.5, font: n)),
          pw.SizedBox(width: 8),
          pw.Text('IPG [   ]', style: pw.TextStyle(fontSize: 5.5, font: n)),
        ]),
        pw.SizedBox(height: 1),
      ]),
    ), fo: b,
  );

  /* ---- 4. PROBLEMA REPORTADO ---- */
  final s4 = _sec('4.  PROBLEMA REPORTADO',
    pw.Container(
      height: 80, width: _pw, padding: const pw.EdgeInsets.fromLTRB(4, 2, 4, 0),
      decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey400, width: _ln)),
      child: _fld(w: _pw, h: 74, text: report.problemDescription),
    ), fo: b,
  );

  /* ---- 5. ITEMS ---- */
  final s5 = _sec('5.  ITEMS / REPUESTOS',
    pw.Container(
      width: _pw,
      decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey400, width: _ln)),
      child: pw.Column(children: [
        pw.Row(children: [
          pw.Container(width: _pw * 0.06, color: _blue, padding: const pw.EdgeInsets.symmetric(vertical: 1.5), child: pw.Text('#', style: pw.TextStyle(fontSize: 5, color: PdfColors.white, font: b), textAlign: pw.TextAlign.center)),
          pw.Container(width: _pw * 0.36, color: _blue, padding: const pw.EdgeInsets.symmetric(vertical: 1.5), child: pw.Text('DESCRIPCIÓN', style: pw.TextStyle(fontSize: 5, color: PdfColors.white, font: b), textAlign: pw.TextAlign.center)),
          pw.Container(width: _pw * 0.24, color: _blue, padding: const pw.EdgeInsets.symmetric(vertical: 1.5), child: pw.Text('MODELO / REF.', style: pw.TextStyle(fontSize: 5, color: PdfColors.white, font: b), textAlign: pw.TextAlign.center)),
          pw.Container(width: _pw * 0.1, color: _blue, padding: const pw.EdgeInsets.symmetric(vertical: 1.5), child: pw.Text('CANT.', style: pw.TextStyle(fontSize: 5, color: PdfColors.white, font: b), textAlign: pw.TextAlign.center)),
          pw.Container(width: _pw * 0.12, color: _blue, padding: const pw.EdgeInsets.symmetric(vertical: 1.5), child: pw.Text('PRECIO \$', style: pw.TextStyle(fontSize: 5, color: PdfColors.white, font: b), textAlign: pw.TextAlign.center)),
          pw.Container(width: _pw * 0.12, color: _blue, padding: const pw.EdgeInsets.symmetric(vertical: 1.5), child: pw.Text('TOTAL \$', style: pw.TextStyle(fontSize: 5, color: PdfColors.white, font: b), textAlign: pw.TextAlign.center)),
        ]),
        ...List.generate(8, (i) {
          final it = i < report.items.length ? report.items[i] : null;
          return pw.Container(
            height: 10,
            decoration: i < 7 ? pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: _ln))) : null,
            child: pw.Row(children: [
              pw.Container(width: _pw * 0.06, alignment: pw.Alignment.center, child: pw.Text('${i + 1}', style: pw.TextStyle(fontSize: 5.5, color: PdfColors.grey700, font: n))),
              pw.Container(width: _pw * 0.36, padding: const pw.EdgeInsets.only(left: 2), child: pw.Text(_san(it?.description ?? ''), style: pw.TextStyle(fontSize: 5.5, font: n))),
              pw.Container(width: _pw * 0.24, padding: const pw.EdgeInsets.only(left: 2), child: pw.Text(_san(it?.model ?? ''), style: pw.TextStyle(fontSize: 5.5, font: n))),
              pw.Container(width: _pw * 0.1, alignment: pw.Alignment.center, child: pw.Text(it != null ? '${it.quantity}' : '', style: pw.TextStyle(fontSize: 5.5, font: n))),
              pw.Container(width: _pw * 0.12, alignment: pw.Alignment.centerRight, padding: const pw.EdgeInsets.only(right: 2), child: pw.Text(it != null && it.price > 0 ? '\$${it.price.toStringAsFixed(2)}' : '', style: pw.TextStyle(fontSize: 5.5, font: n))),
              pw.Container(width: _pw * 0.12, alignment: pw.Alignment.centerRight, padding: const pw.EdgeInsets.only(right: 2), child: pw.Text(it != null && it.total > 0 ? '\$${it.total.toStringAsFixed(2)}' : '', style: pw.TextStyle(fontSize: 5.5, font: n))),
            ]),
          );
        }),
      ]),
    ), fo: b,
  );

  /* ---- 6. PRESUPUESTO ---- */
  final s6 = _sec('6.  PRESUPUESTO',
    pw.Container(
      height: 22, width: _pw, padding: const pw.EdgeInsets.fromLTRB(4, 2, 4, 0),
      decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey400, width: _ln)),
      child: pw.Row(children: [
        _ff('N° PRESUPUESTO', report.budgetNumber, w: w4, h: 9), pw.SizedBox(width: 6),
        _ff('COSTO \$', report.serviceCost > 0 ? '\$${report.serviceCost.toStringAsFixed(2)}' : '', w: w4, h: 9), pw.SizedBox(width: 6),
        _ff('GASTOS \$', report.expenses > 0 ? '\$${report.expenses.toStringAsFixed(2)}' : '', w: w4, h: 9), pw.SizedBox(width: 6),
        _ff('TOTAL \$', report.totalCost > 0 ? '\$${report.totalCost.toStringAsFixed(2)}' : '', w: w4, h: 9),
      ]),
    ), fo: b,
  );

  /* ---- bottom QR ---- */
  final bottomQr = pw.Container(
    width: _pw, height: 44,
    margin: const pw.EdgeInsets.only(top: 4),
    decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey400, width: _ln)),
    child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.center, children: [
      pw.Container(
        width: 42, height: 42, margin: const pw.EdgeInsets.only(left: 4),
        child: pw.BarcodeWidget(
          barcode: pw.Barcode.qrCode(),
          data: reportQrData,
          width: 42, height: 42,
        ),
      ),
      pw.SizedBox(width: 6),
      pw.Expanded(
        child: pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('ESCANEAR PARA CONSULTA RÁPIDA', style: pw.TextStyle(fontSize: 5.5, font: b, color: _blue, letterSpacing: 1.2)),
            pw.SizedBox(height: 1),
            pw.Text('Reporte: ${report.id}', style: pw.TextStyle(fontSize: 5, font: n, color: PdfColors.grey600)),
            pw.Text('Cliente: ${report.client.name} — ${srvDate}', style: pw.TextStyle(fontSize: 5, font: n, color: PdfColors.grey600)),
          ],
        ),
      ),
    ]),
  );

  /* ---- 8. FIRMAS ---- */
  final s8 = pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      _bar('8.  FIRMAS / CONFORMIDAD', fo: b),
      pw.SizedBox(height: 1.5),
      pw.Container(
        height: 82, width: _pw, padding: const pw.EdgeInsets.fromLTRB(4, 2, 4, 0),
        decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey400, width: _ln)),
        child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            _lbl('FIRMA DEL TÉCNICO', w: w2, fo: b),
            _fld(w: w2, h: 58),
            pw.SizedBox(height: 2),
            pw.Text(report.employeeName.isNotEmpty ? report.employeeName : '_________________________', style: pw.TextStyle(fontSize: 6, font: b, color: PdfColors.grey800)),
          ]),
          pw.SizedBox(width: 6),
          pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            _lbl('FIRMA DEL CLIENTE', w: w2, fo: b),
            pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                _fld(w: w2 - 60, h: 58),
                pw.SizedBox(height: 2),
                pw.Text(report.client.name.isNotEmpty ? report.client.name : '_________________________', style: pw.TextStyle(fontSize: 6, font: b, color: PdfColors.grey800)),
              ]),
              if (stamp != null) pw.Container(width: 55, height: 78, margin: const pw.EdgeInsets.only(left: 5), child: pw.Image(pw.MemoryImage(stamp), fit: pw.BoxFit.contain)),
            ]),
          ]),
        ]),
      ),
    ],
  );

  /* ---- 7. OBSERVACIONES ---- */
  final s7 = pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      _bar('7.  OBSERVACIONES / DIAGNÓSTICO', fo: b),
      pw.SizedBox(height: 1.5),
      pw.Expanded(
        child: pw.Container(
          width: _pw,
          decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey400, width: _ln)),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Container(
                  width: _pw,
                  padding: const pw.EdgeInsets.only(left: 3, top: 1),
                  child: pw.Text(_san(observations), style: pw.TextStyle(fontSize: 6, font: n)),
                ),
              ),
              pw.Container(
                width: _pw,
                padding: const pw.EdgeInsets.fromLTRB(3, 1, 3, 2),
                decoration: pw.BoxDecoration(border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300, width: _ln))),
                child: pw.Row(children: [
                  pw.Text('Técnicos visitantes:  ', style: pw.TextStyle(fontSize: 6, font: b, color: PdfColors.grey700)),
                  pw.Text(report.visitedTechnicians.isNotEmpty ? report.visitedTechnicians.join(', ') : '_________________________', style: pw.TextStyle(fontSize: 6, font: n)),
                ]),
              ),
            ],
          ),
        ),
      ),
      pw.SizedBox(height: _gap),
    ],
  );

  pw.Widget buildContent() => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      header,
      pw.SizedBox(height: 2),
      company,
      pw.SizedBox(height: _gap),
      s1, s2, s3, s4, s5, s6,
      pw.Expanded(child: s7),
      s8, bottomQr,
    ],
  );

  pw.Widget pageContent() {
    if (!wmEnabled || watermarkBytes.isEmpty) return buildContent();
    return pw.Stack(
      children: [
        pw.Positioned.fill(
          child: pw.Center(
            child: pw.Opacity(
              opacity: wmOpacity,
              child: pw.Image(pw.MemoryImage(watermarkBytes), fit: pw.BoxFit.cover),
            ),
          ),
        ),
        buildContent(),
      ],
    );
  }

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(_mg),
      build: (_) => pageContent(),
    ),
  );

  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/informe_${report.client.name.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf');
  await file.writeAsBytes(await pdf.save(), flush: true);
  return file;
}
