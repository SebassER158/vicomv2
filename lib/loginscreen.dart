import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vicomv2/apis/api.dart';
import 'package:vicomv2/homescreen.dart';
import 'package:search_choices/search_choices.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vicomv2/providers/modules_provider.dart';
import 'package:vicomv2/services/tareas_badge_controller.dart';
import 'package:vicomv2/widgets/app_bottom_nav_bar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static Route<dynamic> route() {
    return MaterialPageRoute(
      builder: (context) => const LoginScreen(),
    );
  }

  @override
  // ignore: library_private_types_in_public_api
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _key = GlobalKey();

  late SharedPreferences logindata;
  bool newuser = false;
  String cuenta = "";
  bool isLoading = false;

  bool conexion = false;
  String? selectedValueSingleDialog;
  String _tienda = "";
  var tiendas2;

  final Uri _url = Uri.parse('https://mctree.com.mx/avisodeprivacidad/');

  bool _isSwitched = false;

  double latitude = 0.0;
  double longitude = 0.0;

  int _selectedIndex = 0;

  //bool _logueado = false;

  @override
  void initState() {
    super.initState();
    loginState();
    usuarioState();
    TareasBadgeController.instance.refreshGlobal();
  }

  // void modulosDisponibles() async {
  //   logindata = await SharedPreferences.getInstance();
  //   try {
  //         final response = await Api().getAvailableModules(logindata.getString('cuenta') ?? "");

  //         if (response.statusCode == 200) {

  //           print("Entro a ok en modulos disponibles");
  //           final data = jsonDecode(response.body);

  //           if (data['success'] == true && data['modules'] != null) {
  //             final modules = Map<String, bool>.from(data['modules']);

  //             if (mounted) {
  //               context.read<ModulesProvider>().setModules(modules);
  //             }
  //           }
  //         }
  //       } catch (e) {
  //         print('Error cargando módulos: $e');
  //       }
  // }

  // Future<void> modulosDisponibles() async {
  //   logindata = await SharedPreferences.getInstance();

  //   try {
  //     final response =
  //         await Api().getAvailableModules(logindata.getString('cuenta') ?? "");

  //     if (response.statusCode == 200) {
  //       print("Entro en modulos disponibes");
  //       final data = jsonDecode(response.body);

  //       if (data['success'] == true && data['modules'] != null) {
  //         final modules = Map<String, bool>.from(data['modules']);

  //         if (mounted) {
  //           await context.read<ModulesProvider>().setModules(modules);
  //         }
  //       }
  //     }
  //   } catch (e) {
  //     print('Error cargando módulos: $e');
  //   }
  // }

  Future<void> modulosDisponibles() async {
    final prefs = await SharedPreferences.getInstance();

    try {
      final response =
          await Api().getAvailableModules(prefs.getString('cuenta') ?? "");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true && data['modules'] != null) {
          await prefs.setString(
            'available_modules',
            jsonEncode(data['modules']),
          );

          print('Módulos guardados: ${data['modules']}');
        }
      }
    } catch (e) {
      print('Error cargando módulos: $e');
    }
  }

  void loginState() async {
    logindata = await SharedPreferences.getInstance();
    setState(() {
      newuser = (logindata.getBool('logueado') ?? false);
      cuenta = (logindata.getString('cuenta') ?? "");
    });
    if (newuser == true) {
      print("Paso por logueado true");
      // ignore: use_build_context_synchronously
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
      //Navigator.of(context).push(HomeScreen.route());
    }
  }

  void usuarioState() async {
    logindata = await SharedPreferences.getInstance();
    try {
      var response = await Api().getValoresTabla(cuenta, "tiendas");
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
    await modulosDisponibles();

    setState(() {
      // id_usuario = (logindata.getInt('id_usuario') ?? 0);
      // nombre = (logindata.getString('usuario') ?? "");
      // alias = (logindata.getString('alias') ?? "");
    });
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    super.dispose();
  }

  Future userLogin(tiendaul) async {
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
    await prefs.setBool('logueado', true);
    //version nueva con perfiles general
    // String valor = "$cuenta.$nip";
    // var url = "${Api().server}/getValuesTableByNip/$cuenta/usuarios/$nip";
    // print(url);
    // http.Response response = await http.get(Uri.parse(url));

    // if (response.statusCode == 200) {
    // if (response.body.length != 2) {
    // var data = jsonDecode(response.body);

    // await prefs.setString('nip', nip);
    // await prefs.setString('nombre', data["nombre"]);
    // await prefs.setString('app', data["app"]);
    // await prefs.setString('apm', data["apm"]);
    // await prefs.setString('tipo', data["foto"]);
    // await prefs.setString('telefono', data["telefono"].toString());
    // await prefs.setString('supervisor', data["supervisor"] ?? "");
    // await prefs.setString('regional', data["regional"] ?? "");
    // await prefs.setInt('id_usuario', data["id"]);
    // await prefs.setBool('logueado', true);
    setState(() {
      isLoading = false;
    });
    Navigator.of(context)
        .pushAndRemoveUntil(HomeScreen.route(""), (route) => false);
    //   } else {
    //     Fluttertoast.showToast(
    //         msg: "No existe el NIP",
    //         toastLength: Toast.LENGTH_SHORT,
    //         gravity: ToastGravity.BOTTOM,
    //         timeInSecForIosWeb: 1,
    //         fontSize: 16.0);
    //     setState(() {
    //       isLoading = false;
    //     });
    //   }
    // } else {
    //   print(response.statusCode);
    // }
  }

  @override
  Widget build(BuildContext context) {
    if (newuser == false) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          textSelectionTheme: const TextSelectionThemeData(
            cursorColor: Color(0xff007DA4),
            selectionColor: Color(0x4D007DA4),
            selectionHandleColor: Color(0xff007DA4),
          ),
        ),
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height -
                  kBottomNavigationBarHeight,
              child: Container(
                color: const Color(0xff060024), // Fallback
                child: Column(
                  children: [
                    // --- TOP: LOGO & CURVE ---
                    Expanded(
                      flex: 3,
                      child: Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xff060024), Color(0xff060024)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: Stack(
                          children: [
                            // Background decoration circles
                            Positioned(
                              top: -50,
                              left: -50,
                              child: Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 50,
                              right: -20,
                              child: Container(
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withOpacity(0.1),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 20,
                                          offset: const Offset(0, 10),
                                        )
                                      ],
                                    ),
                                    child: Image.asset(
                                      'assets/logo_login.png',
                                      scale: 4,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  const Text(
                                    "Selecciona Tienda",
                                    style: TextStyle(
                                      fontFamily: "Montserrat",
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // --- BOTTOM: FORM ---
                    Expanded(
                      flex: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(40),
                            topRight: Radius.circular(40),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26, 
                              spreadRadius: 5, 
                              blurRadius: 20,
                              offset: Offset(0, -5), // Changes position of shadow
                            ),
                          ],
                        ),
                        child: loginForm(),
                      ),
                    ),
                  ],
                ),
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
    } else {
      return Scaffold(
        body: HomeScreen(),
      );
    }
  }

  Widget loginForm() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          
           // TIENDAS LABEL CONTAINER
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xff007DA4),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xff007DA4).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: const Text(
              'TIENDAS',
              style: TextStyle(
                fontFamily: "Montserrat",
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                letterSpacing: 1.5
              ),
            ),
          ),
          
          const SizedBox(height: 30),

          // GEOLOCATION TOGGLE
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on_rounded, color: const Color(0xff007DA4)),
                    const SizedBox(width: 10),
                    const Text(
                      "Geolocalización",
                      style: TextStyle(
                        fontFamily: "Montserrat",
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff060024),
                      ),
                    ),
                  ],
                ),
                Switch(
                  value: _isSwitched,
                  activeColor: const Color(0xff007DA4),
                  activeTrackColor: const Color(0xff007DA4).withOpacity(0.4),
                  onChanged: (value) {
                    setState(() {
                      _isSwitched = value;
                    });
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // DROPDOWN
          Form(
            key: _key,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[50], // Light background
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: SearchChoices.single(
                // dropDownDialogPadding: const EdgeInsets.all(10),
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                underline: Container(), // Remove default underline
                displayClearIcon: false, // Cleaner look
                icon: const Icon(Icons.arrow_drop_down_circle_outlined, color: Color(0xff060024)),
                style: const TextStyle(
                  fontFamily: "Montserrat",
                  fontSize: 16,
                  color: Color(0xff060024),
                  fontWeight: FontWeight.w500
                ),
                futureSearchFn: (String? searchQuery,
                    String? selectedItem,
                    bool? sortedBy,
                    List<Tuple2<String, String>>? searchList,
                    int? maxLength) async {
                  return await _obtenerTiendas(searchQuery, selectedItem,
                      sortedBy, searchList, maxLength);
                },
                value: selectedValueSingleDialog,
                hint: const Text(
                  "Selecciona una tienda",
                  style: TextStyle(
                    fontFamily: "Montserrat",
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                searchHint: "Buscar tienda...",
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
          ),

          const SizedBox(height: 40),

          // BUTTON
          !isLoading
              ? SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_tienda.isEmpty) {
                        Fluttertoast.showToast(
                            msg: "Selecciona una tienda para continuar",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            fontSize: 16.0);
                        return;
                      }
                      if (_key.currentState!.validate()) {
                        _key.currentState!.save();
                        setState(() {
                          isLoading = true;
                        });
                        userLogin(_tienda);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff060024),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                      shadowColor: const Color(0xff060024).withOpacity(0.5),
                    ),
                    child: const Text(
                      "VER DETALLES",
                      style: TextStyle(
                        fontFamily: "Montserrat",
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                )
              : Center(
                  child: CircularProgressIndicator(
                    color: const Color(0xff007DA4),
                    strokeWidth: 4,
                  ),
                ),

          const SizedBox(height: 20),
          
          GestureDetector(
            onTap: () {
              _launchUrl();
            },
            child: const Text(
              "Aviso de privacidad",
              style: TextStyle(
                fontFamily: "Montserrat",
                fontSize: 14,
                decoration: TextDecoration.underline,
                color: Colors.grey,
              )
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl() async {
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
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

  Future<Tuple2<List<DropdownMenuItem<String>>, int>> _obtenerTiendas(
      String? searchQuery,
      String? selectedItem,
      bool? sortedBy,
      List<Tuple2<String, String>>? searchList,
      int? maxLength) async {
    //Se almacenaran las tiendas
    List<DropdownMenuItem<String>> resultados = [];
    logindata = await SharedPreferences.getInstance();
    // var tiendas2 = await DB.queryData("tiendas");
    if (!_isSwitched) {
      tiendas2.forEach((element) {
        String tienda =
            "${element['id']}--${element['tienda']}--${element['formato']}--${element['numero']}--${element['cadena']}";
        if (tienda.toUpperCase().contains(searchQuery!.toUpperCase())) {
          setState(() {
            resultados.add(DropdownMenuItem(
              value: tienda,
              child: Text(
                  "${element['tienda']} ${element['numero']} ${element['cadena']}"),
            ));
          });
        }
      });
    } else {
      PermissionStatus status = await Permission.location.request();

      if (status.isGranted) {
        // Los permisos de ubicación están concedidos, puedes acceder a la ubicación.
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
      tiendas2.forEach((element) {
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
      });
    }
    return Tuple2<List<DropdownMenuItem<String>>, int>(
        resultados, resultados.length);
  }
}
