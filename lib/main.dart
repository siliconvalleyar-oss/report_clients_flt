import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/report_controller.dart';
import 'controllers/export_controller.dart';
import 'controllers/validation_controller.dart';
import 'controllers/theme_controller.dart';
import 'services/storage_service.dart';
import 'utils/themes.dart';
import 'views/screens/home_screen.dart';
import 'views/screens/report_form_screen.dart';
import 'views/screens/history_screen.dart';
import 'views/screens/settings_screen.dart';
import 'views/screens/report_preview_screen.dart';

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
        ChangeNotifierProvider(create: (_) => ThemeController()),
      ],
      child: Consumer<ThemeController>(
        builder: (context, themeController, _) {
          return MaterialApp(
            title: 'Electromedicina Pro',
            debugShowCheckedModeBanner: false,
            theme: AppThemes.lightTheme,
            darkTheme: AppThemes.darkTheme,
            themeMode: themeController.themeMode,
            home: const HomeScreen(),
            routes: {
              '/report': (_) => const ReportFormScreen(),
              '/history': (_) => const HistoryScreen(),
              '/settings': (_) => const SettingsScreen(),
              '/preview': (_) => const ReportPreviewScreen(),
            },
          );
        },
      ),
    );
  }
}
