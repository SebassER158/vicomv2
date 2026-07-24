import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vicomv2/widgets/app_drawer.dart';
import 'package:vicomv2/widgets/app_bottom_nav_bar.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'loginScreen.dart';

class BiScreen extends StatefulWidget {
  const BiScreen({super.key});

  static Route<dynamic> route(String mensaje) {
    return MaterialPageRoute(
      builder: (context) => const BiScreen(),
    );
  }

  @override
  BiScreenState createState() => BiScreenState();
}

class BiScreenState extends State<BiScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
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

  var controller;

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
    setState(() {
      controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0x00000000))
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {
              // Update loading bar.
            },
            onPageStarted: (String url) {},
            onPageFinished: (String url) {},
            onWebResourceError: (WebResourceError error) {},
            onNavigationRequest: (NavigationRequest request) {
              if (request.url.startsWith(
                  'https://app.powerbi.com/view?r=eyJrIjoiMWIzZDZmMjAtZGU4MC00YWQwLWJmNTUtOWI1MTRjYmI0MjhlIiwidCI6IjUzMjIxMjc5LTkzMWQtNGUwNy04OTBkLTlhOGE0NDgxMTM2NyJ9')) {
                return NavigationDecision.prevent;
              }
              return NavigationDecision.navigate;
            },
          ),
        )
        ..loadRequest(Uri.parse(
            'https://app.powerbi.com/view?r=eyJrIjoiMWIzZDZmMjAtZGU4MC00YWQwLWJmNTUtOWI1MTRjYmI0MjhlIiwidCI6IjUzMjIxMjc5LTkzMWQtNGUwNy04OTBkLTlhOGE0NDgxMTM2NyJ9'));
    });
  }

  void logout() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove("logueado");
    // "nip" identifica al usuario (se guarda en Iniciosesion) y lo usa
    // TareasGlobal; no debe borrarse al solo cambiar de tienda.
    await preferences.remove("id_sucursal");
    await preferences.remove("usuario");
    await preferences.remove("id_usuario");
    await preferences.remove("alias");

    // await preferences.clear();
    //Navigator.of(context).push(LoginS.route("mensaje"));
    Navigator.of(context).pushReplacement(LoginScreen.route());
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
      home: Scaffold(
        key: _scaffoldKey,
        drawer: AppDrawer(
          onLogout: logout,
          availableModules: availableModules,
        ),
        // body: WebViewWidget(controller: controller),
        body: Container(
            child: Column(
          children: [
            Container(
              color: const Color(0xff060024),
              padding: const EdgeInsets.only(
                  top: 30, left: 20, right: 20, bottom: 30),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Builder(builder: (context) {
                    return GestureDetector(
                      onTap: () {
                        Scaffold.of(context).openDrawer();
                      },
                      child: Image.asset(
                        "assets/logo_modulo.png",
                        scale: 5,
                      ),
                    );
                  }),
                  Container(
                    margin: const EdgeInsets.only(left: 10),
                    child: const Text(
                      "BI",
                      style: TextStyle(
                          fontFamily: "Montserrat",
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 22),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: WebViewWidget(controller: controller),
            ),
          ],
        )),
        bottomNavigationBar: AppBottomNavBar(
          currentIndex: _selectedIndex,
          onIndexChanged: (index) => setState(() => _selectedIndex = index),
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
