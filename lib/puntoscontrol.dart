import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vicomv2/apis/api.dart';
import 'package:vicomv2/asignaciontareas.dart';
import 'package:vicomv2/biscreen.dart';
import 'package:vicomv2/exhibiciones.dart';
import 'package:vicomv2/frentes.dart';
import 'package:vicomv2/homescreen.dart';
import 'package:vicomv2/tareas.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:vicomv2/widgets/app_drawer.dart';

import 'loginScreen.dart';

class PuntosControl extends StatefulWidget {
  static Route<dynamic> route(String mensaje) {
    return MaterialPageRoute(
      builder: (context) => PuntosControl(),
    );
  }

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<PuntosControl> {
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

  late String datapce;
  var pcEjecutadosList = [];
  var pcEjecutado;

  late String datapcp;
  var pcPendienteList = [];
  var pcPendiente;

  int _selectedIndex = 0;
  final ScrollController _homeController = ScrollController();

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
    SharedPreferences prefs1 = await SharedPreferences.getInstance();

    try {
      var response2 = await Api().getObjetivosPc(cuenta, idTienda);
      if (response2.statusCode == 200) {
        datao = response2.body; //store response as string
        if (this.mounted) {
          setState(() {
            objetivos = jsonDecode(datao);
            objetivosList = objetivos ?? "[]";

            if (objetivosList.isNotEmpty) {
              objetivo = objetivosList[0]['total_registros'].toString();
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
      var response3 = await Api().getEjecutadoPc(cuenta, idTienda);
      if (response3.statusCode == 200) {
        datae = response3.body; //store response as string
        if (this.mounted) {
          setState(() {
            ejecutados = jsonDecode(datae);
            ejecutadosList = ejecutados ?? "[]";

            if (ejecutadosList.isNotEmpty) {
              ejecutado =
                  (ejecutadosList[0]['total_registros'] ?? 0).toString();
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
      var response4 = await Api().getAvancePc(cuenta, idTienda);
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
      var response5 = await Api().getPcEjecutado(cuenta, idTienda);
      if (response5.statusCode == 200) {
        datapce = response5.body; //store response as string
        if (this.mounted) {
          setState(() {
            pcEjecutado = jsonDecode(datapce);
            pcEjecutadosList = pcEjecutado ?? "[]";
          });
        }
      } else {
        print(response5.statusCode);
      }
    } catch (e) {
      print("Error de conexión: $e");
    }

    try {
      var response6 = await Api().getPcPendiente(cuenta, idTienda);
      if (response6.statusCode == 200) {
        datapcp = response6.body; //store response as string
        if (this.mounted) {
          setState(() {
            pcPendiente = jsonDecode(datapcp);
            pcPendienteList = pcPendiente ?? "[]";
          });
        }
      } else {
        print(response6.statusCode);
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
      theme: ThemeData(
        fontFamily: "Montserrat",
      ),
      home: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.grey[100], // Light background for content contrast
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
                                  "Puntos de Control",
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

                      // LIST: EJECUTADOS
                      _buildSectionHeader("Puntos de Control Ejecutados", Icons.check_circle_outline),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0,2))],
                        ),
                        child: (pcEjecutadosList == null || pcEjecutadosList.isEmpty)
                            ? const Padding(
                                padding: EdgeInsets.all(20),
                                child: Text("No hay registros", style: TextStyle(color: Colors.grey)),
                              )
                            : ListView.separated(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: pcEjecutadosList.length,
                                separatorBuilder: (context, index) => const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    leading: const Icon(Icons.check, color: Colors.green),
                                    title: Text(
                                      pcEjecutadosList[index]['opcion'],
                                      style: const TextStyle(
                                        fontFamily: "Montserrat",
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),

                      const SizedBox(height: 30),

                      // LIST: PENDIENTES
                      _buildSectionHeader("Puntos de Control Pendientes", Icons.pending_actions),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0,2))],
                        ),
                        child: (pcPendienteList == null || pcPendienteList.isEmpty)
                            ? const Padding(
                                padding: EdgeInsets.all(20),
                                child: Text("No hay pendientes", style: TextStyle(color: Colors.grey)),
                              )
                            : ListView.separated(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: pcPendienteList.length,
                                separatorBuilder: (context, index) => const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    leading: Icon(Icons.circle_outlined, color: Colors.orange[400]),
                                    title: Text(
                                      pcPendienteList[index]['opcion'],
                                      style: const TextStyle(
                                        fontFamily: "Montserrat",
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    ),
                                  );
                                },
                              ),
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
                logout(); // Changed to match previous logic (case 1 was login/logout)
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
