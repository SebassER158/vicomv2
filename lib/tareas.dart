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

  int tareas_objetivo =  0;
  var tareas_pendientes;
  var tareas_realizadas;
  var tareas_pendientesList = [];
  var tareas_realizadasList= [];

  int _selectedIndex = 0;

  final ImagePicker _picker = ImagePicker();

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
              title: const Text('Inicio'),
              onTap: () {
                Navigator.of(context).pushAndRemoveUntil(
                    HomeScreen.route(""), (route) => false);
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
            Builder(builder: (context) {
              return ListTile(
                leading: const Icon(Icons.list_alt),
                title: const Text('Tareas'),
                onTap: () {
                  Scaffold.of(context).closeDrawer();
                },
              );
            }),
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
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
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
                        "Tareas",
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
              Container(
                margin: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    Container(
                      height: 20,
                    ),
                    Text(
                      'Tareas asignadas en el mes: ${tareas_objetivo.toString()}',
                      style:
                          const TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
                    ),
                    // const SizedBox(height: 10),
                    // Text(
                    //   tareas_objetivo.toString(),
                    //   style:
                    //       TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    // ),
                    const SizedBox(height: 20),
                    Text(
                      'Tareas realizadas: ${tareas_realizadasList.length.toString()}',
                      style:
                          const TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
                    ),
                    Container(
                      margin: const EdgeInsets.all(10),
                      child: ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: tareas_realizadas == null
                            ? 0
                            : tareas_realizadas.length,
                        itemBuilder: (BuildContext context, int index) {
                          DateTime fechaFl = DateTime.parse(
                                  tareas_realizadas[index]['fecha'])
                              .toLocal();
                          DateTime nuevaFechaFl =
                              fechaFl.add(const Duration(hours: -1));
                          String fechasctring =
                              DateFormat('dd-MM-yyyy')
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
                                                tareas_realizadas[index]
                                                    ['fotoF'],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  child: Image.network(
                                    "http://72.167.33.202" +
                                        tareas_realizadas[index]['imgF'],
                                    width: 40,
                                    height: 60,
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.all(10),
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
                                  margin: const EdgeInsets.all(10),
                                  child: Text(
                                    tareas_realizadas[index]
                                        ['opcion'],
                                    style: const TextStyle(
                                      fontFamily: "Montserrat",
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.all(10),
                                  child: Text(
                                    tareas_realizadas[index]['comentario'],
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
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Tareas pendientes: ${tareas_pendientesList.length.toString()}',
                      style:
                          const TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
                    ),
                    Container(
                      margin: const EdgeInsets.all(10),
                      child: ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: tareas_pendientes == null
                            ? 0
                            : tareas_pendientes.length,
                        itemBuilder: (BuildContext context, int index) {
                          DateTime fechaFl = DateTime.parse(
                                  tareas_pendientes[index]['fecha'])
                              .toLocal();
                          DateTime nuevaFechaF2 =
                              fechaFl.add(const Duration(hours: -1));
                          String fechasctring =
                              DateFormat('dd-MM-yyyy')
                                  .format(nuevaFechaF2);

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
                                                tareas_pendientes[index]
                                                    ['imgF'],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  child: Image.network(
                                    "http://72.167.33.202" +
                                        tareas_pendientes[index]['imgF'],
                                    width: 40,
                                    height: 60,
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.all(10),
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
                                  margin: const EdgeInsets.all(10),
                                  child: Text(
                                    tareas_pendientes[index]
                                        ['opcion'],
                                    style: const TextStyle(
                                      fontFamily: "Montserrat",
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.all(10),
                                  child: Text(
                                    tareas_pendientes[index]['comentario'],
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
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              )
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
                Navigator.of(context).pushAndRemoveUntil(
                    HomeScreen.route(""), (route) => false);
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
