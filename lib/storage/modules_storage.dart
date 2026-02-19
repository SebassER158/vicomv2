import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

const String _modulesKey = 'available_modules';

/// Guardar módulos
Future<void> saveModules(Map<String, bool> modules) async {
  final prefs = await SharedPreferences.getInstance();
  final jsonString = jsonEncode(modules);
  await prefs.setString(_modulesKey, jsonString);
}

/// Obtener módulos
Future<Map<String, bool>> getStoredModules() async {
  final prefs = await SharedPreferences.getInstance();
  final jsonString = prefs.getString(_modulesKey);

  if (jsonString == null) {
    return {};
  }

  final Map<String, dynamic> decoded = jsonDecode(jsonString);

  return decoded.map(
    (key, value) => MapEntry(key, value as bool),
  );
}

/// Limpiar (logout)
Future<void> clearModules() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_modulesKey);
}
