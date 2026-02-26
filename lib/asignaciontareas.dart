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
import 'package:vicomv2/providers/modules_provider.dart';
import 'package:vicomv2/puntoscontrol.dart';
import 'package:vicomv2/tareas.dart';
import 'package:search_choices/search_choices.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vicomv2/widgets/app_drawer.dart';
import 'package:flutter/foundation.dart';

import 'loginScreen.dart';

Future<String> _processImage(String path) async {
  List<int> bytes = await File(path).readAsBytes();
  return base64.encode(bytes);
}

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

  bool isSending = false;

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
    SharedPreferences prefs1 = await SharedPreferences.getInstance();

    try {
      var response = await Api().getValoresTabla(cuenta, "tareasc");
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

  Future<void> enviarTarea(String tareaenv, String comentarioenv) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                const CircularProgressIndicator(
                  color: Color(0xff007DA4), 
                  strokeWidth: 5,
                ),
                const SizedBox(height: 25),
                const Text(
                  "Enviando información...",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: "Montserrat",
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff060024),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Por favor espera un momento",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: "Montserrat",
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );

    try {
      DateTime now = DateTime.now();
      String nombre_foto =
          "tareas-$cuenta-${now.year}-${now.month}-${now.day}-${now.hour}-${now.minute}.jpeg";

      String imagen64 = "";
      if (_image != null) {
        // Run image processing in background isolate
        imagen64 = await compute(_processImage, _image!.path);
      }

      var response1 =
          await Api().getCheckTareasAsignadas(cuenta, tareaenv, idTienda);

      // Close loading dialog
      Navigator.of(context, rootNavigator: true).pop();

      if (response1.statusCode == 200) {
        print("Entro en response 200");
        String respuesta = response1.body;
        var data = jsonDecode(respuesta);
        if (data[0]["existe"] >= 1) {
          Fluttertoast.showToast(
              msg: "Ya existe una tarea con el mismo nombre",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              fontSize: 16.0);
        } else {
          Fluttertoast.showToast(
              msg: "Tarea almacenada",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              fontSize: 16.0);
          
          await Api().postSaveTareasFotoAsignadas(
              idTienda, tareaenv, comentarioenv, cuenta, nombre_foto, imagen64);

          Navigator.of(context)
              .pushAndRemoveUntil(HomeScreen.route(""), (route) => false);
        }
      } else {
        // If status code is not 200, show error toast
         Fluttertoast.showToast(
            msg: "Error al verificar tarea: ${response1.statusCode}",
            backgroundColor: Colors.red,
            textColor: Colors.white,
         );
      }
    } catch (e) {
      // Close loading dialog if error occurs
      Navigator.of(context, rootNavigator: true).pop();
      print("Error: $e");
       Fluttertoast.showToast(
          msg: "Error de conexión: $e",
          backgroundColor: Colors.red,
          textColor: Colors.white,
       );
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

  Future<void> _pickImageGaleria() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No se seleccionó ninguna imagen.');
      }
    });
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
        body: Container(
          color: Colors.white,
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                // --- PREMIUM HEADER ---
                Container(
                  padding: const EdgeInsets.only(
                      top: 50, left: 20, right: 20, bottom: 20),
                  decoration: const BoxDecoration(
                    color: Color(0xff060024),
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(50),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          Flexible(
                            child: const Text(
                              "Asignación de tareas",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: "Montserrat",
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22),
                            ),
                          ),
                          Builder(builder: (context) {
                            return GestureDetector(
                              onTap: () {
                                Scaffold.of(context).openDrawer();
                              },
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.menu, color: Colors.white),
                              ),
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Optional: Add Module Logo if needed or leave clean
                      // Image.asset("assets/logo_modulo.png", scale: 5),
                    ],
                  ),
                ),

                // --- CONTENT ---
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ingresa una tarea',
                        style: TextStyle(
                          fontFamily: "Montserrat",
                          fontSize: 18, 
                          fontWeight: FontWeight.bold,
                          color: Color(0xff060024),
                        ),
                      ),
                      const SizedBox(height: 10),
                      
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: "Tarea",
                          floatingLabelBehavior: FloatingLabelBehavior.auto,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(color: Color(0xff007DA4), width: 2),
                          ),
                          prefixIcon: const Icon(Icons.task_alt, color: Color(0xff007DA4)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa la tarea';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          selectedValueSingleDialog = value;
                          _tarea = value;
                        },
                      ),
                      const SizedBox(height: 25),

                      const Text(
                        'Descripción',
                        style: TextStyle(
                          fontFamily: "Montserrat",
                          fontSize: 18, 
                          fontWeight: FontWeight.bold,
                          color: Color(0xff060024),
                        ),
                      ),
                      const SizedBox(height: 10),
                      
                      TextField(
                        controller: _commentController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(15),
                          labelText: "Descripción",
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(color: Color(0xff007DA4), width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildPremiumButton(
                            icon: Icons.camera_alt,
                            label: 'Cámara',
                            onTap: _pickImage,
                          ),
                          _buildPremiumButton(
                            icon: Icons.photo_library,
                            label: 'Galería',
                            onTap: _pickImageGaleria,
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      
                      if (_image != null)
                        Center(
                          child: Container(
                            decoration: BoxDecoration(
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
                              child: Image.file(
                                _image!,
                                height: 220,
                                width: 220,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      
                      const SizedBox(height: 30),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isSending
                              ? null
                              : () async {
                                  if (_tarea.isEmpty) {
                                      Fluttertoast.showToast(
                                        msg: "Ingresa el nombre de la tarea",
                                        backgroundColor: Colors.red,
                                        textColor: Colors.white,
                                      );
                                      return;
                                  }

                                  setState(() {
                                    isSending = true;
                                  });

                                  try {
                                    String tareaSeleccionada = _tarea;
                                    String comentario = _commentController.text;

                                    print('tarea seleccionada: $tareaSeleccionada');
                                    print('Comentario: $comentario');

                                    await enviarTarea(
                                        tareaSeleccionada, comentario);
                                  } finally {
                                    // Ensure setState is checked for mounted
                                    if (mounted) {
                                      setState(() {
                                        isSending = false;
                                      });
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff060024),
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 5,
                            shadowColor: const Color(0xff060024).withOpacity(0.4),
                          ),
                          child: const Text(
                            'ENVIAR TAREA',
                            style: TextStyle(
                              fontSize: 16, 
                              color: Colors.white, 
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              fontFamily: "Montserrat",
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.white),
      label: Text(
        label,
        style: const TextStyle(color: Colors.white, fontFamily: "Montserrat"),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xff007DA4),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 3,
      ),
    );
  }

  Future<Tuple2<List<DropdownMenuItem<String>>, int>> _obtenerTareas(
      String? searchQuery,
      String? selectedItem,
      bool? sortedBy,
      List<Tuple2<String, String>>? searchList,
      int? maxLength) async {
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
