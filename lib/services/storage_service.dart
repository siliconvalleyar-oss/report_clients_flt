import 'dart:typed_data';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/client_model.dart';
import '../models/report_item.dart';

class FontConfig {
  static const _defaultTitleFamily = 'Helvetica';
  static const _defaultLabelFamily = 'Helvetica';
  static const _defaultContentFamily = 'Helvetica';
  static const _defaultTitleSize = 9.0;
  static const _defaultLabelSize = 8.0;
  static const _defaultContentSize = 8.5;

  final String titleFamily;
  final String labelFamily;
  final String contentFamily;
  final double titleSize;
  final double labelSize;
  final double contentSize;

  const FontConfig({
    this.titleFamily = _defaultTitleFamily,
    this.labelFamily = _defaultLabelFamily,
    this.contentFamily = _defaultContentFamily,
    this.titleSize = _defaultTitleSize,
    this.labelSize = _defaultLabelSize,
    this.contentSize = _defaultContentSize,
  });

  Map<String, dynamic> toMap() => {
        'fontTitleFamily': titleFamily,
        'fontLabelFamily': labelFamily,
        'fontContentFamily': contentFamily,
        'fontTitleSize': titleSize,
        'fontLabelSize': labelSize,
        'fontContentSize': contentSize,
      };

  factory FontConfig.fromMap(Map<String, dynamic> map) => FontConfig(
        titleFamily: map['fontTitleFamily'] ?? _defaultTitleFamily,
        labelFamily: map['fontLabelFamily'] ?? _defaultLabelFamily,
        contentFamily: map['fontContentFamily'] ?? _defaultContentFamily,
        titleSize: (map['fontTitleSize'] ?? _defaultTitleSize).toDouble(),
        labelSize: (map['fontLabelSize'] ?? _defaultLabelSize).toDouble(),
        contentSize: (map['fontContentSize'] ?? _defaultContentSize).toDouble(),
      );

  static const List<String> availableFamilies = [
    'Helvetica',
    'Times-Roman',
    'Courier',
  ];
}

class StorageService {
  static const _settingsBox = 'settings';
  static const _stampKey = 'companyStampImage';
  static const _logoKey = 'companyLogoImage';
  static const _customBrandsKey = 'customBrands';
  static const _customModelsPrefix = 'customModels_';
  static const _fontConfigKey = 'fontConfig';
  static const _watermarkOpacityKey = 'watermarkOpacity';
  static const _watermarkEnabledKey = 'watermarkEnabled';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<Map>('reports');
    await Hive.openBox(_settingsBox);
  }

  static Future<Box> get _box async => await Hive.openBox(_settingsBox);

  static Future<void> saveSetting(String key, dynamic value) async {
    await (await _box).put(key, value);
  }

  static Future<dynamic> getSetting(String key) async {
    return (await _box).get(key);
  }

  static Future<void> saveStampImage(Uint8List bytes) async {
    await (await _box).put(_stampKey, bytes.toList());
  }

  static Future<Uint8List?> getStampImage() async {
    final data = (await _box).get(_stampKey);
    if (data != null && data is List<int>) {
      return Uint8List.fromList(data);
    }
    return null;
  }

  static Future<void> clearStampImage() async {
    await (await _box).delete(_stampKey);
  }

  static Future<void> saveLogoImage(Uint8List bytes) async {
    await (await _box).put(_logoKey, bytes.toList());
  }

  static Future<Uint8List?> getLogoImage() async {
    final data = (await _box).get(_logoKey);
    if (data != null && data is List<int>) {
      return Uint8List.fromList(data);
    }
    return null;
  }

  static Future<void> clearLogoImage() async {
    await (await _box).delete(_logoKey);
  }

  static Future<void> saveWatermarkSettings({required bool enabled, required double opacity}) async {
    final box = await _box;
    await box.put(_watermarkEnabledKey, enabled);
    await box.put(_watermarkOpacityKey, opacity);
  }

  static Future<Map<String, dynamic>> loadWatermarkSettings() async {
    final box = await _box;
    return {
      'enabled': box.get(_watermarkEnabledKey, defaultValue: true) as bool,
      'opacity': (box.get(_watermarkOpacityKey, defaultValue: 0.4) as num).toDouble(),
    };
  }

  static Future<List<String>> getCustomBrands() async {
    final data = (await _box).get(_customBrandsKey);
    if (data != null && data is List) {
      return data.cast<String>();
    }
    return [];
  }

  static Future<void> saveCustomBrands(List<String> brands) async {
    await (await _box).put(_customBrandsKey, brands);
  }

  static Future<void> addCustomBrand(String brand) async {
    final brands = await getCustomBrands();
    if (!brands.contains(brand)) {
      brands.add(brand);
      await saveCustomBrands(brands);
    }
  }

  static Future<List<String>> getCustomModels(String brand) async {
    final data = (await _box).get('$_customModelsPrefix$brand');
    if (data != null && data is List) {
      return data.cast<String>();
    }
    return [];
  }

  static Future<void> saveCustomModels(String brand, List<String> models) async {
    await (await _box).put('$_customModelsPrefix$brand', models);
  }

  static Future<void> addCustomModel(String brand, String model) async {
    final models = await getCustomModels(brand);
    if (!models.contains(model)) {
      models.add(model);
      await saveCustomModels(brand, models);
    }
  }

  static Future<void> saveCompanyData({
    required String name,
    required String address,
    required String phone,
    required String email,
  }) async {
    final box = await _box;
    await box.put('companyName', name);
    await box.put('companyAddress', address);
    await box.put('companyPhone', phone);
    await box.put('companyEmail', email);
  }

  static Future<Map<String, String>> loadCompanyData() async {
    final box = await _box;
    return {
      'name': box.get('companyName', defaultValue: 'Electromedicina Pro') as String,
      'address': box.get('companyAddress', defaultValue: '') as String,
      'phone': box.get('companyPhone', defaultValue: '') as String,
      'email': box.get('companyEmail', defaultValue: '') as String,
      'subtitle': box.get('companySubtitle', defaultValue: 'SERVICIO TÉCNICO ESPECIALIZADO') as String,
    };
  }

  static Future<void> saveCompanySubtitle(String subtitle) async {
    await (await _box).put('companySubtitle', subtitle);
  }

  static Future<FontConfig> getFontConfig() async {
    final data = (await _box).get(_fontConfigKey);
    if (data != null && data is Map) {
      return FontConfig.fromMap(Map<String, dynamic>.from(data));
    }
    return const FontConfig();
  }

  static Future<void> saveFontConfig(FontConfig config) async {
    await (await _box).put(_fontConfigKey, config.toMap());
  }

  static Future<List<String>> getEmployees() async {
    final data = (await _box).get('employees');
    if (data != null && data is List) return data.cast<String>();
    return ['Carlos Méndez', 'Ana López', 'Pedro Ramírez', 'Laura Gutiérrez', 'Roberto Sánchez'];
  }

  static Future<void> saveEmployees(List<String> list) async {
    await (await _box).put('employees', list);
  }

  static Future<void> addEmployee(String name) async {
    final list = await getEmployees();
    if (!list.contains(name)) { list.add(name); await saveEmployees(list); }
  }

  static Future<void> removeEmployee(String name) async {
    final list = await getEmployees();
    list.remove(name);
    await saveEmployees(list);
  }

  static Future<List<String>> getPositions() async {
    final data = (await _box).get('positions');
    if (data != null && data is List) return data.cast<String>();
    return ['Técnico', 'Ingeniero', 'Ingeniero Electrónico', 'Bioingeniero', 'Contador', 'Secretaria/o', 'Gerente', 'CEO'];
  }

  static Future<void> savePositions(List<String> list) async {
    await (await _box).put('positions', list);
  }

  static Future<void> addPosition(String name) async {
    final list = await getPositions();
    if (!list.contains(name)) { list.add(name); await savePositions(list); }
  }

  static Future<void> removePosition(String name) async {
    final list = await getPositions();
    list.remove(name);
    await savePositions(list);
  }

  static Future<List<ClientModel>> getClientAgenda() async {
    final data = (await _box).get('clientAgenda');
    if (data != null && data is List) {
      return data.map((e) => ClientModel.fromMap(Map<String, dynamic>.from(e))).toList();
    }
    return [];
  }

  static Future<void> saveClientAgenda(List<ClientModel> list) async {
    await (await _box).put('clientAgenda', list.map((c) => c.toMap()).toList());
  }

  static Future<void> addClientToAgenda(ClientModel client) async {
    final list = await getClientAgenda();
    list.removeWhere((c) => c.name == client.name);
    list.add(client);
    await saveClientAgenda(list);
  }

  static Future<void> removeClientFromAgenda(String name) async {
    final list = await getClientAgenda();
    list.removeWhere((c) => c.name == name);
    await saveClientAgenda(list);
  }

  static Future<void> clearAll() async {
    await Hive.deleteBoxFromDisk('reports');
    await Hive.deleteBoxFromDisk(_settingsBox);
  }
}
