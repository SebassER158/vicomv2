import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:vicomv2/apis/api.dart';
import 'package:vicomv2/biscreen.dart';
import 'package:vicomv2/exhibiciones.dart';
import 'package:vicomv2/frentes.dart';
import 'package:vicomv2/homescreen.dart';
import 'package:vicomv2/puntoscontrol.dart';
import 'package:vicomv2/tareas.dart';
import 'package:vicomv2/usuario/actividadesscreen.dart';
import 'package:intl/intl.dart';
import 'package:search_choices/search_choices.dart';
import 'package:image_picker/image_picker.dart';

import 'loginScreen.dart';

class AsignacionTareas extends StatefulWidget {
  static Route<dynamic> route(String mensaje) {
    return MaterialPageRoute(
      builder: (context) => AsignacionTareas(),
    );
  }

  @override
  AsignacionTareasState createState() => AsignacionTareasState();
}

class AsignacionTareasState extends State<AsignacionTareas> {
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

  String? selectedValueSingleDialog;
  String _tarea = "";
  var tareas;
  TextEditingController _commentController = TextEditingController();

  int _selectedIndex = 0;
  final ScrollController _homeController = ScrollController();

  File? _image;
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
    SharedPreferences prefs1 = await SharedPreferences.getInstance();

    try {
      var response = await Api().getTiendas(cuenta, "tareasc");
      if (response.statusCode == 200) {
        print("Entro en response 200");
        String respuesta = response.body;
        setState(() {
          tareas = jsonDecode(respuesta);
        });
        print(tareas[0]["opcion"]);
      } else {
        print(response.statusCode);
      }
    } catch (e) {
      print("Error de conexión: $e");
    }
  }

  void enviarTarea(String tareaenv, String comentarioenv) async {

    DateTime now = DateTime.now();
    var nowTime = DateTime.now();
    String fecha_string = nowTime.toString();
    String nombre_foto = "tareas-$cuenta-${now.year}-${now.month}-${now.day}-${now.hour}-${now.minute}.jpeg";
    
    List<int> bytes = await List<int>.from(_image!.readAsBytesSync());
    String imagen64 = base64.encode(bytes);

    try {
      http.Response response = await Api().postSaveTareasFoto(idTienda, tareaenv, comentarioenv, cuenta, nombre_foto, imagen64);

      Navigator.of(context).pushAndRemoveUntil(HomeScreen.route(""), (route) => false);
    } catch (e) {
      print("Error: $e");
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
        _image = File(pickedFile.path);
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

  // @override
  // Widget build(BuildContext context) {
  //   return MaterialApp(
  //     debugShowCheckedModeBanner: false,
  //     home: Scaffold(
  //       key: _scaffoldKey,
  //       drawer: Drawer(
  //         child: ListView(
  //           padding: EdgeInsets.zero,
  //           children: <Widget>[
  //             DrawerHeader(
  //                 decoration: const BoxDecoration(
  //                   color: Color(0xff060024),
  //                 ),
  //                 child: Center(
  //                   child: Image.asset(
  //                     "assets/logo_app.png",
  //                     scale: 6,
  //                   ),
  //                 )),
  //             ListTile(
  //               leading: const Icon(Icons.home),
  //               title: const Text('Inicio'),
  //               onTap: () {
  //                 Navigator.of(context).pushAndRemoveUntil(
  //                     HomeScreen.route(""), (route) => false);
  //               },
  //             ),
  //             ListTile(
  //               leading: const Icon(Icons.store),
  //               title: const Text('Tiendas'),
  //               onTap: () {
  //                 logout();
  //               },
  //             ),
  //             ListTile(
  //               leading: const Icon(Icons.list_alt),
  //               title: const Text('Exhibiciones'),
  //               onTap: () {
  //                 Navigator.of(context).push(Exhibiciones.route(""));
  //               },
  //             ),
  //             Builder(builder: (context) {
  //               return ListTile(
  //                 leading: const Icon(Icons.view_module),
  //                 title: const Text('Tareas'),
  //                 onTap: () {
  //                   Scaffold.of(context).closeDrawer();
  //                 },
  //               );
  //             }),
  //           ],
  //         ),
  //       ),
  //       body: Container(
  //         height: MediaQuery.of(context).size.height,
  //         child: SingleChildScrollView(
  //           child: Column(
  //             children: <Widget>[
  //               Container(
  //                 color: const Color(0xff060024),
  //                 padding: const EdgeInsets.only(
  //                     top: 30, left: 20, right: 20, bottom: 30),
  //                 child: Row(
  //                   crossAxisAlignment: CrossAxisAlignment.center,
  //                   children: [
  //                     IconButton(
  //                       icon: const Icon(Icons.arrow_back, color: Colors.white),
  //                       onPressed: () {
  //                         Navigator.pop(context);
  //                       },
  //                     ),
  //                     Builder(builder: (context) {
  //                       return GestureDetector(
  //                         onTap: () {
  //                           Scaffold.of(context).openDrawer();
  //                         },
  //                         child: Image.asset(
  //                           "assets/logo_modulo.png",
  //                           scale: 5,
  //                         ),
  //                       );
  //                     }),
  //                     Container(
  //                       margin: const EdgeInsets.only(left: 10),
  //                       child: const Text(
  //                         "Tareas",
  //                         style: TextStyle(
  //                             fontFamily: "Montserrat",
  //                             color: Colors.white,
  //                             fontWeight: FontWeight.bold,
  //                             fontSize: 22),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //               Container(
  //                 margin: EdgeInsets.all(10),
  //                 child: Column(
  //                   children: [
  //                     Container(
  //                       height: 20,
  //                     ),
  //                     const Text(
  //                       'Selecciona una tarea',
  //                       style:
  //                           TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  //                     ),
  //                     const SizedBox(height: 10),
  //                     Container(
  //                       decoration: BoxDecoration(
  //                         color: Colors.white,
  //                         borderRadius:
  //                             const BorderRadius.all(Radius.circular(5)),
  //                         border: Border.all(
  //                             color: const Color(0xff007DA4),
  //                             width: 2), // Color del borde
  //                       ),
  //                       child: SearchChoices.single(
  //                         dropDownDialogPadding: const EdgeInsets.all(10),
  //                         underline: Container(),
  //                         clearIcon:
  //                             const Icon(Icons.close, color: Color(0xff060024)),
  //                         iconEnabledColor: const Color(0xff060024),
  //                         futureSearchFn: (String? searchQuery,
  //                             String? selectedItem,
  //                             bool? sortedBy,
  //                             List<Tuple2<String, String>>? searchList,
  //                             int? maxLength) async {
  //                           return await _obtenerTareas(searchQuery, selectedItem,
  //                               sortedBy, searchList, maxLength);
  //                         },
  //                         value: selectedValueSingleDialog,
  //                         // hint: "Tiendas",
  //                         searchHint: "Selecciona una tienda",
  //                         onChanged: (value) {
  //                           print("La tarea seleccionada es: $value");
  //                           setState(() {
  //                             selectedValueSingleDialog = value;
  //                             _tarea = value;
  //                           });
  //                         },
  //                         isExpanded: true,
  //                       ),
  //                     ),
  //                     const SizedBox(height: 20),
  //                     const Text(
  //                       'Comentario',
  //                       style:
  //                           TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  //                     ),
  //                     const SizedBox(height: 10),
  //                     Container(
  //                       decoration: BoxDecoration(
  //                         color: Colors.white,
  //                         borderRadius: const BorderRadius.all(Radius.circular(5)),
  //                         border: Border.all(
  //                           color: const Color(0xff007DA4),
  //                           width: 2,
  //                         ),
  //                       ),
  //                       child: TextField(
  //                         controller: _commentController,
  //                         maxLines: 4,
  //                         decoration: const InputDecoration(
  //                           contentPadding: EdgeInsets.all(10),
  //                           border: InputBorder.none,
  //                         ),
  //                       ),
  //                     ),
  //                     const SizedBox(height: 20),
  //                     Center(
  //                       child: ElevatedButton(
  //                         onPressed: () {
  //                           // Lógica para enviar los datos
  //                           String tareaSeleccionada =
  //                               selectedValueSingleDialog!;
  //                           String comentario = _commentController.text;
  //                           // Aquí puedes añadir la lógica para manejar el envío de los datos
  //                           print('Tienda seleccionada: $tareaSeleccionada');
  //                           print('Comentario: $comentario');
  //                           enviarTarea(tareaSeleccionada, comentario);
  //                         },
  //                         style: ElevatedButton.styleFrom(
  //                           primary: const Color(0xff007DA4),
  //                           padding: const EdgeInsets.symmetric(
  //                               horizontal: 40, vertical: 15),
  //                         ),
  //                         child: const Text(
  //                           'Enviar',
  //                           style: TextStyle(fontSize: 16, color: Colors.white),
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               )
  //             ],
  //           ),
  //         ),
  //       ),
  //       bottomNavigationBar: BottomNavigationBar(
  //         backgroundColor: const Color(0xff060024),
  //         items: const <BottomNavigationBarItem>[
  //           BottomNavigationBarItem(
  //             icon: Icon(Icons.home),
  //             label: 'Inicio',
  //           ),
  //           BottomNavigationBarItem(
  //             icon: Icon(Icons.open_in_new_rounded),
  //             label: 'Tiendas',
  //           ),
  //         ],
  //         currentIndex: _selectedIndex,
  //         selectedItemColor: Colors.white,
  //         unselectedItemColor: Colors.grey,
  //         onTap: (int index) {
  //           switch (index) {
  //             case 0:
  //               // only scroll to top when current index is selected.
  //               if (_selectedIndex == index) {
  //                 Navigator.of(context).pushAndRemoveUntil(
  //                     HomeScreen.route(""), (route) => false);
  //               }
  //               break;
  //             case 1:
  //               // showModal(context);
  //               logout();
  //           }
  //           setState(
  //             () {
  //               _selectedIndex = index;
  //             },
  //           );
  //         },
  //       ),
  //     ),
  //   );
  // }

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
                title: const Text('Tareas'),
                onTap: () {
                  Navigator.of(context).push(Tareas.route(""));
                },
              ),
            Builder(builder: (context) {
              return ListTile(
                leading: const Icon(Icons.list_alt),
                title: const Text('Asignación de tareas'),
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
                    Flexible(
                      child: Container(
                        margin: const EdgeInsets.only(left: 10),
                        child: const Text(
                          "Asignación de tareas",
                          style: TextStyle(
                              fontFamily: "Montserrat",
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.all(10),
                child: Column(
                  children: [
                    Container(
                      height: 20,
                    ),
                    const Text(
                      'Selecciona una tarea',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
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
                          return await _obtenerTareas(searchQuery, selectedItem,
                              sortedBy, searchList, maxLength);
                        },
                        value: selectedValueSingleDialog,
                        // hint: "Tiendas",
                        searchHint: "Selecciona una tienda",
                        onChanged: (value) {
                          print("La tarea seleccionada es: $value");
                          setState(() {
                            selectedValueSingleDialog = value;
                            _tarea = value;
                          });
                        },
                        isExpanded: true,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Comentario',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.all(Radius.circular(5)),
                        border: Border.all(
                          color: const Color(0xff007DA4),
                          width: 2,
                        ),
                      ),
                      child: TextField(
                        controller: _commentController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(10),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Tomar Foto'),
                      style: ElevatedButton.styleFrom(
                        primary: const Color(0xff007DA4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 15),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _image != null
                        ? Image.file(
                            _image!,
                            height: 200,
                          )
                        : Container(),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          // Lógica para enviar los datos
                          String tareaSeleccionada =
                              selectedValueSingleDialog!;
                          String comentario = _commentController.text;
                          // Aquí puedes añadir la lógica para manejar el envío de los datos
                          print('Tienda seleccionada: $tareaSeleccionada');
                          print('Comentario: $comentario');
                          enviarTarea(tareaSeleccionada, comentario);
                        },
                        style: ElevatedButton.styleFrom(
                          primary: const Color(0xff060024),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
                        ),
                        child: const Text(
                          'Enviar',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
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


  Future<Tuple2<List<DropdownMenuItem<String>>, int>> _obtenerTareas(
      String? searchQuery,
      String? selectedItem,
      bool? sortedBy,
      List<Tuple2<String, String>>? searchList,
      int? maxLength) async {
    //Se almacenaran las tiendas
    List<DropdownMenuItem<String>> resultados = [];

    for (var element in tareas) {
      String tarea = element['opcion'];
      if (tarea.toUpperCase().contains(searchQuery!.toUpperCase())) {
        resultados.add(DropdownMenuItem(
          value: tarea,
          child: Text("${element['opcion']}"),
        ));
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
              logout();
            },
            child: const Text('Cerrar sesión'),
          )
        ],
      ),
    );
  }
}
