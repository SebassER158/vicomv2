import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vicomv2/apis/api.dart';
import 'package:vicomv2/homescreen.dart';
import 'package:search_choices/search_choices.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

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

  //bool _logueado = false;

  @override
  void initState() {
    super.initState();
    loginState();
    usuarioState();
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
    // var url = "http://72.167.33.202:2020/getValuesTableByNip/$cuenta/usuarios/$nip";
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
        home: Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromRGBO(6, 0, 36, 1),
                  Color.fromRGBO(6, 0, 36, 1)
                ],
              ),
            ),
            child: Column(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    alignment: Alignment.center,
                    child: Image.asset(
                      'assets/logo_login.png',
                      scale: 4,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: loginForm(),
                  ),
                ),
              ],
            ),
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
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 300.0,
            child: Form(
              key: _key,
              child: Column(
                children: <Widget>[
                  Container(
                    height: 20,
                  ),
                  Container(
                    padding: const EdgeInsets.all(5),
                    width: 200,
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
                          fontSize: 19,
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
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
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
                        return await _obtenerTiendas(searchQuery, selectedItem,
                            sortedBy, searchList, maxLength);
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
                  !isLoading
                      ? Container(
                          padding: const EdgeInsets.all(5),
                          margin: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(6, 0, 36, 1),
                            border: Border.all(color: Colors.white, width: 2),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: GestureDetector(
                            onTap: () {
                              if (_key.currentState!.validate()) {
                                _key.currentState!.save();
                                setState(() {
                                  isLoading = true;
                                });
                                userLogin(_tienda);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              alignment: Alignment.center,
                              color: Colors.transparent,
                              child: const Text(
                                "VER DETALLES",
                                style: TextStyle(
                                  fontFamily: "Montserrat",
                                  fontSize: 20.0,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        )
                      : Container(
                          margin: const EdgeInsets.all(15),
                          child: const CircularProgressIndicator(
                            color: Color(0xff007DA4),
                          )),
                  Container(
                    height: 20,
                  ),
                  GestureDetector(
                    onTap: () {
                      _launchUrl();
                    },
                    child: const Text("Aviso de privacidad",
                        style: TextStyle(
                          letterSpacing: 1,
                          fontFamily: "Montserrat",
                        )),
                  )
                ],
              ),
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
        if(element['coordenadax'] != null && element['coordenaday'] != null){
          print(" aqui lat es -${element['coordenadax'].toString()}-");
          double latitudTienda = double.parse(element['coordenadax'].toString());
          double longitudTienda = double.parse(element['coordenaday'].toString());

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
