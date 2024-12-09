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
import 'package:vicomv2/homescreen.dart';
import 'package:vicomv2/puntoscontrol.dart';
import 'package:vicomv2/tareas.dart';
import 'package:vicomv2/usuario/actividadesscreen.dart';
import 'package:intl/intl.dart';

import 'loginScreen.dart';

class Frentes extends StatefulWidget {
  static Route<dynamic> route(String mensaje) {
    return MaterialPageRoute(
      builder: (context) => Frentes(),
    );
  }

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Frentes> {
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

  late String datap;
  var promediosList= [];
  var promedios;

  late String dataa;
  var avancesList = [];
  var avances;
  String avance = "";

  int _selectedIndex = 0;
  final ScrollController _homeController = ScrollController();

  @override
  void initState() {
    super.initState();
    loginState();
    getData();
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
      var response2 = await Api().getFrentesTienda(cuenta, idTienda);
      if (response2.statusCode == 200) {
        datao = response2.body; //store response as string
        if (this.mounted) {
          setState(() {
            objetivos = jsonDecode(datao);
            objetivosList = objetivos ?? "[]";

            if (objetivosList.isNotEmpty) {
              objetivo = objetivosList[0]['promedio_facing'].toString();
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
      var response3 = await Api().getPromedioCadena(cuenta, idTienda);
      if (response3.statusCode == 200) {
        datae = response3.body; //store response as string
        if (this.mounted) {
          setState(() {
            ejecutados = jsonDecode(datae);
            ejecutadosList = ejecutados ?? "[]";

            if (ejecutadosList.isNotEmpty) {
              ejecutado = (ejecutadosList[0]['avg_facing_Cadenas'] ?? 0).toString();
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
      var response4 = await Api().getPromedioFrentesMarca(cuenta, idTienda);
      if (response4.statusCode == 200) {
        datap = response4.body; //store response as string
        if (this.mounted) {
          setState(() {
            promedios = jsonDecode(datap);
            promediosList = promedios ?? "[]";
          });
        }
      } else {
        print(response4.statusCode);
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
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Inciio'),
                onTap: () {
                  Navigator.of(context).push(HomeScreen.route(""));
                },
              ),
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
              Builder(builder: (context) {
                return ListTile(
                  leading: const Icon(Icons.view_module),
                  title: const Text('Frentes'),
                  onTap: () {
                    Scaffold.of(context).closeDrawer();
                  },
                );
              }),
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
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      Builder(
                        builder: (context) {
                          return GestureDetector(
                            onTap: (){
                              Scaffold.of(context).openDrawer();
                            },
                            child: Image.asset(
                              "assets/logo_modulo.png",
                              scale: 5,
                            ),
                          );
                        }
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 10),
                        child: const Text(
                          "Frentes",
                          style: TextStyle(fontFamily: "Montserrat",
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  child: Column(
                    children: [
                      Container(
                        height: 20,
                      ),
                      Row(
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
                                bottomLeft: Radius.circular(5),
                              )),
                          child: const Text(
                            "Formato:",
                            style: TextStyle(fontFamily: "Montserrat",color: Colors.white, fontSize: 16),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: const Color(0xff007DA4), width: 2),
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(5),
                                bottomRight: Radius.circular(5),
                              )),
                          child: Text(
                            formato,
                            style: const TextStyle(fontFamily: "Montserrat",
                                color: Colors.black, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: 20,
                    ),
                    Row(
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
                                bottomLeft: Radius.circular(5),
                              )),
                          child: const Text(
                            "Tienda:",
                            style: TextStyle(fontFamily: "Montserrat",color: Colors.white, fontSize: 16),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: const Color(0xff007DA4), width: 2),
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(5),
                                bottomRight: Radius.circular(5),
                              )),
                          child: Text(
                            tienda,
                            style: const TextStyle(fontFamily: "Montserrat",
                                color: Colors.black, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                      Container(
                        height: 20,
                      ),
                      const Divider(
                        color: Colors.white10,
                        thickness: 2,
                      ),
                      Container(
                        height: 20,
                      ),
                      Row(
                        children: [
                          const Expanded(
                            child: Center(
                              child: Text(
                                "Frentes de la tienda:",
                                style: TextStyle(fontFamily: "Montserrat",color: Colors.black, fontSize: 16),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                objetivo,
                                style: const TextStyle(fontFamily: "Montserrat",
                                  fontWeight: FontWeight.bold,
                                    color: Colors.black, fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        height: 20,
                      ),
                      Row(
                        children: [
                          const Expanded(
                            child: Center(
                              child: Text(
                                "Promedio de la cadena:",
                                style: TextStyle(fontFamily: "Montserrat",color: Colors.black, fontSize: 16),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                ejecutado,
                                style: const TextStyle(fontFamily: "Montserrat",
                                  fontWeight: FontWeight.bold,
                                    color: Colors.black, fontSize: 16),
                              ),
                            ),
                          ),
                        ],
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
                      height: 20,
                    ),
                    Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: const Color(0xff007DA4), width: 2),
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(5),
                              bottomRight: Radius.circular(5),
                            )),
                        child: Text(
                          "Promedio de Frentes por Marca",
                          style: const TextStyle(
                              fontFamily: "Montserrat",
                              color: Colors.black,
                              fontSize: 16),
                        ),
                      ),
                Container(
                        margin: EdgeInsets.all(15),
                        child: ListView.builder(
                          // physics: const AlwaysScrollableScrollPhysics(),
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: promediosList == null
                              ? 0
                              : promediosList.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Flexible(
                                  child: Text(
                                    promediosList[index]['marca'],
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontFamily: "Montserrat",
                                        color: Colors.black,
                                        fontSize: 16),
                                  ),
                                ),
                                Flexible(
                                  child: Text(
                                    promediosList[index]['promedio_facing'].toString(),
                                    textAlign: TextAlign.end,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontFamily: "Montserrat",
                                        color: Colors.black,
                                        fontSize: 16),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: const Color(0xff060024),
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.open_in_new_rounded),
              label: 'Tiendas',
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
                  Navigator.of(context).pushAndRemoveUntil(HomeScreen.route(""), (route) => false);
                }
                break;
              case 1:
                // showModal(context);
                logout();
            }
            setState(
              () {
                _selectedIndex = index;
              },
            );
          },
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
