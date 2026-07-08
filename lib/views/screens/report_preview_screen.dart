import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/report_controller.dart';
import '../../utils/constants.dart';
import '../widgets/export_buttons.dart';

class ReportPreviewScreen extends StatelessWidget {
  const ReportPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final report = context.watch<ReportController>().currentReport;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vista Previa'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(report),
            const Divider(height: 32),
            _buildSection('Datos del Cliente', [
              _item('Nombre', report.client.name),
              _item('Dirección', report.client.address),
              if (report.serviceLocation.isNotEmpty) _item('Lugar de servicio', report.serviceLocation),
            ]),
            const SizedBox(height: 16),
            _buildSection('Empleado', [
              _item('Nombre', report.employeeName),
              if (report.employeePosition.isNotEmpty) _item('Cargo', report.employeePosition),
            ]),
            const SizedBox(height: 16),
            _buildSection('Servicio', [
              if (report.services.isNotEmpty) _item('Tipo', report.services.map((s) => s.typeName).join(', ')),
              _item('Fecha', '${report.createdAt.day}/${report.createdAt.month}/${report.createdAt.year}'),
              _item('Hora', '${report.createdAt.hour.toString().padLeft(2, '0')}:${report.createdAt.minute.toString().padLeft(2, '0')}'),
            ]),
            const SizedBox(height: 16),
            _buildSection('Equipo', [
              _item('Marca', report.equipment.brand),
              _item('Modelo', report.equipment.model),
              if (report.equipment.serialNumber.isNotEmpty) _item('Nro. Serie', report.equipment.serialNumber),
            ]),
            const SizedBox(height: 16),
            if (report.problemDescription.isNotEmpty)
              _buildSection('Problema Reportado', [Text(report.problemDescription)]),
            const SizedBox(height: 16),
            if (report.workDone.isNotEmpty)
              _buildSection('Trabajo Realizado', [Text(report.workDone)]),
            const SizedBox(height: 16),
            _buildSection('Detalles', [
              if (report.services.any((s) => s.hasSpareParts)) _item('Repuestos', 'Sí'),
              if (report.services.any((s) => s.hasWarranty)) _item('Garantía', 'Sí'),
            ]),
            if (report.budgetNumber.isNotEmpty || report.serviceCost > 0 || report.expenses > 0) ...[
              const SizedBox(height: 16),
              _buildSection('Presupuesto', [
                if (report.budgetNumber.isNotEmpty) _item('N° Presupuesto', report.budgetNumber),
                if (report.serviceCost > 0) _item('Costo del servicio', '\$${report.serviceCost.toStringAsFixed(2)}'),
                if (report.expenses > 0) _item('Gastos', '\$${report.expenses.toStringAsFixed(2)}'),
                if (report.totalCost > 0) _item('Total', '\$${report.totalCost.toStringAsFixed(2)}'),
              ]),
            ],
            const SizedBox(height: 16),
            if (report.services.isNotEmpty && report.services.first.observations.isNotEmpty)
              _buildSection('Observaciones', [Text(report.services.first.observations)]),
            if (report.clientSignature != null) ...[
              const SizedBox(height: 16),
              _buildSection('Firma del Cliente', [
                Image.memory(report.clientSignature!, height: 80),
              ]),
            ],
            const SizedBox(height: 24),
            Center(
              child: Text('ID: ${report.id}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ),
            const SizedBox(height: 24),
            ExportButtons(report: report),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(report) {
    return Center(
      child: Column(
        children: [
          const Icon(Icons.medical_services, size: 48, color: AppConstants.primaryColor),
          const SizedBox(height: 8),
          Text(AppConstants.appName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Reporte Técnico', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppConstants.primaryColor)),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _item(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.w500))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
