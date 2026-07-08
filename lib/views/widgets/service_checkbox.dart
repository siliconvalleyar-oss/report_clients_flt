import 'package:flutter/material.dart';
import '../../models/service_model.dart';

class ServiceCheckbox extends StatefulWidget {
  final ValueChanged<List<ServiceType>> onChanged;

  const ServiceCheckbox({super.key, required this.onChanged});

  @override
  State<ServiceCheckbox> createState() => _ServiceCheckboxState();
}

class _ServiceCheckboxState extends State<ServiceCheckbox> {
  bool _preventive = false;
  bool _corrective = false;
  bool _calibration = false;
  bool _installation = false;

  void _notify() {
    final selected = <ServiceType>[];
    if (_preventive) selected.add(ServiceType.preventive);
    if (_corrective) selected.add(ServiceType.corrective);
    if (_calibration) selected.add(ServiceType.calibration);
    if (_installation) selected.add(ServiceType.installation);
    widget.onChanged(selected);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CheckboxListTile(
          title: const Text('Preventivo'),
          value: _preventive,
          onChanged: (v) => setState(() { _preventive = v ?? false; _notify(); }),
          controlAffinity: ListTileControlAffinity.leading,
        ),
        CheckboxListTile(
          title: const Text('Correctivo'),
          value: _corrective,
          onChanged: (v) => setState(() { _corrective = v ?? false; _notify(); }),
          controlAffinity: ListTileControlAffinity.leading,
        ),
        CheckboxListTile(
          title: const Text('Calibración'),
          value: _calibration,
          onChanged: (v) => setState(() { _calibration = v ?? false; _notify(); }),
          controlAffinity: ListTileControlAffinity.leading,
        ),
        CheckboxListTile(
          title: const Text('Instalación'),
          value: _installation,
          onChanged: (v) => setState(() { _installation = v ?? false; _notify(); }),
          controlAffinity: ListTileControlAffinity.leading,
        ),
      ],
    );
  }
}
