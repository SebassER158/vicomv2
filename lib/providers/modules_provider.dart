import 'package:flutter/material.dart';
import '../storage/modules_storage.dart';

class ModulesProvider with ChangeNotifier {
  Map<String, bool> _availableModules = {};
  bool _initialized = false;

  Map<String, bool> get availableModules => _availableModules;
  bool get initialized => _initialized;

  bool hasModule(String key) => _availableModules[key] == true;

  /// Cargar módulos desde persistencia
  Future<void> loadFromStorage() async {
    final storedModules = await getStoredModules();

    _availableModules = Map<String, bool>.from(storedModules);
    _initialized = true;

    notifyListeners();
  }

  /// Guardar módulos desde API (configuración)
  Future<void> setModules(Map<String, bool> modules) async {
    _availableModules = modules;
    _initialized = true;

    await saveModules(modules);
    notifyListeners();
  }

  void clear() {
    _availableModules = {};
    _initialized = false;
    notifyListeners();
  }
}
