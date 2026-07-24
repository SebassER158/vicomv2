import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vicomv2/apis/api.dart';
import 'package:intl/intl.dart';
import 'package:search_choices/search_choices.dart';
import 'package:vicomv2/asignaciontareas.dart';
import 'package:vicomv2/biscreen.dart';
import 'package:vicomv2/exhibiciones.dart';
import 'package:vicomv2/frentes.dart';
import 'package:vicomv2/providers/modules_provider.dart';
import 'package:vicomv2/puntoscontrol.dart';
import 'package:vicomv2/services/tareas_badge_controller.dart';
import 'package:vicomv2/tareas.dart';
import 'package:photo_view/photo_view.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart' hide RefreshIndicator;
import 'package:vicomv2/widgets/app_drawer.dart';
import 'package:vicomv2/widgets/app_bottom_nav_bar.dart';

import 'loginScreen.dart';

class HomeScreen extends StatefulWidget {
  static Route<dynamic> route(String mensaje) {
    return MaterialPageRoute(
      builder: (context) => HomeScreen(),
    );
  }

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  late String datauv;
  var ultimaVisitaList = [];
  var ultimaVisita;
  int idTienda = 0;
  String cuenta = "";
  String tienda = "";
  String formato = "";
  String numero = "";
  String cadena = "";
  String fechaInicial = "";
  String perfil = "";
  String userCeys = "";
  String nombreUsuario = "";
  String nombreUltimaVisita = "";
  String saludo = "Hola,";
  String fecha_cadena = "";

  late String datatv;
  var totalVisitasList = [];
  var totalVisitas;
  String totalvis = "";

  late String dataet;
  var estadiaTiendaList = [];
  var estadiaTienda;
  String total_horas_et = "";

  late String datate;
  var totalEstadiaList = [];
  var totalEstadia;
  String total_horas_te = "";

  late String datatvd;
  var totalVisitasdList = [];
  var totalVisitasd;

  late String datacv;
  var cumplimientoVisitaList = [];
  var cumplimientoVisita;
  String cumplimiento_visita = "0";

  late String datadpc;
  var datosPuntosControlList = [];
  var datosPuntosControl;
  String total_registros_control = "";
  String total_registros_control_join = "";
  String avance_porcentaje_dpc = "0";

  late String datade;
  var datosExhibicionList = [];
  var datosExhibicion;
  String total_objetivo_de = "";
  String total_ejecutado_de = "";
  String avance_porcentaje_de = "0";

  late String datadl;
  var datosLinealList = [];
  var datosLineal;
  String total_objetivo_dl = "";
  String total_ejecutado_dl = "";
  String avance_porcentaje_dl = "0";

  late String dataso;
  var datosSoList = [];
  var datosSo;
  String porcentaje_avance_so = "0";

  String? selectedValueSingleDialog;
  String _tienda = "";
  var tiendas2;

  bool loading = false;
  bool _isVisible = false;
  bool _isVisible_de = false;
  bool _isVisible_dl = false;

  int _selectedIndex = 0;

  String deviceModel = 'Unknown';

  bool _isSwitched = false;
  bool _isLoading = true;

  double latitude = 0.0;
  double longitude = 0.0;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  Map<String, bool> availableModules = {};
  bool loadingModules = true;

  @override
  void initState() {
    super.initState();
    loginState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await loadModules();
      getData();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Cargando módulos...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _getDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Theme.of(context).platform == TargetPlatform.android) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      setState(() {
        deviceModel = androidInfo.model;
      });
    } else if (Theme.of(context).platform == TargetPlatform.iOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      setState(() {
        deviceModel = iosInfo.utsname.machine;
      });
    }

    final prefs = await SharedPreferences.getInstance();
    final lastSavedDate = prefs.getString('last_saved_date') ?? '';

    final today = DateTime.now();
    final todayString = '${today.year}-${today.month}-${today.day}';

    if (lastSavedDate != todayString) {
      var res_mod = await Api().saveModelos(cuenta, 0, deviceModel);
      if (res_mod.statusCode == 200) {
        await prefs.setString('last_saved_date', todayString);
      }
    }

    print("La version es $deviceModel");
  }

  void loginState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      idTienda = (prefs.getInt('idTienda') ?? 0);
      cuenta = (prefs.getString('cuenta') ?? "");
      tienda = (prefs.getString('tienda') ?? "");
      formato = (prefs.getString('formato') ?? "");
      numero = (prefs.getString('numero') ?? "");
      cadena = (prefs.getString('cadena') ?? "");
      nombreUsuario = (prefs.getString('nombre') ?? "");
    });
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

  bool hasModule(String key) {
    return availableModules[key] == true;
  }

  void getData({bool showLoading = true}) async {
    if (showLoading) {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }
    }

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      
      String currentCuenta = prefs.getString('cuenta') ?? "";
      int currentIdTienda = prefs.getInt('idTienda') ?? 0;
      String currentCadena = prefs.getString('cadena') ?? "";
      String currentNumero = prefs.getString('numero') ?? "";
      
      if (mounted) {
          setState(() {
              cuenta = currentCuenta;
              idTienda = currentIdTienda;
              cadena = currentCadena;
              numero = currentNumero;
          });
      }

      List<Future> futures = [];

      // 1. Fecha Cadena
      futures.add(Future(() async {
        try {
          var responsefc = await Api().getFechaCadena(currentCuenta, currentCadena);
          if (responsefc.statusCode == 200) {
            String respuesta = responsefc.body;
            var datafc = jsonDecode(respuesta);
            DateTime fechaF = DateTime.parse(datafc[0]["fecha"]).toLocal();
            if (mounted) {
              setState(() {
                fecha_cadena = DateFormat('dd-MM-yyyy').format(fechaF);
              });
            }
          }
        } catch (e) {
          print("Error fecha cadena: $e");
        }
      }));

      // 2. Tiendas
      futures.add(Future(() async {
        try {
          var response = await Api().getValoresTabla(currentCuenta, "tiendas");
          if (response.statusCode == 200) {
            String respuesta = response.body;
            if (mounted) {
              setState(() {
                tiendas2 = jsonDecode(respuesta);
              });
            }
          }
        } catch (e) {
          print("Error tiendas: $e");
        }
      }));

      // 3. Ultima Visita
      futures.add(Future(() async {
        try {
          var response = await Api().getUltimaVisita(currentCuenta, currentIdTienda);
          if (response.statusCode == 200) {
            if (mounted) {
              setState(() {
                datauv = response.body;
                ultimaVisita = jsonDecode(datauv);
                ultimaVisitaList = ultimaVisita ?? [];

                if (ultimaVisitaList.isNotEmpty) {
                  DateTime fechaF = DateTime.parse(ultimaVisita[0]['fecha_i']).toLocal();
                  DateTime nuevaFechaF = fechaF.add(const Duration(hours: -2));
                  fechaInicial = DateFormat('dd-MM-yyyy HH:mm:ss').format(nuevaFechaF);
                  userCeys = ultimaVisita[0]['userCeys'] ?? "";
                  perfil = ultimaVisita[0]['perfil'];
                  nombreUltimaVisita = ultimaVisita[0]['nombre_usuario'] ?? "";
                }
              });
            }
          }
        } catch (e) {
          print("Error ultima visita: $e");
        }
      }));

      // 4. Total Visitas
      futures.add(Future(() async {
        try {
          var response2 = await Api().getTotalVisitas(currentCuenta, currentIdTienda);
          if (response2.statusCode == 200) {
            if (mounted) {
              setState(() {
                datatv = response2.body;
                totalVisitas = jsonDecode(datatv);
                totalVisitasList = totalVisitas ?? [];
                if (totalVisitasList.isNotEmpty) {
                  totalvis = totalVisitasList[0]['total'].toString();
                }
              });
            }
          }
        } catch (e) {
           print("Error total visitas: $e");
        }
      }));

      // 5. Estadia Tienda
      futures.add(Future(() async {
        try {
          var response3 = await Api().getEstadiaTienda(currentCuenta, currentIdTienda);
          if (response3.statusCode == 200) {
            if (mounted) {
              setState(() {
                dataet = response3.body;
                estadiaTienda = jsonDecode(dataet);
                estadiaTiendaList = estadiaTienda ?? [];
                if (estadiaTiendaList.isNotEmpty) {
                  total_horas_et = estadiaTiendaList[0]['total_horas'];
                }
              });
            }
          }
        } catch (e) {
          print("Error estadia tienda: $e");
        }
      }));

      // 6. Total Estadia
      futures.add(Future(() async {
        try {
          var response4 = await Api().getTotalEstadia(currentCuenta, currentIdTienda);
          if (response4.statusCode == 200) {
            if (mounted) {
              setState(() {
                datate = response4.body;
                totalEstadia = jsonDecode(datate);
                totalEstadiaList = totalEstadia ?? [];
                if (totalEstadiaList.isNotEmpty) {
                  total_horas_te = totalEstadiaList[0]['total_horas'];
                }
              });
            }
          }
        } catch (e) {
          print("Error total estadia: $e");
        }
      }));

      // 7. Total Visitas Detalle
      futures.add(Future(() async {
        try {
          var response5 = await Api().getTotalVisitasDetalle(currentCuenta, currentIdTienda);
          if (response5.statusCode == 200) {
            if (mounted) {
              setState(() {
                datatvd = response5.body;
                totalVisitasd = jsonDecode(datatvd);
                totalVisitasdList = totalVisitasd ?? [];
              });
            }
          }
        } catch (e) {
          print("Error total visitas detalle: $e");
        }
      }));

      // 8. Cumplimiento Visitas (Condicional)
      if (hasModule('cumplimiento_visitas')) {
        futures.add(Future(() async {
          try {
            var response6 = await Api().getCumplimientoVisita(currentCuenta, currentIdTienda);
            if (response6.statusCode == 200) {
              if (mounted) {
                setState(() {
                  datacv = response6.body;
                  cumplimientoVisita = jsonDecode(datacv);
                  cumplimientoVisitaList = cumplimientoVisita ?? [];
                  cumplimiento_visita = (cumplimientoVisitaList[0]['porcentaje_cumplimiento'] ?? 0).toStringAsFixed(2);
                });
              }
            }
          } catch (e) {
            print("Error cumplimiento visitas: $e");
          }
        }));
      }

      // 9. Puntos Control (Condicional)
      if (hasModule('puntos_control')) {
        futures.add(Future(() async {
          try {
            var response7 = await Api().getDatosPuntosControl(currentCuenta, currentIdTienda);
            if (response7.statusCode == 200) {
              if (mounted) {
                setState(() {
                  datadpc = response7.body;
                  datosPuntosControl = jsonDecode(datadpc);
                  datosPuntosControlList = datosPuntosControl ?? [];
                  total_registros_control = (datosPuntosControlList[0]['total_registros_control'] ?? 0).toString();
                  total_registros_control_join = (datosPuntosControlList[0]['total_registros_control_join'] ?? 0).toString();
                  avance_porcentaje_dpc = (datosPuntosControlList[0]['avance_porcentaje'] ?? 0).toStringAsFixed(2);
                });
              }
            }
          } catch (e) {
            print("Error puntos control: $e");
          }
        }));
      }

      // 10. Exhibiciones (Condicional)
      if (hasModule('exhibiciones')) {
        futures.add(Future(() async {
          try {
            var response8 = await Api().getDatosExhibicion(currentCuenta, currentIdTienda);
            if (response8.statusCode == 200) {
              if (mounted) {
                setState(() {
                  datade = response8.body;
                  datosExhibicion = jsonDecode(datade);
                  datosExhibicionList = datosExhibicion ?? [];
                  total_objetivo_de = (datosExhibicionList[0]['total_objetivo'] ?? 0).toString();
                  total_ejecutado_de = (datosExhibicionList[0]['total_ejecutado'] ?? 0).toString();
                  avance_porcentaje_de = (datosExhibicionList[0]['avance_porcentaje'] ?? 0).toStringAsFixed(2);
                });
              }
            }
          } catch (e) {
            print("Error exhibiciones: $e");
          }
        }));
      }

      // 11. Lineal (Condicional)
      if (hasModule('lineal')) {
        futures.add(Future(() async {
          try {
            var response9 = await Api().getDatosLineal(currentCuenta, currentIdTienda);
            if (response9.statusCode == 200) {
              if (mounted) {
                setState(() {
                  datadl = response9.body;
                  datosLineal = jsonDecode(datadl);
                  datosLinealList = datosLineal ?? [];
                  total_objetivo_dl = (datosLinealList[0]['total_objetivo'] ?? 0).toString();
                  total_ejecutado_dl = (datosLinealList[0]['total_ejecutado'] ?? 0).toString();
                  avance_porcentaje_dl = (datosLinealList[0]['avance_porcentaje'] ?? 0).toStringAsFixed(2);
                });
              }
            }
          } catch (e) {
            print("Error lineal: $e");
          }
        }));
      }

      // 12. SO (Condicional)
      if (hasModule('so')) {
        futures.add(Future(() async {
          try {
            int numeroInt = int.tryParse(currentNumero) ?? 0;
            var response10 = await Api().getDatosSo(currentCuenta, currentCadena, numeroInt);
            if (response10.statusCode == 200) {
              if (mounted) {
                setState(() {
                  dataso = response10.body;
                  datosSo = jsonDecode(dataso);
                  datosSoList = datosSo ?? [];
                  porcentaje_avance_so = (datosSo[0]['porcentaje_avance'] ?? 0).toStringAsFixed(2);
                });
              }
            }
          } catch (e) {
            print("Error SO: $e");
          }
        }));
      }

      // 13. Badge de tareas realizadas (Condicional)
      if (hasModule('tareas_asignadas')) {
        futures.add(TareasBadgeController.instance.refreshPorTienda());
      }

      await Future.wait(futures);

    } catch (e) {
      print("Error general en getData: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future setTienda(tiendaul) async {
    print(tiendaul);
    var tiendasep = tiendaul.split("--");
    int idTienda = int.parse(tiendasep[0]);
    String tienda = tiendasep[1];
    String formato = tiendasep[2];
    String numero = tiendasep[3].toString();
    String cadena = tiendasep[4];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('tienda', tienda);
    await prefs.setString('formato', formato);
    await prefs.setString('numero', numero);
    await prefs.setString('cadena', cadena);
    await prefs.setInt('idTienda', idTienda);
    Navigator.of(context)
        .pushAndRemoveUntil(HomeScreen.route(""), (route) => false);
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

  void _onRefresh() async {
    getData(showLoading: false);
    // _refreshController.refreshCompleted(); // Not using SmartRefresher anymore
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check if initialized
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        key: _scaffoldKey,
        drawer: AppDrawer(
          onLogout: logout,
          availableModules: availableModules,
        ),
        body: Stack(
          children: [
            Column(
              children: [
                Container(
                  color: const Color(0xff060024),
                  padding: const EdgeInsets.only(
                      top: 40, left: 20, right: 20, bottom: 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Builder(builder: (context) {
                        return GestureDetector(
                          onTap: () {
                            Scaffold.of(context).openDrawer();
                          },
                          child: Image.asset(
                            "assets/logo_modulo.png",
                            height: 35,
                          ),
                        );
                      }),
                      Expanded(child: Container()),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            saludo,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: "Montserrat"),
                          ),
                          Text(
                            nombreUsuario,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: "Montserrat",
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      _onRefresh();
                    },
                    color: const Color(0xff007DA4),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          
                          // Premium Geolocator Switch
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
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
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xff007DA4).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(Icons.location_on, color: Color(0xff007DA4)),
                                    ),
                                    const SizedBox(width: 15),
                                    const Text("Geolocalización",
                                        style: TextStyle(
                                          fontFamily: "Montserrat",
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Color(0xff060024),
                                        )),
                                  ],
                                ),
                                Switch(
                                  value: _isSwitched,
                                  activeColor: const Color(0xff007DA4),
                                  onChanged: (value) {
                                    setState(() {
                                      _isSwitched = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 15),
                          
                          // Premium Store Dropdown
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
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
                              border: Border.all(
                                color: const Color(0xff007DA4).withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: SearchChoices.single(
                              dropDownDialogPadding: const EdgeInsets.all(10),
                              underline: Container(), // Remove default underline
                              displayClearIcon: false, // Cleaner look
                              icon: const Icon(Icons.arrow_drop_down_circle, color: Color(0xff007DA4)),
                              isExpanded: true,
                              hint: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Text("Selecciona una tienda", style: TextStyle(fontFamily: "Montserrat", fontSize: 14)),
                              ),
                              style: const TextStyle(
                                fontFamily: "Montserrat",
                                fontSize: 16,
                                color: Color(0xff060024),
                                fontWeight: FontWeight.bold
                              ),
                              futureSearchFn: (String? searchQuery,
                                  String? selectedItem,
                                  bool? sortedBy,
                                  List<Tuple2<String, String>>? searchList,
                                  int? maxLength) async {
                                return await _obtenerTiendas(searchQuery,
                                    selectedItem, sortedBy, searchList, maxLength);
                              },
                              value: selectedValueSingleDialog,
                              onChanged: (value) {
                                setState(() {
                                  if (value != null) {
                                    var tiendasep = value.split("--");
                                    selectedValueSingleDialog =
                                        tiendasep.length > 1 ? tiendasep[1] : value;
                                    _tienda = value;
                                  }
                                });
                              },
                            ),
                          ),
                          
                          const SizedBox(height: 15),
                          
                          // Premium Ver Detalles Button
                          GestureDetector(
                            onTap: () {
                              if (_tienda.isNotEmpty) {
                                setTienda(_tienda);
                              }
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 20),
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xff060024), Color(0xff007DA4)],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(15.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xff007DA4).withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                "VER DETALLES",
                                style: TextStyle(
                                  fontFamily: "Montserrat",
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          _buildPremiumInfoCard(
                            title: "Información de Tienda",
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Formato:",
                                      style: TextStyle(
                                          fontFamily: "Montserrat",
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                  Expanded(
                                      child: Text("$formato $numero",
                                          textAlign: TextAlign.end,
                                          style: const TextStyle(
                                              fontFamily: "Montserrat",
                                              fontSize: 16))),
                                ],
                              ),
                              const Divider(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Tienda:",
                                      style: TextStyle(
                                          fontFamily: "Montserrat",
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                  Expanded(
                                      child: Text(tienda,
                                          textAlign: TextAlign.end,
                                          style: const TextStyle(
                                              fontFamily: "Montserrat",
                                              fontSize: 16))),
                                ],
                              ),
                              const Divider(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("S.O al día:",
                                      style: TextStyle(
                                          fontFamily: "Montserrat",
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                  Text("$fecha_cadena",
                                      style: const TextStyle(
                                          fontFamily: "Montserrat",
                                          fontSize: 16)),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _buildPremiumInfoCard(
                            title: "Detalle de Visita",
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Última visita:",
                                      style: TextStyle(
                                          fontFamily: "Montserrat",
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                  Text(fechaInicial,
                                      style: const TextStyle(
                                          fontFamily: "Montserrat",
                                          fontSize: 16)),
                                ],
                              ),
                              const Divider(height: 20),
                              const Text("Visitada por:",
                                  style: TextStyle(
                                      fontFamily: "Montserrat",
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              const SizedBox(height: 6),
                              Center(
                                child: Text(perfil,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontFamily: "Montserrat",
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16))),
                              Center(
                                child: Text(nombreUltimaVisita,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontFamily: "Montserrat",
                                        fontSize: 16))),
                              Center(
                                child: Text(userCeys,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontFamily: "Montserrat",
                                        fontSize: 16))),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _buildPremiumInfoCard(
                            title: "Resumen de Actividad",
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Permanencia en tienda:",
                                      style: TextStyle(
                                          fontFamily: "Montserrat",
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                  Text(total_horas_et,
                                      style: const TextStyle(
                                          fontFamily: "Montserrat",
                                          fontSize: 16)),
                                ],
                              ),
                              const Divider(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Total visitas mes:",
                                      style: TextStyle(
                                          fontFamily: "Montserrat",
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                  Text(totalvis,
                                      style: const TextStyle(
                                          fontFamily: "Montserrat",
                                          fontSize: 16)),
                                ],
                              ),
                              const Divider(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Tiempo total mes:",
                                      style: TextStyle(
                                          fontFamily: "Montserrat",
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                  Text(total_horas_te,
                                      style: const TextStyle(
                                          fontFamily: "Montserrat",
                                          fontSize: 16)),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          if (hasModule('so') || 
                              hasModule('cumplimiento_visitas') || 
                              hasModule('puntos_control') || 
                              hasModule('exhibiciones') || 
                              hasModule('lineal'))
                          _buildPremiumInfoCard(
                            title: "Auditoría en Tienda",
                            children: [
                              
                              if (hasModule('so')) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 5),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const Expanded(
                                        flex: 4,
                                        child: Text(
                                          "SO:",
                                          style: TextStyle(
                                              fontFamily: "Montserrat",
                                              fontSize: 16),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 6,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "$porcentaje_avance_so%",
                                              style: const TextStyle(
                                                  fontFamily: "Montserrat",
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16),
                                            ),
                                            Text(
                                              "${(double.parse(porcentaje_avance_so.isEmpty ? "0" : porcentaje_avance_so) * 0.8).toStringAsFixed(2)}%",
                                              style: const TextStyle(
                                                  fontFamily: "Montserrat",
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey,
                                                  fontSize: 14),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(),
                              ],

                              if (hasModule('cumplimiento_visitas')) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 5),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const Expanded(
                                        flex: 6,
                                        child: Text(
                                          "Cumplimiento de visita:",
                                          style: TextStyle(
                                              fontFamily: "Montserrat",
                                              fontSize: 16),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 4,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "$cumplimiento_visita%",
                                              style: const TextStyle(
                                                  fontFamily: "Montserrat",
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16),
                                            ),
                                            const Text(
                                              "",
                                              style: TextStyle(
                                                  fontFamily: "Montserrat",
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(),
                              ],

                              if (hasModule('puntos_control')) ...[
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isVisible = !_isVisible;
                                    });
                                  },
                                  child: Container(
                                    color: Colors.transparent, // Hit test behavior
                                    padding: const EdgeInsets.symmetric(vertical: 5),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 6,
                                          child: Row(
                                            children: [
                                              const Flexible(
                                                child: Text(
                                                  "Puntos de control:",
                                                  style: TextStyle(
                                                      fontFamily: "Montserrat",
                                                      fontSize: 16),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Icon(
                                                _isVisible ? Icons.expand_less : Icons.expand_more,
                                                color: const Color(0xff007DA4),
                                              )
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 4,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "$avance_porcentaje_dpc%",
                                                style: const TextStyle(
                                                    fontFamily: "Montserrat",
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16),
                                              ),
                                              Text(
                                                "${(double.parse(avance_porcentaje_dpc.isEmpty ? "0" : avance_porcentaje_dpc) * 0.06).toStringAsFixed(2)}%",
                                                style: const TextStyle(
                                                    fontFamily: "Montserrat",
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.grey,
                                                    fontSize: 14),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                AnimatedCrossFade(
                                  firstChild: Container(),
                                  secondChild: Container(
                                    color: const Color(0xfff5f5f5),
                                    padding: const EdgeInsets.all(10),
                                    margin: const EdgeInsets.only(bottom: 10),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text("Objetivo:", style: TextStyle(fontFamily: "Montserrat")),
                                            Text(total_registros_control, style: const TextStyle(fontFamily: "Montserrat", fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                        const SizedBox(height: 5),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text("Ejecutado:", style: TextStyle(fontFamily: "Montserrat")),
                                            Text(total_registros_control_join, style: const TextStyle(fontFamily: "Montserrat", fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  crossFadeState: _isVisible ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                                  duration: const Duration(milliseconds: 300),
                                ),
                                const Divider(),
                              ],

                              if (hasModule('exhibiciones')) ...[
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isVisible_de = !_isVisible_de;
                                    });
                                  },
                                  child: Container(
                                    color: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(vertical: 5),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 5,
                                          child: Row(
                                            children: [
                                              const Flexible(
                                                child: Text(
                                                  "Exhibiciones:",
                                                  style: TextStyle(
                                                      fontFamily: "Montserrat",
                                                      fontSize: 16),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Icon(
                                                _isVisible_de ? Icons.expand_less : Icons.expand_more,
                                                color: const Color(0xff007DA4),
                                              )
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 5,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "$avance_porcentaje_de%",
                                                style: const TextStyle(
                                                    fontFamily: "Montserrat",
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16),
                                              ),
                                              Text(
                                                "${(double.parse(avance_porcentaje_de.isEmpty ? "0" : avance_porcentaje_de) * 0.1).toStringAsFixed(2)}%",
                                                style: const TextStyle(
                                                    fontFamily: "Montserrat",
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.grey,
                                                    fontSize: 14),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                AnimatedCrossFade(
                                  firstChild: Container(),
                                  secondChild: Container(
                                    color: const Color(0xfff5f5f5),
                                    padding: const EdgeInsets.all(10),
                                    margin: const EdgeInsets.only(bottom: 10),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text("Objetivo:", style: TextStyle(fontFamily: "Montserrat")),
                                            Text(total_objetivo_de, style: const TextStyle(fontFamily: "Montserrat", fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                        const SizedBox(height: 5),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text("Ejecutado:", style: TextStyle(fontFamily: "Montserrat")),
                                            Text(total_ejecutado_de, style: const TextStyle(fontFamily: "Montserrat", fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  crossFadeState: _isVisible_de ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                                  duration: const Duration(milliseconds: 300),
                                ),
                                const Divider(),
                              ],

                              if (hasModule('lineal')) ...[
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isVisible_dl = !_isVisible_dl;
                                    });
                                  },
                                  child: Container(
                                    color: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(vertical: 5),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 4,
                                          child: Row(
                                            children: [
                                              const Flexible(
                                                child: Text(
                                                  "Lineal:",
                                                  style: TextStyle(
                                                      fontFamily: "Montserrat",
                                                      fontSize: 16),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Icon(
                                                _isVisible_dl ? Icons.expand_less : Icons.expand_more,
                                                color: const Color(0xff007DA4),
                                              )
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 6,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "$avance_porcentaje_dl%",
                                                style: const TextStyle(
                                                    fontFamily: "Montserrat",
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16),
                                              ),
                                              Text(
                                                "${(double.parse(avance_porcentaje_dl.isEmpty ? "0" : avance_porcentaje_dl) * 0.04).toStringAsFixed(2)}%",
                                                style: const TextStyle(
                                                    fontFamily: "Montserrat",
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.grey,
                                                    fontSize: 14),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                AnimatedCrossFade(
                                  firstChild: Container(),
                                  secondChild: Container(
                                    color: const Color(0xfff5f5f5),
                                    padding: const EdgeInsets.all(10),
                                    margin: const EdgeInsets.only(bottom: 10),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text("Objetivo:", style: TextStyle(fontFamily: "Montserrat")),
                                            Text(total_objetivo_dl, style: const TextStyle(fontFamily: "Montserrat", fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                        const SizedBox(height: 5),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text("Ejecutado:", style: TextStyle(fontFamily: "Montserrat")),
                                            Text(total_ejecutado_dl, style: const TextStyle(fontFamily: "Montserrat", fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  crossFadeState: _isVisible_dl ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                                  duration: const Duration(milliseconds: 300),
                                ),
                                const Divider(),
                              ],

                              // Total Avance
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const Expanded(
                                      child: Text(
                                        "Avance:",
                                        style: TextStyle(
                                            fontFamily: "Montserrat",
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color: Color(0xff007DA4)),
                                      ),
                                    ),
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            "${((double.parse(porcentaje_avance_so.isEmpty ? "0" : porcentaje_avance_so) * 0.8) + (double.parse(avance_porcentaje_dpc.isEmpty ? "0" : avance_porcentaje_dpc) * 0.06) + (double.parse(avance_porcentaje_de.isEmpty ? "0" : avance_porcentaje_de) * 0.1) + (double.parse(avance_porcentaje_dl.isEmpty ? "0" : avance_porcentaje_dl) * 0.04)).toStringAsFixed(2)}%",
                                            style: const TextStyle(
                                                fontFamily: "Montserrat",
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 10),
                          const Divider(
                            color: Color(0xff007DA4),
                            thickness: 1,
                          ),
                          const SizedBox(height: 10),
                          _buildVisitasTable(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xff007DA4),
                  ),
                ),
              ),
          ],
        ),
        bottomNavigationBar: AppBottomNavBar(
          currentIndex: _selectedIndex,
          onIndexChanged: (index) {
            if (mounted) {
              setState(() => _selectedIndex = index);
            }
          },
        ),
      ),
    );
  }

  Future<Tuple2<List<DropdownMenuItem<String>>, int>> _obtenerTiendas(
      String? searchQuery,
      String? selectedItem,
      bool? sortedBy,
      List<Tuple2<String, String>>? searchList,
      int? maxLength) async {
    List<DropdownMenuItem<String>> resultados = [];

    // tiendas2.forEach((element) {
    //   String tienda =
    //       "${element['id']}--${element['tienda']}--${element['formato']} ${element['numero']}";
    //   if (tienda.toUpperCase().contains(searchQuery!.toUpperCase())) {
    //     setState(() {
    //       resultados.add(DropdownMenuItem(
    //         value: tienda,
    //         child: Text("${element['tienda']} ${element['numero']}"),
    //       ));
    //     });
    //   }
    // });
    if (!_isSwitched) {
      for (var element in tiendas2) {
        String tienda =
            "${element['id']}--${element['tienda']}--${element['formato']}--${element['numero']}--${element['cadena']}";
        if (tienda.toUpperCase().contains(searchQuery!.toUpperCase())) {
          resultados.add(DropdownMenuItem(
            value: tienda,
            child: Text(
                "${element['tienda']} ${element['numero']} ${element['cadena']}"),
          ));
        }
      }
    } else {
      PermissionStatus status = await Permission.location.request();

      if (status.isGranted) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        print(position);
        setState(() {
          latitude = position.latitude;
          longitude = position.longitude;
        });
      } else {
        print("No tiene permisos");
        await Permission.location.request();
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      double rangoMaximo = 300.0;
      for (var element in tiendas2) {
        // ignore: unnecessary_null_comparison
        if (element['coordenadax'] != null && element['coordenaday'] != null) {
          print(" aqui lat es -${element['coordenadax'].toString()}-");
          double latitudTienda =
              double.parse(element['coordenadax'].toString());
          double longitudTienda =
              double.parse(element['coordenaday'].toString());

          double distancia = calcularDistancia(position.latitude,
              position.longitude, latitudTienda, longitudTienda);
          if (distancia <= rangoMaximo) {
            String tienda =
                "${element['id']}--${element['tienda']}--${element['formato']}--${element['numero']}--${element['cadena']}";
            if (tienda.toUpperCase().contains(searchQuery!.toUpperCase())) {
              setState(() {
                resultados.add(DropdownMenuItem(
                  value: tienda,
                  child: Text("${element['tienda']} ${element['numero']}"),
                ));
              });
            }
          }
        }
      }
    }
    return Tuple2<List<DropdownMenuItem<String>>, int>(
        resultados, resultados.length);
  }

  double calcularDistancia(lat1, lon1, lat2, lon2) {
    const radioTierra = 6371000.0; // en metros

    final phi1 = lat1 * (pi / 180.0);
    final phi2 = lat2 * (pi / 180.0);
    final dPhi = (lat2 - lat1) * (pi / 180.0);
    final dLambda = (lon2 - lon1) * (pi / 180.0);

    final a = sin(dPhi / 2) * sin(dPhi / 2) +
        cos(phi1) * cos(phi2) * sin(dLambda / 2) * sin(dLambda / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    final distancia = radioTierra * c;

    return distancia;
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
      decoration: const BoxDecoration(
        color: Color(0xff007DA4),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: "Montserrat",
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildPremiumInfoCard({required String title, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(title),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitasTable() {
    if (totalVisitasdList.isEmpty) {
      return Container();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(const Color(0xff007DA4)),
            headingTextStyle: const TextStyle(
              fontFamily: "Montserrat",
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            dataRowColor: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
                return null; // Use default or add alternated colors here logic if needed
              },
            ),
            columns: const [
              DataColumn(label: Text("Evidencia")),
              DataColumn(label: Text("Fecha")),
              DataColumn(label: Text("Tiempo")),
              DataColumn(label: Text("Visitante")),
              DataColumn(label: Text("Perfil")),
            ],
            rows: totalVisitasdList.asMap().entries.map((entry) {
              int index = entry.key;
              var item = entry.value;

              DateTime fechaFl = DateTime.parse(item['fecha_i']).toLocal();
              DateTime nuevaFechaFl = fechaFl.add(const Duration(hours: -1));
              String fechaString = DateFormat('dd-MM-yyyy\nHH:mm:ss').format(nuevaFechaFl);

              return DataRow(
                color: MaterialStateProperty.resolveWith<Color?>(
                  (Set<MaterialState> states) {
                    // Alternating row colors for better readability
                    if (index % 2 == 0) return Colors.grey.withOpacity(0.05);
                    return Colors.white;
                  },
                ),
                cells: [
                  DataCell(
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => Dialog(
                          backgroundColor: Colors.transparent,
                          insetPadding: EdgeInsets.zero,
                          child: Stack(
                            children: [
                              PhotoView(
                                imageProvider: NetworkImage(
                                  Api.buildImageUrl(item['imgF']),
                                ),
                                backgroundDecoration: const BoxDecoration(color: Colors.black87),
                                minScale: PhotoViewComputedScale.contained,
                                maxScale: PhotoViewComputedScale.covered * 2.5,
                              ),
                              Positioned(
                                top: 40,
                                right: 12,
                                child: GestureDetector(
                                  onTap: () => Navigator.pop(_),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Icon(Icons.close, color: Colors.white, size: 22),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Image.network(
                          Api.buildImageUrl(item['imgF']),
                          width: 40,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.broken_image, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  DataCell(Text(
                    fechaString,
                    style: const TextStyle(fontFamily: "Montserrat", fontSize: 14),
                  )),
                  DataCell(Text(
                    item['diferencia_tiempo'] ?? '',
                    style: const TextStyle(fontFamily: "Montserrat", fontSize: 14),
                  )),
                  DataCell(Text(
                    item['nombre_usuario'] ?? '',
                    style: const TextStyle(fontFamily: "Montserrat", fontSize: 14),
                  )),
                  DataCell(Text(
                    item['perfil'] ?? '',
                    style: const TextStyle(fontFamily: "Montserrat", fontSize: 14),
                  )),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
