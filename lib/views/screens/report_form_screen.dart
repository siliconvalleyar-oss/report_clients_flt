import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/report_controller.dart';
import '../../models/client_model.dart';
import '../../models/equipment_model.dart';
import '../../models/report_item.dart';
import '../../models/report_model.dart';
import '../../models/service_model.dart';
import '../../services/storage_service.dart';
import '../widgets/equipment_dropdown.dart';
import '../widgets/service_checkbox.dart';
import '../widgets/signature_pad.dart';
import '../../utils/constants.dart';

class ReportFormScreen extends StatefulWidget {
  final ReportModel? report;

  const ReportFormScreen({super.key, this.report});

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
  final _budgetNumberController = TextEditingController();
  final _serviceCostController = TextEditingController();
  final _expensesController = TextEditingController();

  String _selectedEmployee = '';
  String _selectedPosition = '';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  TimeOfDay _entryTime = TimeOfDay.now();
  TimeOfDay _exitTime = TimeOfDay.now();
  List<ServiceType> _selectedServices = [];
  String _selectedBrand = '';
  String _selectedModel = '';
  bool _hasSpareParts = false;
  bool _hasWarranty = false;
  Uint8List? _signatureBytes;
  List<ReportItem> _items = [];
  Set<String> _visitedTechnicians = {};

  List<String> _employees = [];
  List<String> _positions = [];
  List<ClientModel> _clientAgenda = [];

  @override
  void initState() {
    super.initState();
    final r = widget.report;
    if (r != null) {
      _clientNameController.text = r.client.name;
      _clientAddressController.text = r.client.address;
      _serviceLocationController.text = r.serviceLocation;
      _serialNumberController.text = r.equipment.serialNumber;
      _problemController.text = r.problemDescription;
      _workDoneController.text = r.workDone;
      _observationsController.text = r.services.isNotEmpty ? r.services.first.observations : '';
      _budgetNumberController.text = r.budgetNumber;
      _serviceCostController.text = r.serviceCost > 0 ? r.serviceCost.toStringAsFixed(2) : '';
      _expensesController.text = r.expenses > 0 ? r.expenses.toStringAsFixed(2) : '';
      _selectedEmployee = r.employeeName;
      _selectedPosition = r.employeePosition;
      _selectedDate = r.createdAt;
      _selectedTime = TimeOfDay(hour: r.createdAt.hour, minute: r.createdAt.minute);
      _selectedServices = r.services.map((s) => s.type).toList();
      _selectedBrand = r.equipment.brand;
      _selectedModel = r.equipment.model;
      _hasSpareParts = r.services.any((s) => s.hasSpareParts);
      _hasWarranty = r.services.any((s) => s.hasWarranty);
      _signatureBytes = r.clientSignature;
      _items = r.items;
      _entryTime = TimeOfDay(
        hour: int.tryParse(r.entryTime.split(':')[0]) ?? 0,
        minute: int.tryParse(r.entryTime.split(':')[1]) ?? 0,
      );
      _exitTime = TimeOfDay(
        hour: int.tryParse(r.exitTime.split(':')[0]) ?? 0,
        minute: int.tryParse(r.exitTime.split(':')[1]) ?? 0,
      );
      _visitedTechnicians = r.visitedTechnicians.toSet();
    }
    _loadLists();
  }

  Future<void> _loadLists() async {
    final emps = await StorageService.getEmployees();
    final pos = await StorageService.getPositions();
    final agenda = await StorageService.getClientAgenda();
    if (mounted) setState(() { _employees = emps; _positions = pos; _clientAgenda = agenda; });
  }

  @override
  void dispose() {
    _clientNameController.dispose();
    _clientAddressController.dispose();
    _serviceLocationController.dispose();
    _serialNumberController.dispose();
    _problemController.dispose();
    _workDoneController.dispose();
    _observationsController.dispose();
    _budgetNumberController.dispose();
    _serviceCostController.dispose();
    _expensesController.dispose();
    super.dispose();
  }

  void _selectFromAgenda(ClientModel? c) {
    if (c == null) return;
    _clientNameController.text = c.name;
    _clientAddressController.text = c.address;
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context, initialDate: _selectedDate, firstDate: DateTime(2020), lastDate: DateTime(2030),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(context: context, initialTime: _selectedTime);
    if (time != null) setState(() => _selectedTime = time);
  }

  Future<void> _pickEntryTime(BuildContext ctx) async {
    final time = await showTimePicker(context: ctx, initialTime: _entryTime);
    if (time != null) setState(() => _entryTime = time);
  }

  Future<void> _pickExitTime(BuildContext ctx) async {
    final time = await showTimePicker(context: ctx, initialTime: _exitTime);
    if (time != null) setState(() => _exitTime = time);
  }

  void _onServicesChanged(List<ServiceType> services) => setState(() => _selectedServices = services);
  void _onEquipmentChanged(String brand, String model) => setState(() { _selectedBrand = brand; _selectedModel = model; });
  void _onSignatureChanged(Uint8List? bytes) => setState(() => _signatureBytes = bytes);

  void _addItem() {
    setState(() => _items = [..._items, const ReportItem()]);
  }

  void _removeItem(int i) {
    setState(() => _items = [..._items.take(i), ..._items.skip(i + 1)]);
  }

  void _updateItem(int i, ReportItem item) {
    setState(() => _items = [..._items.take(i), item, ..._items.skip(i + 1)]);
  }

  Future<void> _generateReport() async {
    if (!_formKey.currentState!.validate()) return;

    final controller = context.read<ReportController>();
    final report = ReportModel(
      id: widget.report?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      client: ClientModel(
        name: _clientNameController.text.trim(),
        address: _clientAddressController.text.trim(),
      ),
      serviceLocation: _serviceLocationController.text.trim(),
      employeeName: _selectedEmployee,
      employeePosition: _selectedPosition,
      services: _selectedServices.map((type) => ServiceModel(
        type: type, date: _selectedDate,
        hasSpareParts: _hasSpareParts, hasWarranty: _hasWarranty,
        observations: _observationsController.text.trim(),
        description: _problemController.text.trim(),
      )).toList(),
      equipment: EquipmentModel(
        brand: _selectedBrand, model: _selectedModel,
        serialNumber: _serialNumberController.text.trim(),
      ),
      problemDescription: _problemController.text.trim(),
      workDone: _workDoneController.text.trim(),
      clientSignature: _signatureBytes,
      budgetNumber: _budgetNumberController.text.trim(),
      serviceCost: double.tryParse(_serviceCostController.text.trim()) ?? 0.0,
      expenses: double.tryParse(_expensesController.text.trim()) ?? 0.0,
      items: _items,
      entryTime: '${_entryTime.hour.toString().padLeft(2, '0')}:${_entryTime.minute.toString().padLeft(2, '0')}',
      exitTime: '${_exitTime.hour.toString().padLeft(2, '0')}:${_exitTime.minute.toString().padLeft(2, '0')}',
      visitedTechnicians: _visitedTechnicians.toList(),
      createdAt: DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, _selectedTime.hour, _selectedTime.minute),
    );

    try {
      controller.setReport(report);
      await controller.saveReport();
      if (mounted) Navigator.pushReplacementNamed(context, '/preview');
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
        title: Text(widget.report != null ? 'Editar Reporte' : 'Nuevo Reporte'),
        backgroundColor: AppConstants.primaryColor, foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('Datos del Cliente'),
              if (_clientAgenda.isNotEmpty) ...[
                DropdownButtonFormField<ClientModel>(
                  decoration: const InputDecoration(labelText: 'Seleccionar de agenda', border: OutlineInputBorder()),
                  items: _clientAgenda.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
                  onChanged: _selectFromAgenda,
                ),
                const SizedBox(height: 12),
              ],
              TextFormField(
                controller: _clientNameController,
                decoration: const InputDecoration(labelText: 'Nombre del cliente *', border: OutlineInputBorder()),
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
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedPosition.isEmpty ? null : _selectedPosition,
                decoration: const InputDecoration(labelText: 'Cargo / Posición', border: OutlineInputBorder()),
                items: _positions.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                onChanged: (v) => setState(() => _selectedPosition = v ?? ''),
              ),

              const SizedBox(height: 16),
              _sectionTitle('Técnicos Visitantes'),
              const SizedBox(height: 8),
              if (_employees.isEmpty)
                const Text('No hay empleados registrados. Agréguelos en Configuración.',
                  style: TextStyle(fontSize: 12, color: Colors.grey))
              else
                Wrap(spacing: 6, runSpacing: 4, children: _employees.map((e) => FilterChip(
                  label: Text(e, style: const TextStyle(fontSize: 12)),
                  selected: _visitedTechnicians.contains(e),
                  onSelected: (v) => setState(() {
                    if (v) { _visitedTechnicians.add(e); } else { _visitedTechnicians.remove(e); }
                  }),
                )).toList()),

              const SizedBox(height: 24),
              _sectionTitle('Tipo de Servicio'),
              ServiceCheckbox(onChanged: _onServicesChanged),

              const SizedBox(height: 24),
              _sectionTitle('Fecha y Hora'),
              Row(children: [
                Expanded(child: OutlinedButton.icon(
                  onPressed: _pickDate, icon: const Icon(Icons.calendar_today),
                  label: Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                )),
                const SizedBox(width: 12),
                Expanded(child: OutlinedButton.icon(
                  onPressed: _pickTime, icon: const Icon(Icons.access_time),
                  label: Text(_selectedTime.format(context)),
                )),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: OutlinedButton.icon(
                  onPressed: () => _pickEntryTime(context), icon: const Icon(Icons.login),
                  label: Text('Entrada: ${_entryTime.format(context)}'),
                )),
                const SizedBox(width: 12),
                Expanded(child: OutlinedButton.icon(
                  onPressed: () => _pickExitTime(context), icon: const Icon(Icons.logout),
                  label: Text('Salida: ${_exitTime.format(context)}'),
                )),
              ]),

              const SizedBox(height: 24),
              _sectionTitle('Equipo'),
              EquipmentDropdown(onChanged: _onEquipmentChanged, serialNumberController: _serialNumberController),

              const SizedBox(height: 24),
              _sectionTitle('Descripción del Problema'),
              TextFormField(
                controller: _problemController, maxLines: 4,
                maxLength: 3000, buildCounter: _counter,
                decoration: const InputDecoration(hintText: 'Describa el problema reportado...', border: OutlineInputBorder()),
              ),

              const SizedBox(height: 24),
              _sectionTitle('Trabajo Realizado'),
              TextFormField(
                controller: _workDoneController, maxLines: 4,
                maxLength: 2000, buildCounter: _counter,
                decoration: const InputDecoration(hintText: 'Describa el trabajo realizado...', border: OutlineInputBorder()),
              ),

              const SizedBox(height: 8),
              CheckboxListTile(
                title: const Text('Repuestos Utilizados'), contentPadding: EdgeInsets.zero,
                value: _hasSpareParts, onChanged: (v) => setState(() => _hasSpareParts = v ?? false),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              CheckboxListTile(
                title: const Text('Con Garantía'), contentPadding: EdgeInsets.zero,
                value: _hasWarranty, onChanged: (v) => setState(() => _hasWarranty = v ?? false),
                controlAffinity: ListTileControlAffinity.leading,
              ),

              const SizedBox(height: 16),
              Row(children: [
                _sectionTitle('Items / Repuestos'),
                const Spacer(),
                IconButton(onPressed: _addItem, icon: const Icon(Icons.add_circle, color: AppConstants.primaryColor)),
              ]),
              ..._items.asMap().entries.map((e) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(children: [
                    Row(children: [
                      Text('Ítem ${e.key + 1}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      const Spacer(),
                      IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red), onPressed: () => _removeItem(e.key)),
                    ]),
                    const SizedBox(height: 6),
                    Row(children: [
                      Expanded(child: TextFormField(
                        initialValue: e.value.description,
                        decoration: const InputDecoration(labelText: 'Descripción', border: OutlineInputBorder(), isDense: true),
                        onChanged: (v) => _updateItem(e.key, e.value.copyWith(description: v)),
                      )),
                      const SizedBox(width: 8),
                      Expanded(child: TextFormField(
                        initialValue: e.value.model,
                        decoration: const InputDecoration(labelText: 'Modelo / Ref.', border: OutlineInputBorder(), isDense: true),
                        onChanged: (v) => _updateItem(e.key, e.value.copyWith(model: v)),
                      )),
                    ]),
                    const SizedBox(height: 6),
                    Row(children: [
                      SizedBox(width: 100, child: TextFormField(
                        initialValue: e.value.quantity.toString(),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Cant.', border: OutlineInputBorder(), isDense: true),
                        onChanged: (v) => _updateItem(e.key, e.value.copyWith(quantity: int.tryParse(v) ?? 1)),
                      )),
                      const SizedBox(width: 8),
                      Expanded(child: TextFormField(
                        initialValue: e.value.price > 0 ? e.value.price.toStringAsFixed(2) : '',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(labelText: 'Precio \$', border: OutlineInputBorder(), isDense: true, prefixText: '\$ '),
                        onChanged: (v) => _updateItem(e.key, e.value.copyWith(price: double.tryParse(v) ?? 0)),
                      )),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 90,
                        child: InputDecorator(
                          decoration: const InputDecoration(labelText: 'Total', border: OutlineInputBorder(), isDense: true),
                          child: Text('\$${(e.value.quantity * e.value.price).toStringAsFixed(2)}', style: const TextStyle(fontSize: 13)),
                        ),
                      ),
                    ]),
                  ]),
                ),
              )),

              const SizedBox(height: 16),
              _sectionTitle('Presupuesto y Costos'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _budgetNumberController,
                decoration: const InputDecoration(labelText: 'N° de presupuesto (opcional)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: TextFormField(
                  controller: _serviceCostController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Costo del servicio \$', border: OutlineInputBorder(), prefixText: '\$ '),
                )),
                const SizedBox(width: 12),
                Expanded(child: TextFormField(
                  controller: _expensesController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Gastos \$', border: OutlineInputBorder(), prefixText: '\$ '),
                )),
              ]),

              const SizedBox(height: 24),
              _sectionTitle('Observaciones'),
              TextFormField(
                controller: _observationsController, maxLines: 3,
                maxLength: 1000, buildCounter: _counter,
                decoration: const InputDecoration(hintText: 'Observaciones adicionales...', border: OutlineInputBorder()),
              ),

              const SizedBox(height: 24),
              _sectionTitle('Firma del Cliente'),
              SignaturePad(onSaved: _onSignatureChanged),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity, height: 52,
                child: ElevatedButton.icon(
                  onPressed: _generateReport,
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Generar Reporte PDF', style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(backgroundColor: AppConstants.primaryColor, foregroundColor: Colors.white),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
  );

  Widget? _counter(BuildContext ctx, {required int currentLength, required bool isFocused, required int? maxLength}) =>
      maxLength != null ? Text('$currentLength/$maxLength', style: TextStyle(fontSize: 11, color: currentLength > maxLength * 0.9 ? Colors.orange : Colors.grey)) : null;
}
