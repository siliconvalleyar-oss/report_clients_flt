import 'package:hive_flutter/hive_flutter.dart';

class StorageService {
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<Map>('reports');
    await Hive.openBox('settings');
  }

  static Future<void> saveSetting(String key, dynamic value) async {
    final box = await Hive.openBox('settings');
    await box.put(key, value);
  }

  static Future<dynamic> getSetting(String key) async {
    final box = await Hive.openBox('settings');
    return box.get(key);
  }

  static Future<void> clearAll() async {
    await Hive.deleteBoxFromDisk('reports');
    await Hive.deleteBoxFromDisk('settings');
  }
}
