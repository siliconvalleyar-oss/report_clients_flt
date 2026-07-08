import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/report_controller.dart';
import '../../utils/constants.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Image.asset('assets/logo.png', height: 80, errorBuilder: (_, __, ___) => const Icon(Icons.medical_services, size: 80, color: AppConstants.primaryColor)),
            const SizedBox(height: 16),
            const Text('Reportes Técnicos', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _MenuButton(icon: Icons.description, label: 'Nuevo Reporte', color: AppConstants.primaryColor, onTap: () => Navigator.pushNamed(context, '/report')),
                  _MenuButton(icon: Icons.history, label: 'Historial', color: Colors.teal, onTap: () => Navigator.pushNamed(context, '/history')),
                  _MenuButton(icon: Icons.folder_copy, label: 'Plantillas', color: Colors.blueGrey, onTap: () {}),
                  _MenuButton(icon: Icons.settings, label: 'Configuración', color: Colors.orange, onTap: () => Navigator.pushNamed(context, '/settings')),
                  _MenuButton(icon: Icons.dark_mode, label: 'Modo Oscuro', color: Colors.indigo, onTap: () {}),
                  _MenuButton(icon: Icons.info, label: 'Acerca de', color: Colors.purple, onTap: () => _showAbout(context)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: AppConstants.version,
      children: [
        const Text('Aplicación para generación de reportes técnicos de electromedicina.'),
      ],
    );
  }
}

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MenuButton({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withAlpha(50)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 8),
              Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}
