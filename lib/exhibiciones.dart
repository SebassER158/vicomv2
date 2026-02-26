import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vicomv2/apis/api.dart';
import 'package:vicomv2/asignaciontareas.dart';
import 'package:vicomv2/biscreen.dart';
import 'package:vicomv2/frentes.dart';
import 'package:vicomv2/homescreen.dart';
import 'package:vicomv2/puntoscontrol.dart';
import 'package:vicomv2/tareas.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:vicomv2/widgets/app_drawer.dart';

import 'loginScreen.dart';

class Exhibiciones extends StatefulWidget {
  static Route<dynamic> route(String mensaje) {
    return MaterialPageRoute(
      builder: (context) => Exhibiciones(),
    );
  }

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Exhibiciones> {
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

  late String datao;
  var objetivosList = [];
  var objetivos;
  String objetivo = "";

  late String datae;
  var ejecutadosList = [];
  var ejecutados;
  String ejecutado = "";

  late String dataa;
  var avancesList = [];
  var avances;
  String avance = "";

  late String dataex;
  var exhibicionesList = [];
  var exhibiciones;

  int _selectedIndex = 0;

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
    idTienda = (prefs.getInt('idTienda') ?? 0);
    cuenta = (prefs.getString('cuenta') ?? "");

    try {
      var response2 = await Api().getObjetivosEx(cuenta, idTienda);
      if (response2.statusCode == 200) {
        datao = response2.body; //store response as string
        if (this.mounted) {
          setState(() {
            objetivos = jsonDecode(datao);
            objetivosList = objetivos ?? "[]";

            if (objetivosList.isNotEmpty) {
              objetivo = objetivosList[0]['objetivo'].toString();
            }
          });
        }
      } else {
        print(response2.statusCode);
      }
    } catch (e) {
      print("Error de conexión: $e");
    }

    try {
      var response3 = await Api().getEjecutadoEx(cuenta, idTienda);
      if (response3.statusCode == 200) {
        datae = response3.body; //store response as string
        if (this.mounted) {
          setState(() {
            ejecutados = jsonDecode(datae);
            ejecutadosList = ejecutados ?? "[]";

            if (ejecutadosList.isNotEmpty) {
              ejecutado = (ejecutadosList[0]['ejecutado'] ?? 0).toString();
            }
          });
        }
      } else {
        print(response3.statusCode);
      }
    } catch (e) {
      print("Error de conexión: $e");
    }

    try {
      var response4 = await Api().getAvanceEx(cuenta, idTienda);
      if (response4.statusCode == 200) {
        dataa = response4.body; //store response as string
        if (this.mounted) {
          setState(() {
            avances = jsonDecode(dataa);
            avancesList = avances ?? "[]";

            if (avancesList.isNotEmpty) {
              avance =
                  (avancesList[0]['avance_porcentaje'] ?? 0).toStringAsFixed(2);
            }
          });
        }
      } else {
        print(response4.statusCode);
      }
    } catch (e) {
      print("Error de conexión: $e");
    }

    try {
      var response5 = await Api().getExhibicionesPrueba(cuenta, idTienda);
      if (response5.statusCode == 200) {
        dataex = response5.body; //store response as string
        if (this.mounted) {
          setState(() {
            exhibiciones = jsonDecode(dataex);
            exhibicionesList = exhibiciones ?? "[]";
          });
        }
      } else {
        print(response5.statusCode);
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

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: "Montserrat"),
      home: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.grey[100],
        drawer: AppDrawer(
          onLogout: logout,
          availableModules: availableModules,
        ),
        body: SmartRefresher(
          header: const WaterDropMaterialHeader(
            color: Color(0xff060024),
            backgroundColor: Color(0xff007DA4),
          ),
          onRefresh: _onRefresh,
          controller: _refreshController,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                // --- PREMIUM HEADER ---
                Stack(
                  children: [
                    Container(
                      height: 180,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xff060024), Color(0xff060024)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                    ),
                    Positioned(
                      top: -50,
                      left: -50,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      right: -30,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                                  onPressed: () => Navigator.pop(context),
                                ),
                                const Text(
                                  "Exhibiciones",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Builder(builder: (context) {
                                  return IconButton(
                                    icon: const Icon(Icons.menu, color: Colors.white),
                                    onPressed: () => Scaffold.of(context).openDrawer(),
                                  );
                                }),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // --- CONTENT CONTAINER ---
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // INFO STORE & FORMAT CARD
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildInfoRow(Icons.store, "Tienda", tienda),
                            const Divider(height: 30, color: Colors.grey),
                            _buildInfoRow(Icons.category, "Formato", formato),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // METRICS CARDS ROW
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetricCard("Objetivo", objetivo, const Color(0xff007DA4)),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: _buildMetricCard("Ejecutado", ejecutado, const Color(0xff060024)),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 15),
                      
                      // PROGRESS METRIC (Full Width)
                      _buildMetricCard("Avance Global", "$avance%", Colors.green, isFullWidth: true),

                      const SizedBox(height: 30),

                      // EXHIBICIONES LIST TITLE
                      _buildSectionHeader("Historial de Exhibiciones", Icons.history),
                      const SizedBox(height: 15),

                      // LIST: EXHIBICIONES CARDS
                      (exhibicionesList == null || exhibicionesList.isEmpty)
                          ? Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(30),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const Column(
                                children: [
                                  Icon(Icons.image_not_supported_outlined, size: 50, color: Colors.grey),
                                  SizedBox(height: 10),
                                  Text("No hay exhibiciones registradas", style: TextStyle(color: Colors.grey)),
                                ],
                              ),
                            )
                          : ListView.separated(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: exhibicionesList.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 15),
                              itemBuilder: (BuildContext context, int index) {
                                DateTime fechaFl = DateTime.parse(exhibicionesList[index]['fecha']).toLocal();
                                DateTime nuevaFechaFl = fechaFl.add(const Duration(hours: -1));
                                String fechaString = DateFormat('dd/MM/yyyy HH:mm:ss').format(nuevaFechaFl);
                                
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: Column(
                                        children: [
                                          // CARD HEADER: DATE & TYPE
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                            color: const Color(0xff060024).withOpacity(0.05),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    const Icon(Icons.calendar_today, size: 14, color: Color(0xff060024)),
                                                    const SizedBox(width: 5),
                                                    Text(
                                                      fechaString,
                                                      style: const TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        color: Color(0xff060024),
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xff007DA4),
                                                    borderRadius: BorderRadius.circular(5),
                                                  ),
                                                  child: Text(
                                                    exhibicionesList[index]['tipoexhibicion'],
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.bold
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          
                                          const Divider(height: 1, color: Colors.grey),

                                          // CARD BODY
                                          Padding(
                                            padding: const EdgeInsets.all(15),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                // PHOTO THUMBNAIL
                                                GestureDetector(
                                                  onTap: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (_) => Dialog(
                                                        backgroundColor: Colors.transparent,
                                                        child: PhotoView(
                                                          backgroundDecoration: const BoxDecoration(color: Colors.transparent),
                                                          imageProvider: NetworkImage(
                                                            "http://72.167.33.202${exhibicionesList[index]['fotoF']}",
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  child: Container(
                                                    width: 80,
                                                    height: 100,
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(10),
                                                      border: Border.all(color: Colors.grey.shade300),
                                                      image: DecorationImage(
                                                        image: NetworkImage(
                                                          "http://72.167.33.202${exhibicionesList[index]['fotoF']}",
                                                        ),
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                
                                                const SizedBox(width: 15),
                                                
                                                // DETAILS
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      _buildDetailItem(Icons.category_outlined, "Departamento", exhibicionesList[index]['departamento']),
                                                      const SizedBox(height: 8),
                                                      _buildDetailItem(Icons.label_outline, "Marca", exhibicionesList[index]['marca']),
                                                      const SizedBox(height: 8),
                                                      // _buildDetailItem(Icons.layers_outlined, "Tipo", exhibicionesList[index]['tipoexhibicion']), // Already in header
                                                      _buildDetailItem(Icons.timelapse, "Permanencia", exhibicionesList[index]['permanencia'] ?? "N/A"),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
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
          selectedItemColor: const Color(0xff007DA4), // Cyan active
          unselectedItemColor: Colors.white60,
          currentIndex: _selectedIndex,
          onTap: (int index) {
            switch (index) {
              case 0:
                if (_selectedIndex == index) {
                  Navigator.of(context).pushAndRemoveUntil(
                      HomeScreen.route(""), (route) => false);
                }
                break;
              case 1:
                logout(); // Changed to match previous logic (case 1 was logout, though icon was different)
                break;
            }
            setState(() {
              _selectedIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.logout),
              label: 'Cerrar Sesión',
            ),
          ],
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xff007DA4).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xff007DA4)),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xff060024),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String label, String value, Color color, {bool isFullWidth = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      // width: isFullWidth ? double.infinity : null,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xff007DA4), size: 20),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xff060024),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontFamily: "Montserrat", color: Colors.black87, fontSize: 13),
              children: [
                TextSpan(text: "$title: ", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                TextSpan(text: value, style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ],
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
