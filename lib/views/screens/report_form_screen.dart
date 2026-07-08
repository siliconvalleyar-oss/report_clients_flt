import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/report_controller.dart';
import '../../models/client_model.dart';
import '../../models/equipment_model.dart';
import '../../models/report_model.dart';
import '../../models/service_model.dart';
import '../widgets/equipment_dropdown.dart';
import '../widgets/service_checkbox.dart';
import '../widgets/signature_pad.dart';

class ReportFormScreen extends StatefulWidget {
  const ReportFormScreen({super.key});

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _clientNameController = TextEditingController();
  final _clientAddressController = TextEditingController();
  final _serviceLocationController = TextEditingController();
  final _serialNumberController = TextEditingController();
  final _problemController = TextEditingController();
  final _workDoneController = TextEditingController();
  final _observationsController = TextEditingController();

  String _selectedEmployee = '';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  List<ServiceType> _selectedServices = [];
  String _selectedBrand = '';
  String _selectedModel = '';
  bool _hasSpareParts = false;
  bool _hasWarranty = false;
  Uint8List? _signatureBytes;

  final List<String> _employees = [
    'Carlos Méndez',
    'Ana López',
    'Pedro Ramírez',
    'Laura Gutiérrez',
    'Roberto Sánchez',
  ];

  @override
  void dispose() {
    _clientNameController.dispose();
    _clientAddressController.dispose();
    _serviceLocationController.dispose();
    _serialNumberController.dispose();
    _problemController.dispose();
    _workDoneController.dispose();
    _observationsController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (time != null) setState(() => _selectedTime = time);
  }

  void _onServicesChanged(List<ServiceType> services) {
    setState(() => _selectedServices = services);
  }

  void _onEquipmentChanged(String brand, String model) {
    setState(() {
      _selectedBrand = brand;
      _selectedModel = model;
    });
  }

  void _onSignatureChanged(Uint8List? bytes) {
    setState(() => _signatureBytes = bytes);
  }

  Future<void> _generateReport() async {
    if (!_formKey.currentState!.validate()) return;

    final controller = context.read<ReportController>();
    final report = ReportModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      client: ClientModel(
        name: _clientNameController.text.trim(),
        address: _clientAddressController.text.trim(),
      ),
      serviceLocation: _serviceLocationController.text.trim(),
      employeeName: _selectedEmployee,
      services: _selectedServices.map((type) => ServiceModel(
        type: type,
        date: _selectedDate,
        hasSpareParts: _hasSpareParts,
        hasWarranty: _hasWarranty,
        observations: _observationsController.text.trim(),
        description: _problemController.text.trim(),
      )).toList(),
      equipment: EquipmentModel(
        brand: _selectedBrand,
        model: _selectedModel,
        serialNumber: _serialNumberController.text.trim(),
      ),
      problemDescription: _problemController.text.trim(),
      workDone: _workDoneController.text.trim(),
      clientSignature: _signatureBytes,
      createdAt: DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      ),
    );

    try {
      await controller.saveReport();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/preview');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Reporte'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('Datos del Cliente'),
              TextFormField(
                controller: _clientNameController,
                decoration: const InputDecoration(labelText: 'Nombre del cliente', border: OutlineInputBorder()),
                validator: (v) => v == null || v.trim().isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _clientAddressController,
                decoration: const InputDecoration(labelText: 'Dirección', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _serviceLocationController,
                decoration: const InputDecoration(labelText: 'Lugar de servicio', border: OutlineInputBorder()),
              ),

              const SizedBox(height: 24),
              _sectionTitle('Empleado'),
              DropdownButtonFormField<String>(
                value: _selectedEmployee.isEmpty ? null : _selectedEmployee,
                decoration: const InputDecoration(labelText: 'Seleccionar empleado', border: OutlineInputBorder()),
                items: _employees.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() => _selectedEmployee = v ?? ''),
                validator: (v) => v == null || v.isEmpty ? 'Seleccione un empleado' : null,
              ),

              const SizedBox(height: 24),
              _sectionTitle('Tipo de Servicio'),
              ServiceCheckbox(onChanged: _onServicesChanged),

              const SizedBox(height: 24),
              _sectionTitle('Fecha y Hora'),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickDate,
                      icon: const Icon(Icons.calendar_today),
                      label: Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickTime,
                      icon: const Icon(Icons.access_time),
                      label: Text(_selectedTime.format(context)),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              _sectionTitle('Equipo'),
              EquipmentDropdown(
                onChanged: _onEquipmentChanged,
                serialNumberController: _serialNumberController,
              ),

              const SizedBox(height: 24),
              _sectionTitle('Descripción del Problema'),
              TextFormField(
                controller: _problemController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Describa el problema reportado...',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 24),
              _sectionTitle('Trabajo Realizado'),
              TextFormField(
                controller: _workDoneController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Describa el trabajo realizado...',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Repuestos Utilizados'),
                value: _hasSpareParts,
                onChanged: (v) => setState(() => _hasSpareParts = v ?? false),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              CheckboxListTile(
                title: const Text('Con Garantía'),
                value: _hasWarranty,
                onChanged: (v) => setState(() => _hasWarranty = v ?? false),
                controlAffinity: ListTileControlAffinity.leading,
              ),

              const SizedBox(height: 24),
              _sectionTitle('Observaciones'),
              TextFormField(
                controller: _observationsController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Observaciones adicionales...',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 24),
              _sectionTitle('Firma del Cliente'),
              SignaturePad(onSaved: _onSignatureChanged),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _generateReport,
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Generar Reporte PDF', style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }
}
