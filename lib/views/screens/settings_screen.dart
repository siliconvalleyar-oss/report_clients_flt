import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _companyNameController = TextEditingController(text: 'Electromedicina Pro');
  final _companyAddressController = TextEditingController();
  final _companyPhoneController = TextEditingController();
  final _companyEmailController = TextEditingController();
  String _selectedLanguage = 'es';

  @override
  void dispose() {
    _companyNameController.dispose();
    _companyAddressController.dispose();
    _companyPhoneController.dispose();
    _companyEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Datos de la Empresa', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(
            controller: _companyNameController,
            decoration: const InputDecoration(labelText: 'Nombre de la empresa', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _companyAddressController,
            decoration: const InputDecoration(labelText: 'Dirección', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _companyPhoneController,
            decoration: const InputDecoration(labelText: 'Teléfono', border: OutlineInputBorder()),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _companyEmailController,
            decoration: const InputDecoration(labelText: 'Correo electrónico', border: OutlineInputBorder()),
            keyboardType: TextInputType.emailAddress,
          ),

          const SizedBox(height: 32),
          const Text('Idioma', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedLanguage,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: const [
              DropdownMenuItem(value: 'es', child: Text('Español')),
              DropdownMenuItem(value: 'en', child: Text('English')),
            ],
            onChanged: (v) => setState(() => _selectedLanguage = v ?? 'es'),
          ),

          const SizedBox(height: 32),
          const Text('Respaldo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.backup, color: AppConstants.primaryColor),
            title: const Text('Respaldar datos'),
            subtitle: const Text('Exportar todos los reportes'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Respaldo iniciado')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.restore, color: AppConstants.primaryColor),
            title: const Text('Restaurar datos'),
            subtitle: const Text('Importar reportes desde respaldo'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Restauración iniciada')),
              );
            },
          ),

          const SizedBox(height: 32),
          const Text('Acerca de', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppConstants.appName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Versión: ${AppConstants.version}'),
                  const SizedBox(height: 4),
                  const Text('Aplicación para generación de reportes técnicos de electromedicina.'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
