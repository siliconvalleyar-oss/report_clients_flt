import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../controllers/theme_controller.dart';
import '../../models/client_model.dart';
import '../../services/storage_service.dart';
import '../../utils/constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _companyNameController = TextEditingController();
  final _companyAddressController = TextEditingController();
  final _companyPhoneController = TextEditingController();
  final _companyEmailController = TextEditingController();
  final _companySubtitleController = TextEditingController();
  String _selectedLanguage = 'es';
  Uint8List? _stampBytes;
  Uint8List? _logoBytes;
  List<String> _customBrands = [];
  Map<String, List<String>> _customModels = {};
  late FontConfig _fontConfig;
  bool _watermarkEnabled = true;
  double _watermarkOpacity = 0.4;
  List<String> _employees = [];
  List<String> _positions = [];
  List<ClientModel> _clientAgenda = [];

  @override
  void initState() {
    super.initState();
    _fontConfig = const FontConfig();
    _loadCompanyData();
    _loadStamp();
    _loadLogo();
    _loadCustomBrands();
    _loadFontConfig();
    _loadWatermarkSettings();
    _loadEmployees();
    _loadPositions();
    _loadClientAgenda();
  }

  Future<void> _loadCompanyData() async {
    final data = await StorageService.loadCompanyData();
    _companyNameController.text = data['name'] ?? '';
    _companyAddressController.text = data['address'] ?? '';
    _companyPhoneController.text = data['phone'] ?? '';
    _companyEmailController.text = data['email'] ?? '';
    _companySubtitleController.text = data['subtitle'] ?? 'SERVICIO TÉCNICO ESPECIALIZADO';
  }

  Future<void> _saveCompanyData() async {
    await StorageService.saveCompanyData(
      name: _companyNameController.text.trim(),
      address: _companyAddressController.text.trim(),
      phone: _companyPhoneController.text.trim(),
      email: _companyEmailController.text.trim(),
    );
    await StorageService.saveCompanySubtitle(_companySubtitleController.text.trim());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Datos de empresa guardados')),
      );
    }
  }

  Future<void> _loadStamp() async {
    final bytes = await StorageService.getStampImage();
    if (mounted) setState(() => _stampBytes = bytes);
  }

  Future<void> _loadLogo() async {
    final bytes = await StorageService.getLogoImage();
    if (mounted) setState(() => _logoBytes = bytes);
  }

  Future<void> _pickLogo() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: ImageSource.gallery, maxWidth: 400, maxHeight: 400);
    if (xFile == null) return;
    final bytes = await xFile.readAsBytes();
    await StorageService.saveLogoImage(bytes);
    if (mounted) {
      setState(() => _logoBytes = bytes);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logo guardado correctamente')),
      );
    }
  }

  Future<void> _removeLogo() async {
    await StorageService.clearLogoImage();
    if (mounted) {
      setState(() => _logoBytes = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logo eliminado')),
      );
    }
  }

  Future<void> _loadCustomBrands() async {
    final brands = await StorageService.getCustomBrands();
    final Map<String, List<String>> models = {};
    for (final b in brands) {
      models[b] = await StorageService.getCustomModels(b);
    }
    if (mounted) setState(() {
      _customBrands = brands;
      _customModels = models;
    });
  }

  Future<void> _loadFontConfig() async {
    final config = await StorageService.getFontConfig();
    if (mounted) setState(() => _fontConfig = config);
  }

  Future<void> _loadWatermarkSettings() async {
    final settings = await StorageService.loadWatermarkSettings();
    if (mounted) setState(() {
      _watermarkEnabled = settings['enabled'] as bool;
      _watermarkOpacity = (settings['opacity'] as num).toDouble();
    });
  }

  Future<void> _saveWatermarkSettings() async {
    await StorageService.saveWatermarkSettings(enabled: _watermarkEnabled, opacity: _watermarkOpacity);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Configuración de fondo guardada')),
      );
    }
  }

  Future<void> _loadEmployees() async {
    final list = await StorageService.getEmployees();
    if (mounted) setState(() => _employees = list);
  }

  Future<void> _loadPositions() async {
    final list = await StorageService.getPositions();
    if (mounted) setState(() => _positions = list);
  }

  Future<void> _loadClientAgenda() async {
    final list = await StorageService.getClientAgenda();
    if (mounted) setState(() => _clientAgenda = list);
  }

  Future<void> _addEmployee() async {
    final c = TextEditingController();
    final v = await showDialog<String>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Nuevo empleado'),
      content: TextField(controller: c, autofocus: true, decoration: const InputDecoration(labelText: 'Nombre', border: OutlineInputBorder())),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
        FilledButton(onPressed: () { final t = c.text.trim(); if (t.isNotEmpty) Navigator.pop(ctx, t); }, child: const Text('Guardar')),
      ],
    ));
    if (v != null && v.isNotEmpty) { await StorageService.addEmployee(v); await _loadEmployees(); }
  }

  Future<void> _removeEmployee(String name) async {
    await StorageService.removeEmployee(name);
    await _loadEmployees();
  }

  Future<void> _addPosition() async {
    final c = TextEditingController();
    final v = await showDialog<String>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Nuevo cargo'),
      content: TextField(controller: c, autofocus: true, decoration: const InputDecoration(labelText: 'Cargo', border: OutlineInputBorder())),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
        FilledButton(onPressed: () { final t = c.text.trim(); if (t.isNotEmpty) Navigator.pop(ctx, t); }, child: const Text('Guardar')),
      ],
    ));
    if (v != null && v.isNotEmpty) { await StorageService.addPosition(v); await _loadPositions(); }
  }

  Future<void> _removePosition(String name) async {
    await StorageService.removePosition(name);
    await _loadPositions();
  }

  Future<void> _addClientToAgenda() async {
    final nameC = TextEditingController();
    final addrC = TextEditingController();
    final phoneC = TextEditingController();
    final emailC = TextEditingController();
    final result = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Agregar cliente'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: nameC, decoration: const InputDecoration(labelText: 'Nombre', border: OutlineInputBorder())),
        const SizedBox(height: 8),
        TextField(controller: addrC, decoration: const InputDecoration(labelText: 'Dirección', border: OutlineInputBorder())),
        const SizedBox(height: 8),
        TextField(controller: phoneC, decoration: const InputDecoration(labelText: 'Teléfono', border: OutlineInputBorder())),
        const SizedBox(height: 8),
        TextField(controller: emailC, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Guardar')),
      ],
    ));
    if (result == true && nameC.text.trim().isNotEmpty) {
      await StorageService.addClientToAgenda(ClientModel(
        name: nameC.text.trim(),
        address: addrC.text.trim(),
        phone: phoneC.text.trim(),
        email: emailC.text.trim(),
      ));
      await _loadClientAgenda();
    }
  }

  Future<void> _removeClientFromAgenda(String name) async {
    await StorageService.removeClientFromAgenda(name);
    await _loadClientAgenda();
  }

  Future<void> _saveFontConfig() async {
    await StorageService.saveFontConfig(_fontConfig);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Configuración de tipografía guardada')),
      );
    }
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _companyAddressController.dispose();
    _companyPhoneController.dispose();
    _companyEmailController.dispose();
    _companySubtitleController.dispose();
    super.dispose();
  }

  Future<void> _pickStamp() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: ImageSource.gallery, maxWidth: 600, maxHeight: 600);
    if (xFile == null) return;
    final bytes = await xFile.readAsBytes();
    await StorageService.saveStampImage(bytes);
    if (mounted) {
      setState(() => _stampBytes = bytes);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sello guardado correctamente')),
      );
    }
  }

  Future<void> _removeStamp() async {
    await StorageService.clearStampImage();
    if (mounted) {
      setState(() => _stampBytes = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sello eliminado')),
      );
    }
  }

  Future<void> _addCustomBrand() async {
    final controller = TextEditingController();
    final brand = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nueva marca'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Nombre de la marca', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              final v = controller.text.trim();
              if (v.isNotEmpty) Navigator.pop(ctx, v);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (brand != null && brand.isNotEmpty) {
      await StorageService.addCustomBrand(brand);
      await _loadCustomBrands();
    }
  }

  Future<void> _deleteCustomBrand(String brand) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar marca'),
        content: Text('¿Eliminar "$brand" y todos sus modelos?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final brands = await StorageService.getCustomBrands();
      brands.remove(brand);
      await StorageService.saveCustomBrands(brands);
      await StorageService.saveCustomModels(brand, []);
      await _loadCustomBrands();
    }
  }

  Future<void> _addCustomModel(String brand) async {
    final controller = TextEditingController();
    final model = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Nuevo modelo para $brand'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Nombre del modelo', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              final v = controller.text.trim();
              if (v.isNotEmpty) Navigator.pop(ctx, v);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (model != null && model.isNotEmpty) {
      await StorageService.addCustomModel(brand, model);
      await _loadCustomBrands();
    }
  }

  Future<void> _deleteCustomModel(String brand, String model) async {
    final models = await StorageService.getCustomModels(brand);
    models.remove(model);
    await StorageService.saveCustomModels(brand, models);
    await _loadCustomBrands();
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
          _sectionTitle('Datos de la Empresa'),
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
          const SizedBox(height: 12),
          TextField(
            controller: _companySubtitleController,
            decoration: const InputDecoration(labelText: 'Subtítulo del reporte', border: OutlineInputBorder(),
              hintText: 'SERVICIO TÉCNICO ESPECIALIZADO'),
          ),

          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _saveCompanyData,
              icon: const Icon(Icons.save),
              label: const Text('Guardar datos de empresa'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 32),
          _sectionTitle('Logo de la Empresa'),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (_logoBytes != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(_logoBytes!, height: 80, fit: BoxFit.contain),
                    ),
                    const SizedBox(height: 12),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickLogo,
                          icon: const Icon(Icons.image),
                          label: Text(_logoBytes != null ? 'Cambiar logo' : 'Cargar logo'),
                        ),
                      ),
                      if (_logoBytes != null) ...[
                        const SizedBox(width: 12),
                        IconButton(
                          onPressed: _removeLogo,
                          icon: const Icon(Icons.delete, color: Colors.red),
                          tooltip: 'Eliminar logo',
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('El logo se mostrará en el encabezado del PDF', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),
          _sectionTitle('Sello de la Empresa'),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (_stampBytes != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(_stampBytes!, height: 100, fit: BoxFit.contain),
                    ),
                    const SizedBox(height: 12),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickStamp,
                          icon: const Icon(Icons.image),
                          label: Text(_stampBytes != null ? 'Cambiar sello' : 'Cargar sello'),
                        ),
                      ),
                      if (_stampBytes != null) ...[
                        const SizedBox(width: 12),
                        IconButton(
                          onPressed: _removeStamp,
                          icon: const Icon(Icons.delete, color: Colors.red),
                          tooltip: 'Eliminar sello',
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('El sello se mostrará al final del PDF', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),
          _sectionTitle('Fondo del Reporte PDF'),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.image, color: AppConstants.primaryColor),
                      const SizedBox(width: 12),
                      const Expanded(child: Text('Mostrar imagen de fondo', style: TextStyle(fontSize: 16))),
                      Switch(
                        value: _watermarkEnabled,
                        onChanged: (v) => setState(() => _watermarkEnabled = v),
                        activeColor: AppConstants.primaryColor,
                      ),
                    ],
                  ),
                  if (_watermarkEnabled) ...[
                    const SizedBox(height: 16),
                    const Text('Opacidad', style: TextStyle(fontSize: 14)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Text('0%', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        Expanded(
                          child: Slider(
                            value: _watermarkOpacity,
                            min: 0.0,
                            max: 1.0,
                            divisions: 100,
                            activeColor: AppConstants.primaryColor,
                            onChanged: (v) => setState(() => _watermarkOpacity = v),
                          ),
                        ),
                        const Text('100%', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                    Center(child: Text('${(_watermarkOpacity * 100).round()}%', style: const TextStyle(fontSize: 12, color: Colors.grey))),
                    const SizedBox(height: 8),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _saveWatermarkSettings,
                      icon: const Icon(Icons.save),
                      label: const Text('Guardar configuración de fondo'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),
          _sectionTitle('Tipografía del Reporte PDF'),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _fontRow(
                    'Títulos de sección',
                    _fontConfig.titleFamily,
                    _fontConfig.titleSize,
                    (f) => _fontConfig = FontConfig(
                      titleFamily: f,
                      labelFamily: _fontConfig.labelFamily,
                      contentFamily: _fontConfig.contentFamily,
                      titleSize: _fontConfig.titleSize,
                      labelSize: _fontConfig.labelSize,
                      contentSize: _fontConfig.contentSize,
                    ),
                    (s) => _fontConfig = FontConfig(
                      titleFamily: _fontConfig.titleFamily,
                      labelFamily: _fontConfig.labelFamily,
                      contentFamily: _fontConfig.contentFamily,
                      titleSize: s,
                      labelSize: _fontConfig.labelSize,
                      contentSize: _fontConfig.contentSize,
                    ),
                  ),
                  const Divider(height: 24),
                  _fontRow(
                    'Etiquetas de datos',
                    _fontConfig.labelFamily,
                    _fontConfig.labelSize,
                    (f) => _fontConfig = FontConfig(
                      titleFamily: _fontConfig.titleFamily,
                      labelFamily: f,
                      contentFamily: _fontConfig.contentFamily,
                      titleSize: _fontConfig.titleSize,
                      labelSize: _fontConfig.labelSize,
                      contentSize: _fontConfig.contentSize,
                    ),
                    (s) => _fontConfig = FontConfig(
                      titleFamily: _fontConfig.titleFamily,
                      labelFamily: _fontConfig.labelFamily,
                      contentFamily: _fontConfig.contentFamily,
                      titleSize: _fontConfig.titleSize,
                      labelSize: s,
                      contentSize: _fontConfig.contentSize,
                    ),
                  ),
                  const Divider(height: 24),
                  _fontRow(
                    'Contenido / cuerpo',
                    _fontConfig.contentFamily,
                    _fontConfig.contentSize,
                    (f) => _fontConfig = FontConfig(
                      titleFamily: _fontConfig.titleFamily,
                      labelFamily: _fontConfig.labelFamily,
                      contentFamily: f,
                      titleSize: _fontConfig.titleSize,
                      labelSize: _fontConfig.labelSize,
                      contentSize: _fontConfig.contentSize,
                    ),
                    (s) => _fontConfig = FontConfig(
                      titleFamily: _fontConfig.titleFamily,
                      labelFamily: _fontConfig.labelFamily,
                      contentFamily: _fontConfig.contentFamily,
                      titleSize: _fontConfig.titleSize,
                      labelSize: _fontConfig.labelSize,
                      contentSize: s,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _saveFontConfig,
                      icon: const Icon(Icons.save),
                      label: const Text('Guardar configuración de tipografía'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),
          Row(children: [
            _sectionTitle('Empleados'),
            const Spacer(),
            IconButton(onPressed: _addEmployee, icon: const Icon(Icons.add_circle, color: AppConstants.primaryColor), tooltip: 'Agregar empleado'),
          ]),
          const SizedBox(height: 8),
          const Text('Estos empleados aparecerán en el formulario de reportes.', style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 8),
          if (_employees.isEmpty) const Card(child: Padding(padding: EdgeInsets.all(16), child: Center(child: Text('Sin empleados'))))
          else Wrap(spacing: 6, runSpacing: 4, children: _employees.map((e) => Chip(
            label: Text(e, style: const TextStyle(fontSize: 12)),
            deleteIcon: const Icon(Icons.close, size: 16),
            onDeleted: () => _removeEmployee(e),
          )).toList()),

          const SizedBox(height: 24),
          Row(children: [
            _sectionTitle('Cargos / Posiciones'),
            const Spacer(),
            IconButton(onPressed: _addPosition, icon: const Icon(Icons.add_circle, color: AppConstants.primaryColor), tooltip: 'Agregar cargo'),
          ]),
          const SizedBox(height: 8),
          const Text('Los cargos aparecerán en el formulario de reportes.', style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 8),
          if (_positions.isEmpty) const Card(child: Padding(padding: EdgeInsets.all(16), child: Center(child: Text('Sin cargos'))))
          else Wrap(spacing: 6, runSpacing: 4, children: _positions.map((p) => Chip(
            label: Text(p, style: const TextStyle(fontSize: 12)),
            deleteIcon: const Icon(Icons.close, size: 16),
            onDeleted: () => _removePosition(p),
          )).toList()),

          const SizedBox(height: 24),
          Row(children: [
            _sectionTitle('Agenda de Clientes'),
            const Spacer(),
            IconButton(onPressed: _addClientToAgenda, icon: const Icon(Icons.add_circle, color: AppConstants.primaryColor), tooltip: 'Agregar cliente'),
          ]),
          const SizedBox(height: 8),
          const Text('Los clientes guardados se autocompletarán en el formulario.', style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 8),
          if (_clientAgenda.isEmpty)
            const Card(child: Padding(padding: EdgeInsets.all(16), child: Center(child: Text('Agenda vacía'))))
          else
            ..._clientAgenda.map((c) => Card(margin: const EdgeInsets.only(bottom: 6), child: ListTile(
              dense: true,
              title: Text(c.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              subtitle: Text([c.address, c.phone, c.email].where((x) => x.isNotEmpty).join(' — '), style: const TextStyle(fontSize: 11)),
              trailing: IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red), onPressed: () => _removeClientFromAgenda(c.name)),
            ))),

          const SizedBox(height: 32),
          Row(
            children: [
              _sectionTitle('Marcas y Modelos Personalizados'),
              const Spacer(),
              IconButton(
                onPressed: _addCustomBrand,
                icon: const Icon(Icons.add_circle, color: AppConstants.primaryColor),
                tooltip: 'Agregar marca',
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Las marcas y modelos agregados aquí estarán disponibles en el formulario de reportes.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          if (_customBrands.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: Text('No hay marcas personalizadas. Toque + para agregar una.')),
              ),
            )
          else
            ..._customBrands.map((brand) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.business, size: 20, color: AppConstants.primaryColor),
                            const SizedBox(width: 8),
                            Expanded(child: Text(brand, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15))),
                            IconButton(
                              onPressed: () => _addCustomModel(brand),
                              icon: const Icon(Icons.add, size: 20),
                              tooltip: 'Agregar modelo',
                            ),
                            IconButton(
                              onPressed: () => _deleteCustomBrand(brand),
                              icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                              tooltip: 'Eliminar marca',
                            ),
                          ],
                        ),
                        if ((_customModels[brand] ?? []).isNotEmpty) ...[
                          const Divider(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: (_customModels[brand] ?? []).map((m) => Chip(
                              label: Text(m, style: const TextStyle(fontSize: 12)),
                              deleteIcon: const Icon(Icons.close, size: 16),
                              onDeleted: () => _deleteCustomModel(brand, m),
                            )).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                )),

          const SizedBox(height: 32),
          _sectionTitle('Apariencia'),
          const SizedBox(height: 12),
          Consumer<ThemeController>(
            builder: (_, tc, __) => Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(tc.themeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode, color: AppConstants.primaryColor),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Modo oscuro', style: TextStyle(fontSize: 16)),
                          Text(tc.themeMode == ThemeMode.dark ? 'Azul oscuro activado' : 'Azul oscuro desactivado',
                            style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                    Switch(
                      value: tc.themeMode == ThemeMode.dark,
                      onChanged: (_) => tc.toggleTheme(),
                      activeColor: AppConstants.primaryColor,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),
          _sectionTitle('Idioma'),
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
          _sectionTitle('Respaldo'),
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
          _sectionTitle('Acerca de'),
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

  Widget _sectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
  }

  Widget _fontRow(
    String label,
    String currentFamily,
    double currentSize,
    void Function(String) onFamilyChanged,
    void Function(double) onSizeChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: DropdownButtonFormField<String>(
                value: FontConfig.availableFamilies.contains(currentFamily) ? currentFamily : FontConfig.availableFamilies.first,
                decoration: const InputDecoration(
                  labelText: 'Familia',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: FontConfig.availableFamilies
                    .map((f) => DropdownMenuItem(value: f, child: Text(f, style: const TextStyle(fontSize: 13))))
                    .toList(),
                onChanged: (v) {
                  if (v != null) {
                    setState(() => onFamilyChanged(v));
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: TextFormField(
                initialValue: currentSize.toStringAsFixed(1),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Tamaño',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onChanged: (v) {
                  final parsed = double.tryParse(v);
                  if (parsed != null && parsed > 0) {
                    setState(() => onSizeChanged(parsed));
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
