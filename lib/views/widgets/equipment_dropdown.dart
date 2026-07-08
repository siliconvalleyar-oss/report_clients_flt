import 'package:flutter/material.dart';
import '../../services/storage_service.dart';

class EquipmentDropdown extends StatefulWidget {
  final void Function(String brand, String model) onChanged;
  final TextEditingController serialNumberController;

  const EquipmentDropdown({
    super.key,
    required this.onChanged,
    required this.serialNumberController,
  });

  @override
  State<EquipmentDropdown> createState() => _EquipmentDropdownState();
}

class _EquipmentDropdownState extends State<EquipmentDropdown> {
  String _selectedBrand = '';
  String _selectedModel = '';
  List<String> _customBrands = [];
  Map<String, List<String>> _customModels = {};

  static const Map<String, List<String>> _defaultBrandModels = {
    'GE Healthcare': ['Logiq E9', 'Logiq P7', 'Voluson S8', 'Vivid E95', 'Dash 4000'],
    'Siemens': ['Somatom Force', 'Magnetom Vida', 'Acuson SC2000', 'Syngo DynaCT'],
    'Philips': ['EPIQ 7', 'Affiniti 70', 'IntelliVue MX800', 'Azurion 7'],
    'Mindray': ['DC-80', 'SV300', 'BeneVision N19', 'ePM 12'],
    'Drager': ['Savina 300', 'Evita V800', 'Babylog VN800', 'Perseus A500'],
    'Baxter': ['Sigma Spectrum', 'Flo-Gard 6301', 'Colleague 3', 'APEX CHAMPION'],
  };

  List<String> get _allBrands =>
      [..._defaultBrandModels.keys, ..._customBrands];

  List<String> _modelsFor(String brand) {
    final defaults = _defaultBrandModels[brand] ?? [];
    final customs = _customModels[brand] ?? [];
    return [...defaults, ...customs];
  }

  @override
  void initState() {
    super.initState();
    _loadCustomData();
  }

  Future<void> _loadCustomData() async {
    final brands = await StorageService.getCustomBrands();
    final Map<String, List<String>> models = {};
    for (final b in brands) {
      models[b] = await StorageService.getCustomModels(b);
    }
    if (mounted) {
      setState(() {
        _customBrands = brands;
        _customModels = models;
      });
    }
  }

  void _onBrandChanged(String? brand) {
    if (brand == null) return;
    setState(() {
      _selectedBrand = brand;
      _selectedModel = '';
    });
    widget.onChanged(_selectedBrand, _selectedModel);
  }

  void _onModelChanged(String? model) {
    if (model == null) return;
    setState(() => _selectedModel = model);
    widget.onChanged(_selectedBrand, _selectedModel);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: _selectedBrand.isEmpty ? null : _selectedBrand,
          decoration: const InputDecoration(labelText: 'Marca', border: OutlineInputBorder()),
          items: _allBrands.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
          onChanged: _onBrandChanged,
          validator: (v) => v == null || v.isEmpty ? 'Seleccione una marca' : null,
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _selectedBrand.isEmpty || _selectedModel.isEmpty ? null : _selectedModel,
          decoration: const InputDecoration(labelText: 'Modelo', border: OutlineInputBorder()),
          items: _modelsFor(_selectedBrand).map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
          onChanged: _selectedBrand.isNotEmpty ? _onModelChanged : null,
          validator: (v) => v == null || v.isEmpty ? 'Seleccione un modelo' : null,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: widget.serialNumberController,
          decoration: const InputDecoration(labelText: 'Número de Serie', border: OutlineInputBorder()),
        ),
      ],
    );
  }
}
