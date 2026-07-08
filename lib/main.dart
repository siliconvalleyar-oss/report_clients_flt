import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/report_controller.dart';
import 'controllers/export_controller.dart';
import 'controllers/validation_controller.dart';
import 'services/storage_service.dart';
import 'utils/themes.dart';
import 'views/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  runApp(const ReportClientsApp());
}

class ReportClientsApp extends StatelessWidget {
  const ReportClientsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ReportController()),
        ChangeNotifierProvider(create: (_) => ExportController()),
        ChangeNotifierProvider(create: (_) => ValidationController()),
      ],
      child: MaterialApp(
        title: 'Electromedicina Pro',
        debugShowCheckedModeBanner: false,
        theme: AppThemes.lightTheme,
        darkTheme: AppThemes.darkTheme,
        themeMode: ThemeMode.light,
        home: const HomeScreen(),
      ),
    );
  }
}
