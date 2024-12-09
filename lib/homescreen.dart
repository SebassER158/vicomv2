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
import 'package:vicomv2/iniciosesion.dart';
import 'package:vicomv2/puntoscontrol.dart';
import 'package:vicomv2/tareas.dart';
import 'package:photo_view/photo_view.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

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

  double latitude = 0.0;
  double longitude = 0.0;

  @override
  void initState() {
    super.initState();
    loginState();
    //getData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getData(); // Llamar a getData después de que el widget haya sido renderizado.
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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

    // var res_mod = await Api().saveModelos(cuenta, 0, deviceModel);

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
    });
    // _getDeviceInfo();
  }

  void getData() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            width: 100,
            height: 100,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 4,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var responsefc =
          await Api().getFechaCadena(cuenta, prefs.getString('cadena') ?? "");
      if (responsefc.statusCode == 200) {
        print("Entro en response 200");
        String respuesta = responsefc.body;
        var datafc = jsonDecode(respuesta);
        DateTime fechaF = DateTime.parse(datafc[0]["fecha"]).toLocal();

        setState(() {
          fecha_cadena = DateFormat('dd-MM-yyyy').format(fechaF);
        });
        print("Esta es la fecha $fecha_cadena");
      } else {
        print(responsefc.statusCode);
      }
    } catch (e) {
      print("Error de conexión: $e");
    }

    try {
      var response = await Api().getTiendas(cuenta, "tiendas");
      if (response.statusCode == 200) {
        print("Entro en response 200");
        String respuesta = response.body;
        setState(() {
          tiendas2 = jsonDecode(respuesta);
        });
        print(tiendas2[0]["tienda"]);
      } else {
        print(response.statusCode);
      }
    } catch (e) {
      print("Error de conexión: $e");
    }

    try {
      var response = await Api().getUltimaVisita(cuenta, idTienda);
      if (response.statusCode == 200) {
        datauv = response.body; //store response as string
        if (this.mounted) {
          setState(() {
            ultimaVisita = jsonDecode(datauv);
            ultimaVisitaList = ultimaVisita ?? "[]";

            if (ultimaVisitaList.isNotEmpty) {
              // fechaInicial = ultimaVisita[0]['fecha_i'];
              DateTime fechaF =
                  DateTime.parse(ultimaVisita[0]['fecha_i']).toLocal();
              DateTime nuevaFechaF = fechaF.add(const Duration(hours: -1));
              // String fechaFormateada = DateFormat('dd-MM-yyyy HH:mm:ss').format(nuevaFechaF);
              fechaInicial =
                  DateFormat('dd-MM-yyyy HH:mm:ss').format(nuevaFechaF);
              userCeys = ultimaVisita[0]['userCeys'] ?? "";
              perfil = ultimaVisita[0]['perfil'];
              nombreUsuario = ultimaVisita[0]['nombre_usuario'];
            }
          });
        }
        print(ultimaVisita);
        print("Este es el otro");
        print(ultimaVisitaList);
      } else {
        print(response.statusCode);
      }
    } catch (e) {
      print("Error de conexión: $e");
    }

    try {
      var response2 = await Api().getTotalVisitas(cuenta, idTienda);
      if (response2.statusCode == 200) {
        datatv = response2.body; //store response as string
        if (this.mounted) {
          setState(() {
            totalVisitas = jsonDecode(datatv);
            totalVisitasList = totalVisitas ?? "[]";

            if (totalVisitasList.isNotEmpty) {
              totalvis = totalVisitasList[0]['total'].toString();
            }
          });
          print(totalvis);
          print("Si lo mostro?");
        }
      } else {
        print(response2.statusCode);
      }
    } catch (e) {
      print("Error de conexión: $e");
    }

    try {
      var response3 = await Api().getEstadiaTienda(cuenta, idTienda);
      if (response3.statusCode == 200) {
        dataet = response3.body; //store response as string
        if (this.mounted) {
          setState(() {
            estadiaTienda = jsonDecode(dataet);
            estadiaTiendaList = estadiaTienda ?? "[]";

            if (estadiaTiendaList.isNotEmpty) {
              total_horas_et = estadiaTiendaList[0]['total_horas'];
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
      var response4 = await Api().getTotalEstadia(cuenta, idTienda);
      if (response4.statusCode == 200) {
        datate = response4.body; //store response as string
        if (this.mounted) {
          setState(() {
            totalEstadia = jsonDecode(datate);
            totalEstadiaList = totalEstadia ?? "[]";

            if (totalEstadiaList.isNotEmpty) {
              total_horas_te = totalEstadiaList[0]['total_horas'];
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
      var response5 = await Api().getTotalVisitasDetalle(cuenta, idTienda);
      if (response5.statusCode == 200) {
        datatvd = response5.body; //store response as string
        if (this.mounted) {
          setState(() {
            totalVisitasd = jsonDecode(datatvd);
            totalVisitasdList = totalVisitasd ?? "[]";
            print("Que trae totalVisitasdList");
            print(totalVisitasdList);
            print(totalVisitasdList.length);
          });
        }
      } else {
        print(response5.statusCode);
      }
    } catch (e) {
      print("Error de conexión: $e");
    }

    try {
      var response6 = await Api().getCumplimientoVisita(cuenta, idTienda);
      if (response6.statusCode == 200) {
        datacv = response6.body; //store response as string
        if (this.mounted) {
          setState(() {
            cumplimientoVisita = jsonDecode(datacv);
            cumplimientoVisitaList = cumplimientoVisita ?? "[]";
            cumplimiento_visita =
                (cumplimientoVisitaList[0]['porcentaje_cumplimiento'] ?? 0)
                    .toStringAsFixed(2);
          });
        }
      } else {
        print(response6.statusCode);
      }
    } catch (e) {
      print("Error de conexión: $e");
    }

    try {
      var response7 = await Api().getDatosPuntosControl(cuenta, idTienda);
      if (response7.statusCode == 200) {
        datadpc = response7.body; //store response as string
        if (this.mounted) {
          setState(() {
            datosPuntosControl = jsonDecode(datadpc);
            datosPuntosControlList = datosPuntosControl ?? "[]";
            total_registros_control =
                (datosPuntosControlList[0]['total_registros_control'] ?? 0)
                    .toString();
            total_registros_control_join =
                (datosPuntosControlList[0]['total_registros_control_join'] ?? 0)
                    .toString();
            avance_porcentaje_dpc =
                (datosPuntosControlList[0]['avance_porcentaje'] ?? 0)
                    .toStringAsFixed(2);
          });
        }
      } else {
        print(response7.statusCode);
      }
    } catch (e) {
      print("Error de conexión: $e");
    }

    try {
      var response8 = await Api().getDatosExhibicion(cuenta, idTienda);
      if (response8.statusCode == 200) {
        datade = response8.body; //store response as string
        if (this.mounted) {
          setState(() {
            datosExhibicion = jsonDecode(datade);
            datosExhibicionList = datosExhibicion ?? "[]";
            total_objetivo_de =
                (datosExhibicionList[0]['total_objetivo'] ?? 0).toString();
            total_ejecutado_de =
                (datosExhibicionList[0]['total_ejecutado'] ?? 0).toString();
            avance_porcentaje_de =
                (datosExhibicionList[0]['avance_porcentaje'] ?? 0)
                    .toStringAsFixed(2);
          });
        }
      } else {
        print(response8.statusCode);
      }
    } catch (e) {
      print("Error de conexión: $e");
    }

    try {
      var response9 = await Api().getDatosLineal(cuenta, idTienda);
      if (response9.statusCode == 200) {
        datadl = response9.body; //store response as string
        if (this.mounted) {
          setState(() {
            datosLineal = jsonDecode(datadl);
            datosLinealList = datosLineal ?? "[]";
            total_objetivo_dl =
                (datosLinealList[0]['total_objetivo'] ?? 0).toString();
            total_ejecutado_dl =
                (datosLinealList[0]['total_ejecutado'] ?? 0).toString();
            avance_porcentaje_dl =
                (datosLinealList[0]['avance_porcentaje'] ?? 0)
                    .toStringAsFixed(2);
          });
        }
      } else {
        print(response9.statusCode);
      }
    } catch (e) {
      print("Error de conexión: $e");
    }

    try {
      var response10 =
          await Api().getDatosSo(cuenta, cadena, int.parse(numero));
      if (response10.statusCode == 200) {
        dataso = response10.body; //store response as string
        if (this.mounted) {
          setState(() {
            datosSo = jsonDecode(dataso);
            datosSoList = datosSo ?? "[]";
            porcentaje_avance_so =
                (datosSo[0]['porcentaje_avance'] ?? 0).toStringAsFixed(2);
          });
        }
      } else {
        print(response10.statusCode);
      }
    } catch (e) {
      print("Error de conexión: $e");
    }

    Navigator.of(context).pop();
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
    await preferences.remove("nip");
    await preferences.remove("id_sucursal");
    await preferences.remove("usuario");
    await preferences.remove("id_usuario");
    await preferences.remove("alias");

    // await preferences.clear();
    //Navigator.of(context).push(LoginS.route("mensaje"));
    Navigator.of(context).pushReplacement(LoginScreen.route());
  }

  void logout2() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove("logueado");
    await preferences.remove("nip");
    await preferences.remove("id_sucursal");
    await preferences.remove("usuario");
    await preferences.remove("id_usuario");
    await preferences.remove("alias");
    await preferences.remove("iniciosesion");

    // await preferences.clear();
    //Navigator.of(context).push(LoginS.route("mensaje"));
    Navigator.of(context).pushReplacement(Iniciosesion.route());
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
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                  decoration: const BoxDecoration(
                    color: Color(0xff060024),
                  ),
                  child: Center(
                    child: Image.asset(
                      "assets/logo_app.png",
                      scale: 6,
                    ),
                  )),
              Builder(builder: (context) {
                return ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text('Inicio'),
                  onTap: () {
                    Scaffold.of(context).closeDrawer();
                  },
                );
              }),
              ListTile(
                leading: const Icon(Icons.store),
                title: const Text('Tiendas'),
                onTap: () {
                  logout();
                },
              ),
              ListTile(
                leading: const Icon(Icons.view_module),
                title: const Text('Puntos de control'),
                onTap: () {
                  Navigator.of(context).push(PuntosControl.route(""));
                },
              ),
              ListTile(
                leading: const Icon(Icons.view_module),
                title: const Text('Exhibiciones'),
                onTap: () {
                  Navigator.of(context).push(Exhibiciones.route(""));
                },
              ),
              ListTile(
                leading: const Icon(Icons.view_module),
                title: const Text('Frentes'),
                onTap: () {
                  Navigator.of(context).push(Frentes.route(""));
                },
              ),
              ListTile(
                leading: const Icon(Icons.list_alt),
                title: const Text('Asignación de tareas'),
                onTap: () {
                  Navigator.of(context).push(AsignacionTareas.route(""));
                },
              ),
              ListTile(
                leading: const Icon(Icons.list_alt),
                title: const Text('Tareas'),
                onTap: () {
                  Navigator.of(context).push(Tareas.route(""));
                },
              ),
              ListTile(
                leading: const Icon(Icons.list_alt),
                title: const Text('BI'),
                onTap: () {
                  Navigator.of(context).push(BiScreen.route(""));
                },
              ),
            ],
          ),
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(
                  color: const Color(0xff060024),
                  padding: const EdgeInsets.only(
                      top: 30, left: 20, right: 20, bottom: 30),
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
                            scale: 5,
                          ),
                        );
                      }),
                      Container(
                        margin: const EdgeInsets.only(left: 10),
                        child: const Text(
                          "Visita",
                          style: TextStyle(
                              fontFamily: "Montserrat",
                              color: Colors.white,
                              letterSpacing: 3,
                              fontSize: 22),
                        ),
                      ),
                    ],
                  ),
                ),
                // const Divider(
                //   color: Color(0xff007DA4)Accent,
                //   thickness: 1,
                // ),
                Column(
                  children: [
                    Container(
                      height: 20,
                    ),
                    Container(
                      padding: const EdgeInsets.all(5),
                      width: 150,
                      decoration: BoxDecoration(
                        color: const Color(0xff007DA4),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text(
                          'TIENDAS',
                          style: TextStyle(
                            fontFamily: "Montserrat",
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 20,
                    ),
                    Center(
                      child: Column(
                        children: [
                          Text("Geolocalización",
                              style: TextStyle(
                                letterSpacing: 1,
                                fontFamily: "Montserrat",
                              )),
                          Switch(
                            value: _isSwitched,
                            onChanged: (value) {
                              setState(() {
                                _isSwitched = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 20,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5)),
                        border: Border.all(
                            color: const Color(0xff007DA4),
                            width: 2), // Color del borde
                      ),
                      child: SearchChoices.single(
                        dropDownDialogPadding: const EdgeInsets.all(10),
                        underline: Container(),
                        clearIcon:
                            const Icon(Icons.close, color: Color(0xff060024)),
                        iconEnabledColor: const Color(0xff060024),
                        futureSearchFn: (String? searchQuery,
                            String? selectedItem,
                            bool? sortedBy,
                            List<Tuple2<String, String>>? searchList,
                            int? maxLength) async {
                          return await _obtenerTiendas(searchQuery,
                              selectedItem, sortedBy, searchList, maxLength);
                        },
                        value: selectedValueSingleDialog,
                        // hint: "Tiendas",
                        searchHint: "Selecciona una tienda",
                        onChanged: (value) {
                          setState(() {
                            var tiendasep = value.split("--");
                            selectedValueSingleDialog = tiendasep[1] ?? value;
                            _tienda = value;
                          });
                        },
                        isExpanded: true,
                      ),
                    ),
                    Container(
                      width: 200,
                      padding: const EdgeInsets.all(5),
                      margin: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(6, 0, 36, 1),
                        border: Border.all(color: Colors.white, width: 2),
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          setTienda(_tienda);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          alignment: Alignment.center,
                          color: Colors.transparent,
                          child: const Text(
                            "VER DETALLES",
                            style: TextStyle(
                              fontFamily: "Montserrat",
                              fontSize: 16.0,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          // Envuelve el primer column en un Expanded
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                        color: const Color(0xff007DA4),
                                        border: Border.all(
                                            color: const Color(0xff007DA4),
                                            width: 2),
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(5),
                                          bottomLeft: Radius.circular(5),
                                        )),
                                    child: const Text(
                                      "Formato:",
                                      style: TextStyle(
                                          fontFamily: "Montserrat",
                                          color: Colors.white,
                                          fontSize: 16),
                                    ),
                                  ),
                                  Expanded(
                                    // Usar Expanded aquí para que el texto largo no cause problemas
                                    child: Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: const Color(0xff007DA4),
                                              width: 2),
                                          borderRadius: const BorderRadius.only(
                                            topRight: Radius.circular(5),
                                            bottomRight: Radius.circular(5),
                                          )),
                                      child: Text(
                                        "$formato $numero",
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            fontFamily: "Montserrat",
                                            color: Colors.black,
                                            fontSize: 16),
                                        overflow: TextOverflow
                                            .ellipsis, // Para manejar textos largos
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                  height:
                                      20), // Usar SizedBox en lugar de Container para mejor rendimiento
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                        color: const Color(0xff007DA4),
                                        border: Border.all(
                                            color: const Color(0xff007DA4),
                                            width: 2),
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(5),
                                          bottomLeft: Radius.circular(5),
                                        )),
                                    child: const Text(
                                      "Tienda:",
                                      style: TextStyle(
                                          fontFamily: "Montserrat",
                                          color: Colors.white,
                                          fontSize: 16),
                                    ),
                                  ),
                                  Expanded(
                                    // Usar Expanded aquí también
                                    child: Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: const Color(0xff007DA4),
                                              width: 2),
                                          borderRadius: const BorderRadius.only(
                                            topRight: Radius.circular(5),
                                            bottomRight: Radius.circular(5),
                                          )),
                                      child: Text(
                                        tienda,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            fontFamily: "Montserrat",
                                            color: Colors.black,
                                            fontSize: 16),
                                        overflow: TextOverflow
                                            .ellipsis, // Para manejar textos largos
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                  height:
                                      20), // Usar SizedBox en lugar de Container
                            ],
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  color: const Color(0xff007DA4),
                                  border: Border.all(
                                      color: const Color(0xff007DA4), width: 2),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(5),
                                    topRight: Radius.circular(5),
                                  )),
                              child: const Text(
                                "S.O al dia::",
                                style: TextStyle(
                                    fontFamily: "Montserrat",
                                    color: Colors.white,
                                    fontSize: 16),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: const Color(0xff007DA4), width: 2),
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(5),
                                    bottomRight: Radius.circular(5),
                                  )),
                              child: Text(
                                "$fecha_cadena",
                                style: const TextStyle(
                                    fontFamily: "Montserrat",
                                    color: Colors.black,
                                    fontSize: 16),
                                overflow: TextOverflow
                                    .ellipsis, // Para manejar textos largos si es necesario
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(
                      color: Colors.grey,
                      thickness: 1,
                    ),
                    Container(
                      height: 20,
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 10, right: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Ultima visita:",
                            style: TextStyle(
                                fontFamily: "Montserrat",
                                color: Colors.black,
                                fontSize: 16),
                          ),
                          Text(
                            fechaInicial,
                            style: const TextStyle(
                                fontFamily: "Montserrat",
                                color: Colors.black,
                                fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    const Divider(
                      color: Color(0xff007DA4),
                      thickness: 1,
                    ),
                    Container(
                      height: 20,
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      margin: const EdgeInsets.only(left: 10),
                      child: const Text(
                        "Visitada por:",
                        style: TextStyle(
                            fontFamily: "Montserrat",
                            color: Colors.black,
                            fontSize: 16),
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      margin: const EdgeInsets.only(left: 10),
                      child: Text(
                        perfil,
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                          fontFamily: "Montserrat",
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      margin: const EdgeInsets.only(left: 10),
                      child: Text(
                        nombreUsuario,
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                          fontFamily: "Montserrat",
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      margin: const EdgeInsets.only(left: 10),
                      child: Text(
                        userCeys,
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                          fontFamily: "Montserrat",
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const Divider(
                      color: Color(0xff007DA4),
                      thickness: 1,
                    ),
                    Container(
                      height: 20,
                    ),
                    // Container(
                    //   margin: const EdgeInsets.only(left: 10),
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.start,
                    //     children: [
                    //       const Expanded(
                    //         child: Text(
                    //           "SO:",
                    //           style: TextStyle(
                    //               fontFamily: "Montserrat",
                    //               color: Colors.black,
                    //               fontSize: 16),
                    //         ),
                    //       ),
                    //       Expanded(
                    //         child: Text(
                    //           "$porcentaje_avance_so%",
                    //           style: const TextStyle(
                    //               fontFamily: "Montserrat",
                    //               fontWeight: FontWeight.bold,
                    //               color: Colors.black,
                    //               fontSize: 16),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // Container(
                    //   margin: const EdgeInsets.only(left: 10),
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.start,
                    //     children: [
                    //       const Expanded(
                    //         child: Text(
                    //           "Cumplimiento de visita:",
                    //           style: TextStyle(
                    //               fontFamily: "Montserrat",
                    //               color: Colors.black,
                    //               fontSize: 16),
                    //         ),
                    //       ),
                    //       Expanded(
                    //         child: Text(
                    //           "$cumplimiento_visita%",
                    //           style: const TextStyle(
                    //               fontFamily: "Montserrat",
                    //               fontWeight: FontWeight.bold,
                    //               color: Colors.black,
                    //               fontSize: 16),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    Container(
                      margin: const EdgeInsets.only(left: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Expanded(
                            child: Text(
                              "Permanencia en tienda:",
                              style: TextStyle(
                                  fontFamily: "Montserrat",
                                  color: Colors.black,
                                  fontSize: 16),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              total_horas_et,
                              style: const TextStyle(
                                  fontFamily: "Montserrat",
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Expanded(
                            child: Text(
                              "Total de visitas este mes:",
                              style: TextStyle(
                                  fontFamily: "Montserrat",
                                  color: Colors.black,
                                  fontSize: 16),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              totalvis,
                              style: const TextStyle(
                                  fontFamily: "Montserrat",
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Expanded(
                            child: Text(
                              "Tiempo total de permanencia este mes:",
                              style: TextStyle(
                                  fontFamily: "Montserrat",
                                  color: Colors.black,
                                  fontSize: 16),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              total_horas_te,
                              style: const TextStyle(
                                  fontFamily: "Montserrat",
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 20,
                    ),
                    const Divider(
                      color: Color(0xff007DA4),
                      thickness: 1,
                    ),
                    Container(
                      height: 10,
                    ),
                    // Container(
                    //   margin: const EdgeInsets.only(left: 10),
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.start,
                    //     children: [
                    //       const Expanded(
                    //         child: Text(
                    //           "Puntos de control:",
                    //           style: TextStyle(
                    //               fontFamily: "Montserrat",
                    //               color: Colors.black,
                    //               fontSize: 16),
                    //         ),
                    //       ),
                    //       Expanded(
                    //         child: Text(
                    //           "$avance_porcentaje_dpc%",
                    //           style: const TextStyle(
                    //               fontFamily: "Montserrat",
                    //               fontWeight: FontWeight.bold,
                    //               color: Colors.black,
                    //               fontSize: 16),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // Container(
                    //   color: Color(0xffe6e6e6),
                    //   padding: EdgeInsets.only(top:10, bottom: 10),
                    //   child: Column(
                    //     children: [
                    //       Container(
                    //         margin: const EdgeInsets.only(left: 10),
                    //         child: Row(
                    //           mainAxisAlignment: MainAxisAlignment.start,
                    //           children: [
                    //             const Expanded(
                    //               child: Text(
                    //                 "Objetivo:",
                    //                 style: TextStyle(
                    //                     fontFamily: "Montserrat",
                    //                     color: Colors.black,
                    //                     fontSize: 16),
                    //               ),
                    //             ),
                    //             Expanded(
                    //               child: Text(
                    //                 total_registros_control,
                    //                 style: const TextStyle(
                    //                     fontFamily: "Montserrat",
                    //                     fontWeight: FontWeight.bold,
                    //                     color: Colors.black,
                    //                     fontSize: 16),
                    //               ),
                    //             ),
                    //           ],
                    //         ),
                    //       ),
                    //       Container(
                    //         margin: const EdgeInsets.only(left: 10),
                    //         child: Row(
                    //           mainAxisAlignment: MainAxisAlignment.start,
                    //           children: [
                    //             const Expanded(
                    //               child: Text(
                    //                 "Ejecutado:",
                    //                 style: TextStyle(
                    //                     fontFamily: "Montserrat",
                    //                     color: Colors.black,
                    //                     fontSize: 16),
                    //               ),
                    //             ),
                    //             Expanded(
                    //               child: Text(
                    //                 total_registros_control_join,
                    //                 style: const TextStyle(
                    //                     fontFamily: "Montserrat",
                    //                     fontWeight: FontWeight.bold,
                    //                     color: Colors.black,
                    //                     fontSize: 16),
                    //               ),
                    //             ),
                    //           ],
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),

                    Container(
                      margin: const EdgeInsets.only(left: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Expanded(
                            child: Text(
                              "SO:",
                              style: TextStyle(
                                  fontFamily: "Montserrat",
                                  color: Colors.black,
                                  fontSize: 16),
                            ),
                          ),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "$porcentaje_avance_so%",
                                  style: const TextStyle(
                                      fontFamily: "Montserrat",
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontSize: 16),
                                ),
                                Text(
                                  "${(double.parse(porcentaje_avance_so) * 0.2).toStringAsFixed(2)}%",
                                  style: const TextStyle(
                                      fontFamily: "Montserrat",
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Expanded(
                            child: Text(
                              "Cumplimiento de visita:",
                              style: TextStyle(
                                  fontFamily: "Montserrat",
                                  color: Colors.black,
                                  fontSize: 16),
                            ),
                          ),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "$cumplimiento_visita%",
                                  style: const TextStyle(
                                      fontFamily: "Montserrat",
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontSize: 16),
                                ),
                                Text(
                                  "${(double.parse(cumplimiento_visita) * 0.5).toStringAsFixed(2)}%",
                                  style: const TextStyle(
                                      fontFamily: "Montserrat",
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isVisible = !_isVisible;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(left: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Expanded(
                              child: Text(
                                "Puntos de control:",
                                style: TextStyle(
                                    fontFamily: "Montserrat",
                                    color: Colors.black,
                                    fontSize: 16),
                              ),
                            ),
                            Expanded(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "$avance_porcentaje_dpc%",
                                    style: const TextStyle(
                                        fontFamily: "Montserrat",
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: 16),
                                  ),
                                  Text(
                                    "${(double.parse(avance_porcentaje_dpc) * 0.1).toStringAsFixed(2)}%",
                                    style: const TextStyle(
                                        fontFamily: "Montserrat",
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    AnimatedOpacity(
                      opacity: _isVisible ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: _isVisible
                          ? Container(
                              color: const Color(0xffe6e6e6),
                              padding:
                                  const EdgeInsets.only(top: 10, bottom: 10),
                              child: Column(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(left: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        const Expanded(
                                          child: Text(
                                            "Objetivo:",
                                            style: TextStyle(
                                                fontFamily: "Montserrat",
                                                color: Colors.black,
                                                fontSize: 16),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            total_registros_control,
                                            style: const TextStyle(
                                                fontFamily: "Montserrat",
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                                fontSize: 16),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(left: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        const Expanded(
                                          child: Text(
                                            "Ejecutado:",
                                            style: TextStyle(
                                                fontFamily: "Montserrat",
                                                color: Colors.black,
                                                fontSize: 16),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            total_registros_control_join,
                                            style: const TextStyle(
                                                fontFamily: "Montserrat",
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                                fontSize: 16),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Container(),
                    ),

                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isVisible_de = !_isVisible_de;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(left: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Expanded(
                              child: Text(
                                "Exhibiciones:",
                                style: TextStyle(
                                    fontFamily: "Montserrat",
                                    color: Colors.black,
                                    fontSize: 16),
                              ),
                            ),
                            Expanded(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "$avance_porcentaje_de%",
                                    style: const TextStyle(
                                        fontFamily: "Montserrat",
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: 16),
                                  ),
                                  Text(
                                    "${(double.parse(avance_porcentaje_de) * 0.1).toStringAsFixed(2)}%",
                                    style: const TextStyle(
                                        fontFamily: "Montserrat",
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    AnimatedOpacity(
                      opacity: _isVisible_de ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: _isVisible_de
                          ? Container(
                              color: const Color(0xffe6e6e6),
                              padding:
                                  const EdgeInsets.only(top: 10, bottom: 10),
                              child: Column(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(left: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        const Expanded(
                                          child: Text(
                                            "Objetivo:",
                                            style: TextStyle(
                                                fontFamily: "Montserrat",
                                                color: Colors.black,
                                                fontSize: 16),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            total_ejecutado_de,
                                            style: const TextStyle(
                                                fontFamily: "Montserrat",
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                                fontSize: 16),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(left: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        const Expanded(
                                          child: Text(
                                            "Ejecutado:",
                                            style: TextStyle(
                                                fontFamily: "Montserrat",
                                                color: Colors.black,
                                                fontSize: 16),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            total_ejecutado_de,
                                            style: const TextStyle(
                                                fontFamily: "Montserrat",
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                                fontSize: 16),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Container(),
                    ),

                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isVisible_dl = !_isVisible_dl;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(left: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Expanded(
                              child: Text(
                                "Lineal:",
                                style: TextStyle(
                                    fontFamily: "Montserrat",
                                    color: Colors.black,
                                    fontSize: 16),
                              ),
                            ),
                            Expanded(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "$avance_porcentaje_dl%",
                                    style: const TextStyle(
                                        fontFamily: "Montserrat",
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: 16),
                                  ),
                                  Text(
                                    "${(double.parse(avance_porcentaje_dl) * 0.1).toStringAsFixed(2)}%",
                                    style: const TextStyle(
                                        fontFamily: "Montserrat",
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    AnimatedOpacity(
                      opacity: _isVisible_dl ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: _isVisible_dl
                          ? Container(
                              color: const Color(0xffe6e6e6),
                              padding:
                                  const EdgeInsets.only(top: 10, bottom: 10),
                              child: Column(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(left: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        const Expanded(
                                          child: Text(
                                            "Objetivo:",
                                            style: TextStyle(
                                                fontFamily: "Montserrat",
                                                color: Colors.black,
                                                fontSize: 16),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            total_objetivo_dl,
                                            style: const TextStyle(
                                                fontFamily: "Montserrat",
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                                fontSize: 16),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(left: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        const Expanded(
                                          child: Text(
                                            "Ejecutado:",
                                            style: TextStyle(
                                                fontFamily: "Montserrat",
                                                color: Colors.black,
                                                fontSize: 16),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            total_ejecutado_dl,
                                            style: const TextStyle(
                                                fontFamily: "Montserrat",
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                                fontSize: 16),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Container(),
                    ),

                    Container(
                      margin: const EdgeInsets.only(left: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Expanded(
                            child: Text(
                              "Avance:",
                              style: TextStyle(
                                  fontFamily: "Montserrat",
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                          ),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "",
                                  style: TextStyle(
                                      fontFamily: "Montserrat",
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontSize: 16),
                                ),
                                Text(
                                  "${((double.parse(cumplimiento_visita) * 0.5) + (double.parse(porcentaje_avance_so) * 0.2) + (double.parse(avance_porcentaje_dpc) * 0.1) + (double.parse(avance_porcentaje_de) * 0.1) + (double.parse(avance_porcentaje_dl) * 0.1)).toStringAsFixed(2)}%",
                                  style: const TextStyle(
                                      fontFamily: "Montserrat",
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      height: 10,
                    ),
                    const Divider(
                      color: Color(0xff007DA4),
                      thickness: 1,
                    ),
                    Container(
                      height: 10,
                    ),
                    // Container(
                    //   color: const Color(0xFFE6E6E6),
                    //   child: Column(
                    //     children: [
                    Container(
                      height: 10,
                    ),
                    totalVisitasdList.length > 0
                        ? SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Container(
                              margin: EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  // Container(
                                  //   margin: EdgeInsets.all(5),
                                  //   padding: const EdgeInsets.all(5),
                                  //   decoration: BoxDecoration(
                                  //       color: const Color(0xff007DA4),
                                  //       border: Border.all(
                                  //           color: const Color(0xff007DA4),
                                  //           width: 2),
                                  //       borderRadius: BorderRadius.circular(5)),
                                  //   child: const Text(
                                  //     "Evidencia",
                                  //     style: TextStyle(
                                  //         fontFamily: "Montserrat",
                                  //         color: Colors.white,
                                  //         fontSize: 16),
                                  //   ),
                                  // ),
                                  Container(
                                    margin: EdgeInsets.all(5),
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                        color: const Color(0xff007DA4),
                                        border: Border.all(
                                            color: Color(0xff007DA4), width: 2),
                                        borderRadius: BorderRadius.circular(5)),
                                    child: const Text(
                                      "Evidencia",
                                      style: TextStyle(
                                          fontFamily: "Montserrat",
                                          color: Colors.white,
                                          fontSize: 16),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.all(5),
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                        color: const Color(0xff007DA4),
                                        border: Border.all(
                                            color: Color(0xff007DA4), width: 2),
                                        borderRadius: BorderRadius.circular(5)),
                                    child: const Text(
                                      "Visita",
                                      style: TextStyle(
                                          fontFamily: "Montserrat",
                                          color: Colors.white,
                                          fontSize: 16),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.all(5),
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                        color: const Color(0xff007DA4),
                                        border: Border.all(
                                            color: const Color(0xff007DA4),
                                            width: 2),
                                        borderRadius: BorderRadius.circular(5)),
                                    child: const Text(
                                      "Tiempo",
                                      style: TextStyle(
                                          fontFamily: "Montserrat",
                                          color: Colors.white,
                                          fontSize: 16),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.all(5),
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                        color: const Color(0xff007DA4),
                                        border: Border.all(
                                            color: const Color(0xff007DA4),
                                            width: 2),
                                        borderRadius: BorderRadius.circular(5)),
                                    child: const Text(
                                      "Quien la visito",
                                      style: TextStyle(
                                          fontFamily: "Montserrat",
                                          color: Colors.white,
                                          fontSize: 16),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.all(5),
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                        color: const Color(0xff007DA4),
                                        border: Border.all(
                                            color: const Color(0xff007DA4),
                                            width: 2),
                                        borderRadius: BorderRadius.circular(5)),
                                    child: const Text(
                                      "Perfil",
                                      style: TextStyle(
                                          fontFamily: "Montserrat",
                                          color: Colors.white,
                                          fontSize: 16),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Container(),
                    // Container(
                    //   margin: EdgeInsets.all(10),
                    //   child: ListView.builder(
                    //     physics: NeverScrollableScrollPhysics(),
                    //     shrinkWrap: true,
                    //     itemCount: totalVisitasdList == null
                    //         ? 0
                    //         : totalVisitasdList.length,
                    //     itemBuilder: (BuildContext context, int index) {
                    //       DateTime fechaFl =
                    //           DateTime.parse(totalVisitasdList[index]['fecha_i'])
                    //               .toLocal();
                    //       DateTime nuevaFechaFl =
                    //           fechaFl.add(const Duration(hours: -1));
                    //       String fechasctring = DateFormat('dd-MM-yyyy\nHH:mm:ss')
                    //           .format(nuevaFechaFl);

                    //       print("PAsa aqui $index vecesS");
                    //       return SingleChildScrollView(
                    //         scrollDirection: Axis.vertical,
                    //         child: Column(
                    //           children: List.generate(totalVisitasdList.length,
                    //               (index) {
                    //             return SingleChildScrollView(
                    //               scrollDirection: Axis.horizontal,
                    //               child: Row(
                    //                 mainAxisAlignment:
                    //                     MainAxisAlignment.spaceAround,
                    //                 verticalDirection: VerticalDirection.up,
                    //                 children: [

                    //                   Container(
                    //                     margin: EdgeInsets.all(10),
                    //                     child: Text(
                    //                       fechasctring,
                    //                       textAlign: TextAlign.center,
                    //                       style: const TextStyle(
                    //                         fontFamily: "Montserrat",
                    //                         color: Colors.black,
                    //                         fontSize: 16,
                    //                       ),
                    //                     ),
                    //                   ),
                    //                   Container(
                    //                     margin: EdgeInsets.all(10),
                    //                     child: Text(
                    //                       totalVisitasdList[index]
                    //                           ['diferencia_tiempo'],
                    //                       style: const TextStyle(
                    //                         fontFamily: "Montserrat",
                    //                         color: Colors.black,
                    //                         fontSize: 16,
                    //                       ),
                    //                     ),
                    //                   ),
                    //                   Container(
                    //                     margin: EdgeInsets.all(10),
                    //                     child: Text(
                    //                       totalVisitasdList[index]['nombre_usuario'],
                    //                       style: const TextStyle(
                    //                         fontFamily: "Montserrat",
                    //                         color: Colors.black,
                    //                         fontSize: 16,
                    //                       ),
                    //                     ),
                    //                   ),
                    //                   Container(
                    //                     margin: EdgeInsets.all(10),
                    //                     child: Text(
                    //                       totalVisitasdList[index]['perfil'],
                    //                       style: const TextStyle(
                    //                         fontFamily: "Montserrat",
                    //                         color: Colors.black,
                    //                         fontSize: 16,
                    //                       ),
                    //                     ),
                    //                   ),
                    //                 ],
                    //               ),
                    //             );
                    //           }
                    //           ),
                    //         ),
                    //       );
                    //     },
                    //   ),
                    // ),
                    Container(
                      margin: EdgeInsets.all(10),
                      child: ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: totalVisitasdList == null
                            ? 0
                            : totalVisitasdList.length,
                        itemBuilder: (BuildContext context, int index) {
                          DateTime fechaFl = DateTime.parse(
                                  totalVisitasdList[index]['fecha_i'])
                              .toLocal();
                          DateTime nuevaFechaFl =
                              fechaFl.add(const Duration(hours: -1));
                          String fechasctring =
                              DateFormat('dd-MM-yyyy\nHH:mm:ss')
                                  .format(nuevaFechaFl);

                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              verticalDirection: VerticalDirection.up,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (_) => Dialog(
                                        child: PhotoView(
                                          imageProvider: NetworkImage(
                                            "http://72.167.33.202" +
                                                totalVisitasdList[index]
                                                    ['imgF'],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  child: Image.network(
                                    "http://72.167.33.202" +
                                        totalVisitasdList[index]['imgF'],
                                    width: 40,
                                    height: 60,
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.all(10),
                                  child: Text(
                                    fechasctring,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontFamily: "Montserrat",
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.all(10),
                                  child: Text(
                                    totalVisitasdList[index]
                                        ['diferencia_tiempo'],
                                    style: const TextStyle(
                                      fontFamily: "Montserrat",
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.all(10),
                                  child: Text(
                                    totalVisitasdList[index]['nombre_usuario'],
                                    style: const TextStyle(
                                      fontFamily: "Montserrat",
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.all(10),
                                  child: Text(
                                    totalVisitasdList[index]['perfil'],
                                    style: const TextStyle(
                                      fontFamily: "Montserrat",
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Container(
          // decoration: const BoxDecoration(
          //   image: DecorationImage(
          //     image: AssetImage('assets/fondo_1_1.png'),
          //     fit: BoxFit.none,
          //   ),
          // ),
          child: BottomNavigationBar(
            backgroundColor: const Color(0xff060024),
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Inicio',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.open_in_new_rounded),
                // label: 'Tiendas',
                label: 'Login',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.grey,
            onTap: (int index) {
              switch (index) {
                case 0:
                  // only scroll to top when current index is selected.
                  if (_selectedIndex == index) {
                    print("Se selecciono home");
                  }
                  break;
                case 1:
                  showModal(context);
                  // logout();
              }
              setState(
                () {
                  _selectedIndex = index;
                },
              );
            },
          ),
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
              logout2();
            },
            child: const Text('Cerrar sesión'),
          )
        ],
      ),
    );
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
}
