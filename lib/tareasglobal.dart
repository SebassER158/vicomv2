import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vicomv2/apis/api.dart';
import 'package:vicomv2/models/tarea_asignada.dart';
import 'package:vicomv2/services/tareas_badge_controller.dart';
import 'package:vicomv2/tareas_global_detalle.dart';
import 'package:vicomv2/widgets/app_bottom_nav_bar.dart';
import 'package:vicomv2/widgets/tarea_card.dart';
import 'package:vicomv2/widgets/tienda_filter_chips.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

const int _maxPreview = 5;

class TareasGlobal extends StatefulWidget {
  static Route<dynamic> route() {
    return MaterialPageRoute(
      builder: (context) => TareasGlobal(),
    );
  }

  @override
  TareasGlobalState createState() => TareasGlobalState();
}

class TareasGlobalState extends State<TareasGlobal> {
  String cuenta = "";
  String nip = "";

  int tareasObjetivo = 0;
  List<TareaAsignada> tareasPendientes = [];
  List<TareaAsignada> tareasRealizadas = [];

  bool isLoading = true;
  String? _tiendaSeleccionada;
  int _selectedIndex = 0;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  List<String> get _tiendasDisponibles {
    final nombres = {
      ...tareasRealizadas.map((t) => t.tienda),
      ...tareasPendientes.map((t) => t.tienda),
    }..removeWhere((t) => t.isEmpty);
    final lista = nombres.toList()..sort();
    return lista;
  }

  List<TareaAsignada> get _realizadasFiltradas => _tiendaSeleccionada == null
      ? tareasRealizadas
      : tareasRealizadas.where((t) => t.tienda == _tiendaSeleccionada).toList();

  List<TareaAsignada> get _pendientesFiltradas => _tiendaSeleccionada == null
      ? tareasPendientes
      : tareasPendientes.where((t) => t.tienda == _tiendaSeleccionada).toList();

  @override
  void initState() {
    super.initState();
    getData();
  }

  void _onRefresh() async {
    getData();
    _refreshController.refreshCompleted();
  }

  void getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    cuenta = (prefs.getString('cuenta') ?? "");
    nip = (prefs.getString('nip') ?? "");

    try {
      var response = await Api().getTareasPendientesGlobal(cuenta, nip);
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body) ?? [];
        final parsed = data
            .map((e) => TareaAsignada.fromJson(e, isCompleted: false))
            .toList()
          ..sort((a, b) => b.fecha.compareTo(a.fecha));
        setState(() => tareasPendientes = parsed);
      } else {
        print(response.statusCode);
      }
    } catch (e) {
      print("Error de conexión: $e");
    }

    try {
      var response1 = await Api().getTareasRealizadasGlobal(cuenta, nip);
      if (response1.statusCode == 200) {
        List<dynamic> data = jsonDecode(response1.body) ?? [];
        final parsed = data
            .map((e) => TareaAsignada.fromJson(e, isCompleted: true))
            .toList()
          ..sort((a, b) => b.fecha.compareTo(a.fecha));
        setState(() => tareasRealizadas = parsed);
        TareasBadgeController.instance.marcarLeidoGlobal(parsed.length);
      } else {
        print(response1.statusCode);
      }
    } catch (e) {
      print("Error de conexión: $e");
    }

    try {
      var response2 = await Api().getTareasAsignadasMesGlobal(cuenta, nip);
      if (response2.statusCode == 200) {
        var tareas = jsonDecode(response2.body);
        setState(() {
          tareasObjetivo = tareas != null && tareas.isNotEmpty
              ? (tareas[0]["total_tareas_objetivo"] ?? 0)
              : 0;
        });
      } else {
        print(response2.statusCode);
      }
    } catch (e) {
      print("Error de conexión: $e");
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _verMas(String titulo, List<TareaAsignada> tareasCompletas) {
    Navigator.of(context).push(TareasGlobalDetalle.route(
      titulo: titulo,
      tareas: tareasCompletas,
      tiendaInicial: _tiendaSeleccionada,
    ));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Montserrat'),
      home: Scaffold(
        backgroundColor: Colors.grey[100],
        body: SmartRefresher(
          header: const WaterDropMaterialHeader(
            color: Color(0xff060024),
            backgroundColor: Color(0xff007DA4),
          ),
          onRefresh: _onRefresh,
          controller: _refreshController,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // PREMIUM HEADER
                Stack(
                  children: [
                    Container(
                      height: 140,
                      decoration: const BoxDecoration(
                        color: Color(0xff060024),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 10),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back,
                                  color: Colors.white),
                              onPressed: () => Navigator.pop(context),
                            ),
                            const Expanded(
                              child: Text(
                                'Tareas Asignadas',
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 48),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.filter_alt_rounded,
                              color: Color(0xff007DA4), size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Filtrar por tienda',
                            style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (_tiendasDisponibles.isNotEmpty)
                        TiendaFilterChips(
                          tiendas: _tiendasDisponibles,
                          seleccionada: _tiendaSeleccionada,
                          onChanged: (tienda) =>
                              setState(() => _tiendaSeleccionada = tienda),
                        ),
                      const SizedBox(height: 15),

                      // SUMMARY CARDS
                      Row(
                        children: [
                          Expanded(
                              child: _statCard(
                                  'Asignadas',
                                  tareasObjetivo.toString(),
                                  const Color(0xff007DA4),
                                  Icons.assignment)),
                          const SizedBox(width: 12),
                          Expanded(
                              child: _statCard(
                                  'Realizadas',
                                  _realizadasFiltradas.length.toString(),
                                  Colors.green,
                                  Icons.check_circle)),
                          const SizedBox(width: 12),
                          Expanded(
                              child: _statCard(
                                  'Pendientes',
                                  _pendientesFiltradas.length.toString(),
                                  Colors.orange,
                                  Icons.pending_actions)),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // COMPLETED TASKS
                      Row(
                        children: const [
                          Icon(Icons.check_circle,
                              color: Colors.green, size: 20),
                          SizedBox(width: 8),
                          Text('Tareas Realizadas',
                              style: TextStyle(
                                  color: Color(0xff060024),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 15),
                      _lista(
                        titulo: 'Tareas Realizadas',
                        tareas: _realizadasFiltradas,
                        tareasCompletas: tareasRealizadas,
                        emptyMsg: 'Sin tareas realizadas',
                      ),
                      const SizedBox(height: 30),

                      // PENDING TASKS
                      Row(
                        children: const [
                          Icon(Icons.pending_actions,
                              color: Colors.orange, size: 20),
                          SizedBox(width: 8),
                          Text('Tareas Pendientes',
                              style: TextStyle(
                                  color: Color(0xff060024),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 15),
                      _lista(
                        titulo: 'Tareas Pendientes',
                        tareas: _pendientesFiltradas,
                        tareasCompletas: tareasPendientes,
                        emptyMsg: 'Sin tareas pendientes',
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: AppBottomNavBar(
          currentIndex: _selectedIndex,
          isLoginContext: true,
          onIndexChanged: (index) => setState(() => _selectedIndex = index),
        ),
      ),
    );
  }

  Widget _lista({
    required String titulo,
    required List<TareaAsignada> tareas,
    required List<TareaAsignada> tareasCompletas,
    required String emptyMsg,
  }) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: CircularProgressIndicator(color: Color(0xff007DA4)),
        ),
      );
    }
    if (tareas.isEmpty) {
      return _emptyState(emptyMsg);
    }

    final visibles = tareas.take(_maxPreview).toList();
    return Column(
      children: [
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: visibles.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (ctx, i) => TareaCard(tarea: visibles[i]),
        ),
        if (tareas.length > _maxPreview)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _verMas(titulo, tareasCompletas),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xff007DA4)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  'Ver más (${tareas.length - _maxPreview})',
                  style: const TextStyle(
                      color: Color(0xff007DA4), fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _statCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 3),
          Text(label,
              style: TextStyle(color: Colors.grey[600], fontSize: 10),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _emptyState(String msg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child:
          Center(child: Text(msg, style: const TextStyle(color: Colors.grey))),
    );
  }
}
