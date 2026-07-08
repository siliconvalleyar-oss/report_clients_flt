import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/report_controller.dart';
import '../../models/report_model.dart';
import '../../utils/constants.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportController>().loadHistory();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ReportController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por cliente, marca o modelo...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (v) => controller.setSearchQuery(v),
            ),
          ),
          Expanded(
            child: controller.isLoading
                ? const Center(child: CircularProgressIndicator())
                : controller.history.isEmpty
                    ? const Center(child: Text('No hay reportes guardados'))
                    : RefreshIndicator(
                        onRefresh: () => controller.loadHistory(),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: controller.history.length,
                          itemBuilder: (_, i) => _ReportCard(
                            report: controller.history[i],
                            onTap: () {
                              context.read<ReportController>().setReport(controller.history[i]);
                              Navigator.pushNamed(context, '/pdf_viewer');
                            },
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final ReportModel report;
  final VoidCallback onTap;

  const _ReportCard({
    required this.report,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppConstants.primaryColor.withAlpha(30),
          child: const Icon(Icons.picture_as_pdf, color: AppConstants.primaryColor),
        ),
        title: Text(report.client.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          '${report.equipment.brand} ${report.equipment.model} - ${report.createdAt.day}/${report.createdAt.month}/${report.createdAt.year}',
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
