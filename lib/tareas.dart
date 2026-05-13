import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:vicomv2/apis/api.dart';
import 'package:vicomv2/asignaciontareas.dart';
import 'package:vicomv2/biscreen.dart';
import 'package:vicomv2/exhibiciones.dart';
import 'package:vicomv2/frentes.dart';
import 'package:vicomv2/homescreen.dart';
import 'package:vicomv2/puntoscontrol.dart';
import 'package:vicomv2/usuario/actividadesscreen.dart';
import 'package:intl/intl.dart';
import 'package:search_choices/search_choices.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:vicomv2/widgets/app_drawer.dart';

import 'loginScreen.dart';

class Tareas extends StatefulWidget {
  static Route<dynamic> route(String mensaje) {
    return MaterialPageRoute(
      builder: (context) => Tareas(),
    );
  }

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Tareas> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  late String datauv;
  var ultimaVisitaList = [];
  var ultimaVisita;
  int idTienda = 0;
  String cuenta = "";
  String tienda = "";
  String formato = "";
  String fechaInicial = "";
  String perfil = "";
  String userCeys = "";
  String nombreUsuario = "";

  int tareas_objetivo = 0;
  var tareas_pendientes;
  var tareas_realizadas;
  var tareas_pendientesList = [];
  var tareas_realizadasList = [];

  int _selectedIndex = 0;

  final ImagePicker _picker = ImagePicker();

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  Map<String, bool> availableModules = {};
  bool loadingModules = true;

  @override
  void initState() {
    super.initState();
    loginState();
    loadModules();
    getData();
  }

  Future<void> loadModules() async {
    final modules = await getStoredModules();

    setState(() {
      availableModules = modules;
      loadingModules = false;
    });

    print('Módulos cargados en Home: $availableModules');
  }

  Future<Map<String, bool>> getStoredModules() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('available_modules');

    if (raw == null) return {};

    final decoded = jsonDecode(raw) as Map<String, dynamic>;

    return decoded.map((key, value) => MapEntry(key, value == true));
  }

  void _onRefresh() async {
    // monitor network fetch
    getData();
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void loginState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      idTienda = (prefs.getInt('idTienda') ?? 0);
      cuenta = (prefs.getString('cuenta') ?? "");
      tienda = (prefs.getString('tienda') ?? "");
      formato = (prefs.getString('formato') ?? "");
    });
  }

  void getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    cuenta = (prefs.getString('cuenta') ?? "");

    try {
      var response = await Api().getTareasPendientes(cuenta, idTienda);
      if (response.statusCode == 200) {
        print("Entro en response 200");
        String respuesta = response.body;
        setState(() {
          tareas_pendientes = jsonDecode(respuesta);
          tareas_pendientesList = tareas_pendientes ?? "[]";
        });
      } else {
        print(response.statusCode);
      }
    } catch (e) {
      print("Error de conexión: $e");
    }

    try {
      var response1 = await Api().getTareasRealizadas(cuenta, idTienda);
      if (response1.statusCode == 200) {
        print("Entro en response 200");
        String respuesta = response1.body;
        setState(() {
          tareas_realizadas = jsonDecode(respuesta);
          tareas_realizadasList = tareas_realizadas ?? "[]";
        });
      } else {
        print(response1.statusCode);
      }
    } catch (e) {
      print("Error de conexión: $e");
    }

    try {
      var response2 = await Api().getTareasAsignadasMes(cuenta, idTienda);
      if (response2.statusCode == 200) {
        print("Entro en response 200");
        String respuesta = response2.body;
        var tareas = jsonDecode(respuesta);
        setState(() {
          tareas_objetivo = tareas[0]["total_tareas_objetivo"] ?? 0;
        });
      } else {
        print(response2.statusCode);
      }
    } catch (e) {
      print("Error de conexión: $e");
    }
  }

  void logout() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove("logueado");
    await preferences.remove("nip");
    await preferences.remove("id_sucursal");
    await preferences.remove("usuario");
    await preferences.remove("id_usuario");
    await preferences.remove("alias");

    // await preferences.clear();
    //Navigator.of(context).push(LoginS.route("mensaje"));
    Navigator.of(context).pushReplacement(LoginScreen.route());
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
      } else {
        print('No se seleccionó ninguna imagen.');
      }
    });
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Montserrat'),
      home: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.grey[100],
        drawer: AppDrawer(onLogout: logout, availableModules: availableModules),
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
                      height: 180,
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
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
                            const Text('Tareas', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                            Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.menu, color: Colors.white), onPressed: () => Scaffold.of(ctx).openDrawer())),
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
                      // SUMMARY CARDS
                      Row(
                        children: [
                          Expanded(child: _statCard('Asignadas', tareas_objetivo.toString(), const Color(0xff007DA4), Icons.assignment)),
                          const SizedBox(width: 12),
                          Expanded(child: _statCard('Realizadas', tareas_realizadasList.length.toString(), Colors.green, Icons.check_circle)),
                          const SizedBox(width: 12),
                          Expanded(child: _statCard('Pendientes', tareas_pendientesList.length.toString(), Colors.orange, Icons.pending_actions)),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // COMPLETED TASKS
                      Row(
                        children: const [
                          Icon(Icons.check_circle, color: Colors.green, size: 20),
                          SizedBox(width: 8),
                          Text('Tareas Realizadas', style: TextStyle(color: Color(0xff060024), fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 15),
                      if (tareas_realizadas == null || (tareas_realizadas as List).isEmpty)
                        _emptyState('Sin tareas realizadas')
                      else
                        ListView.separated(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: (tareas_realizadas as List).length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (ctx, i) {
                            final t = tareas_realizadas[i];
                            DateTime fechaFl = DateTime.parse(t['fecha']).toLocal();
                            String fechaStr = DateFormat('dd-MM-yyyy HH:mm').format(fechaFl.add(const Duration(hours: -2)));
                            DateTime fechaF2 = DateTime.parse(t['fecha_retro']).toLocal();
                            String fechaRetroStr = DateFormat('dd-MM-yyyy HH:mm').format(fechaF2.add(const Duration(hours: -2)));
                            return _taskCard(
                              imageUrl: Api.buildImageUrl(t['imgF']),
                              retroImageUrl: Api.buildImageUrl(t['imgF_retro']),
                              fecha: fechaStr,
                              opcion: t['opcion'],
                              comentario: t['comentario'],
                              isCompleted: true,
                              fechaRetro: fechaRetroStr,
                              comentarioRetro: t['comentario_retro'],
                            );
                          },
                        ),
                      const SizedBox(height: 30),

                      // PENDING TASKS
                      Row(
                        children: const [
                          Icon(Icons.pending_actions, color: Colors.orange, size: 20),
                          SizedBox(width: 8),
                          Text('Tareas Pendientes', style: TextStyle(color: Color(0xff060024), fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 15),
                      if (tareas_pendientes == null || (tareas_pendientes as List).isEmpty)
                        _emptyState('Sin tareas pendientes')
                      else
                        ListView.separated(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: (tareas_pendientes as List).length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (ctx, i) {
                            final t = tareas_pendientes[i];
                            DateTime fechaFl = DateTime.parse(t['fecha']).toLocal();
                            String fechaStr = DateFormat('dd-MM-yyyy').format(fechaFl.add(const Duration(hours: -1)));
                            return _taskCard(
                              imageUrl: Api.buildImageUrl(t['imgF']),
                              fecha: fechaStr,
                              opcion: t['opcion'],
                              comentario: t['comentario'],
                              isCompleted: false,
                            );
                          },
                        ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: const Color(0xff060024),
          selectedItemColor: const Color(0xff007DA4),
          unselectedItemColor: Colors.white60,
          currentIndex: _selectedIndex,
          onTap: (index) {
            if (index == 0 && _selectedIndex == index) Navigator.of(context).pushAndRemoveUntil(HomeScreen.route(''), (r) => false);
            else if (index == 1) logout();
            setState(() => _selectedIndex = index);
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
            BottomNavigationBarItem(icon: Icon(Icons.logout), label: 'Salir'),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 3),
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 10), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _emptyState(String msg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Center(child: Text(msg, style: const TextStyle(color: Colors.grey))),
    );
  }

  Widget _taskCard({
    required String imageUrl,
    String? retroImageUrl,
    required String fecha,
    required String opcion,
    required String comentario,
    required bool isCompleted,
    String? fechaRetro,
    String? comentarioRetro,
  }) {
    final accent = isCompleted ? Colors.green : Colors.orange;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3))],
        border: Border.all(color: accent.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => showDialog(
                    context: context,
                    builder: (ctx) => Dialog(
                      backgroundColor: Colors.transparent,
                      insetPadding: EdgeInsets.zero,
                      child: Stack(
                        children: [
                          PhotoView(
                            imageProvider: NetworkImage(imageUrl),
                            backgroundDecoration: const BoxDecoration(color: Colors.black87),
                            minScale: PhotoViewComputedScale.contained,
                            maxScale: PhotoViewComputedScale.covered * 2.5,
                          ),
                          Positioned(
                            top: 40,
                            right: 12,
                            child: GestureDetector(
                              onTap: () => Navigator.pop(ctx),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                                child: const Icon(Icons.close, color: Colors.white, size: 22),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  child: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(imageUrl, width: 60, height: 80, fit: BoxFit.cover)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 13, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(fecha, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(opcion, style: const TextStyle(color: Color(0xff060024), fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text(comentario, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: accent.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: Text(isCompleted ? 'Realizada' : 'Pendiente', style: TextStyle(color: accent, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            if (isCompleted && fechaRetro != null) ...
            [
              const Divider(height: 20),
              Row(
                children: [
                  if (retroImageUrl != null)
                    GestureDetector(
                      onTap: () => showDialog(
                        context: context,
                        builder: (ctx) => Dialog(
                          backgroundColor: Colors.transparent,
                          insetPadding: EdgeInsets.zero,
                          child: Stack(
                            children: [
                              PhotoView(
                                imageProvider: NetworkImage(retroImageUrl),
                                backgroundDecoration: const BoxDecoration(color: Colors.black87),
                                minScale: PhotoViewComputedScale.contained,
                                maxScale: PhotoViewComputedScale.covered * 2.5,
                              ),
                              Positioned(
                                top: 40,
                                right: 12,
                                child: GestureDetector(
                                  onTap: () => Navigator.pop(ctx),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                                    child: const Icon(Icons.close, color: Colors.white, size: 22),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      child: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(retroImageUrl, width: 50, height: 65, fit: BoxFit.cover)),
                    ),
                  if (retroImageUrl != null) const SizedBox(width: 12),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Retroalimentación', style: TextStyle(color: Colors.grey[500], fontSize: 11, fontWeight: FontWeight.bold)),
                      Text(fechaRetro, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                      if (comentarioRetro != null && comentarioRetro.isNotEmpty)
                        Text(comentarioRetro, style: const TextStyle(color: Color(0xff060024), fontSize: 12)),
                    ],
                  )),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void showModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content: const Text('¿Quieres cerrar la sesión?'),
        actions: <TextButton>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              logout();
            },
            child: const Text('Cerrar sesión'),
          )
        ],
      ),
    );
  }
}
