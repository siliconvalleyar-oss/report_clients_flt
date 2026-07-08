import 'package:flutter/material.dart';
import '../../models/report_model.dart';
import '../../utils/constants.dart';

class ExportButtons extends StatelessWidget {
  final ReportModel report;

  const ExportButtons({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _button(
          icon: Icons.share,
          label: 'Compartir por WhatsApp',
          color: const Color(0xFF25D366),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Compartiendo por WhatsApp...')),
            );
          },
        ),
        const SizedBox(height: 12),
        _button(
          icon: Icons.email,
          label: 'Enviar por Email',
          color: const Color(0xFFEA4335),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Enviando por email...')),
            );
          },
        ),
        const SizedBox(height: 12),
        _button(
          icon: Icons.cloud_upload,
          label: 'Guardar en Google Drive',
          color: const Color(0xFF4285F4),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Guardando en Drive...')),
            );
          },
        ),
        const SizedBox(height: 12),
        _button(
          icon: Icons.picture_as_pdf,
          label: 'Exportar PDF',
          color: const Color(0xFFD32F2F),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Exportando PDF...')),
            );
          },
        ),
        const SizedBox(height: 12),
        _button(
          icon: Icons.print,
          label: 'Imprimir',
          color: Colors.blueGrey,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Enviando a impresora...')),
            );
          },
        ),
      ],
    );
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
