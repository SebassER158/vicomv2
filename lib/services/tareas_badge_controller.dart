import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vicomv2/apis/api.dart';

/// Cuenta las "tareas realizadas" no vistas todavía por el usuario, para
/// mostrarlas como notificación (círculo rojo) en el ítem "Tareas" de
/// [AppBottomNavBar]. Hay dos contadores independientes:
/// - [porTienda]: tareas realizadas de la tienda actual (idTienda).
/// - [global]: tareas realizadas de todas las tiendas (nip del usuario).
///
/// El "último visto" se persiste por tienda / por usuario en
/// SharedPreferences. Al refrescar se compara el total actual contra ese
/// valor; al entrar a la pantalla de tareas correspondiente se marca como
/// leído (el total actual pasa a ser el nuevo "último visto").
class TareasBadgeController {
  TareasBadgeController._();
  static final TareasBadgeController instance = TareasBadgeController._();

  final ValueNotifier<int> porTienda = ValueNotifier<int>(0);
  final ValueNotifier<int> global = ValueNotifier<int>(0);

  String _keyTienda(int idTienda) => 'tareas_realizadas_leidas_tienda_$idTienda';
  String _keyGlobal(String nip) => 'tareas_realizadas_leidas_global_$nip';

  Future<void> refreshPorTienda() async {
    final prefs = await SharedPreferences.getInstance();
    final cuenta = prefs.getString('cuenta') ?? '';
    final idTienda = prefs.getInt('idTienda') ?? 0;
    if (cuenta.isEmpty || idTienda == 0) {
      porTienda.value = 0;
      return;
    }
    try {
      final response = await Api().getTareasRealizadas(cuenta, idTienda);
      if (response.statusCode == 200) {
        final data = (jsonDecode(response.body) as List?) ?? [];
        final leidas = prefs.getInt(_keyTienda(idTienda)) ?? 0;
        final diff = data.length - leidas;
        porTienda.value = diff > 0 ? diff : 0;
      }
    } catch (e) {
      print('Error al refrescar badge de tareas por tienda: $e');
    }
  }

  Future<void> marcarLeidoPorTienda(int totalRealizadas) async {
    final prefs = await SharedPreferences.getInstance();
    final idTienda = prefs.getInt('idTienda') ?? 0;
    if (idTienda == 0) return;
    await prefs.setInt(_keyTienda(idTienda), totalRealizadas);
    porTienda.value = 0;
  }

  Future<void> refreshGlobal() async {
    final prefs = await SharedPreferences.getInstance();
    final cuenta = prefs.getString('cuenta') ?? '';
    final nip = prefs.getString('nip') ?? '';
    if (cuenta.isEmpty || nip.isEmpty) {
      global.value = 0;
      return;
    }
    try {
      final response = await Api().getTareasRealizadasGlobal(cuenta, nip);
      if (response.statusCode == 200) {
        final data = (jsonDecode(response.body) as List?) ?? [];
        final leidas = prefs.getInt(_keyGlobal(nip)) ?? 0;
        final diff = data.length - leidas;
        global.value = diff > 0 ? diff : 0;
      }
    } catch (e) {
      print('Error al refrescar badge de tareas global: $e');
    }
  }

  Future<void> marcarLeidoGlobal(int totalRealizadas) async {
    final prefs = await SharedPreferences.getInstance();
    final nip = prefs.getString('nip') ?? '';
    if (nip.isEmpty) return;
    await prefs.setInt(_keyGlobal(nip), totalRealizadas);
    global.value = 0;
  }
}
