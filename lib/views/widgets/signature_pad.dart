import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class SignaturePad extends StatefulWidget {
  final ValueChanged<Uint8List?> onSaved;

  const SignaturePad({super.key, required this.onSaved});

  @override
  State<SignaturePad> createState() => _SignaturePadState();
}

class _SignaturePadState extends State<SignaturePad> {
  final List<Offset?> _points = [];
  Uint8List? _signatureBytes;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          width: double.infinity,
          height: 150,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: GestureDetector(
              onPanStart: (details) {
                setState(() => _points.add(details.localPosition));
              },
              onPanUpdate: (details) {
                setState(() => _points.add(details.localPosition));
              },
              onPanEnd: (_) {
                setState(() => _points.add(null));
                _captureSignature();
              },
              child: CustomPaint(
                painter: _SignaturePainter(_points),
                size: const Size(double.infinity, 150),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton.icon(
              onPressed: _clear,
              icon: const Icon(Icons.clear),
              label: const Text('Limpiar'),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: _accept,
              icon: const Icon(Icons.check),
              label: const Text('Aceptar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _clear() {
    setState(() {
      _points.clear();
      _signatureBytes = null;
    });
    widget.onSaved(null);
  }

  void _accept() {
    if (_signatureBytes != null) {
      widget.onSaved(_signatureBytes);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Firma guardada')),
      );
    }
  }

  Future<void> _captureSignature() async {
    if (_points.isEmpty) return;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const size = Size(400, 150);
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Colors.white);
    _SignaturePainter(_points).paint(canvas, size);
    final picture = recorder.endRecording();
    final img = await picture.toImage(size.width.toInt(), size.height.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    _signatureBytes = byteData?.buffer.asUint8List();
  }
}

class _SignaturePainter extends CustomPainter {
  final List<Offset?> points;

  _SignaturePainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
