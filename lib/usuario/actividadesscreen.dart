import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vicomv2/apis/api.dart';
import 'package:intl/intl.dart';

// ignore: unused_import
class ActividadesScreen extends StatefulWidget {

  static Route<dynamic> route(String mensaje, String nombre) {
    return MaterialPageRoute(
      builder: (context) => ActividadesScreen(mensaje: mensaje, nombre: nombre),
    );
  }

  const ActividadesScreen({required this.mensaje, required this.nombre}) : super();
  final String mensaje;
  final String nombre;

  @override
  ActividadesScreenState createState() => ActividadesScreenState(mensaje, nombre);
}

class ActividadesScreenState extends State<ActividadesScreen> {

  late String data;
  var datos;
  List<dynamic> datosList = [];
  String cuenta = "";

  late final String mensaje;
  late final String nombre;
  ActividadesScreenState(this.mensaje, this.nombre);
  
  
  @override
  void initState() {
    super.initState();
    getDatos();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    super.dispose();
  }

  void getDatos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    cuenta  = (prefs.getString('cuenta') ?? "");
    String fechaHoy = DateFormat('yyyy-MM-dd').format(DateTime.now());
    var respuesta = await Api().getActividades(cuenta, int.parse(mensaje), fechaHoy);
    if (respuesta.statusCode == 200) {
        data = respuesta.body;
        
        setState(() {
          datos = jsonDecode(data);
          datosList = datos ?? "[]";
        });
      } else {
        print(respuesta.statusCode);
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(top: 30, bottom: 10, left: 10, right: 10),
                  color: Colors.grey,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GestureDetector(
                        child: Image.asset("assets/ic_home_activo.png",
                          scale: 20,
                        ),
                      ),
                      GestureDetector(
                        child: Image.asset("assets/ic_diagrama.png",
                          scale: 20,
                        ),
                      ),
                      GestureDetector(
                        child: Image.asset("assets/ic_cal_1.png",
                          scale: 20,
                        ),
                      ),
                      GestureDetector(
                        child: Image.asset("assets/btn_rosa.png",
                          scale: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Text("Usuario",
                        style: TextStyle(
                          color: Colors.blue[900],
                          fontWeight: FontWeight.bold,
                          fontSize: 18
                        ),
                      ),
                      Text(nombre,
                        style: const TextStyle(
                          fontSize: 18
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(
                  color: Colors.blueAccent,
                  thickness: 2,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text("Visitas",
                          style: TextStyle(
                            color: Colors.blue[900],
                            fontWeight: FontWeight.bold,
                            fontSize: 18
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text("Cobertura",
                          style: TextStyle(
                            color: Colors.blue[900],
                            fontWeight: FontWeight.bold,
                            fontSize: 18
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(
                  color: Colors.grey,
                  thickness: 2,
                ),
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  // ignore: unnecessary_null_comparison
                  itemCount: datosList == null ? 0 : datosList.length,
                  itemBuilder: (BuildContext context, int index) {
                    
                    DateTime fe = DateTime.parse(datosList[index]['fecha_i']);
                    DateTime fs = DateTime.parse(datosList[index]['fecha_f']);
                    String fechaEntrada = DateFormat('dd-MM-yyyy').format(fe);
                    String fechaSalida = DateFormat('dd-MM-yyyy').format(fs);
                    String horaEntrada = DateFormat('hh:mm:ss').format(fe);
                    String horaSalida = DateFormat('hh:mm:ss').format(fs);
                    
                    return Column(
                      children: [
                        Divider(
                          color: Colors.grey[700],
                          thickness: 2.5,
                        ),
                        Text("Tienda: ${datosList[index]['tienda']}"),
                        Text("Usuario: ${datosList[index]['usuario_id']}"),
                        Text("Fecha entrada: $fechaEntrada"),
                        Text("Check-in: $horaEntrada"),
                        const Text(""),
                        Text("Fecha salida: $fechaSalida"),
                        Text("Check-out: $horaSalida"),
                        const Text(""),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  image: const DecorationImage(
                                    image: AssetImage('assets/fondo_1_1.png'),
                                    fit: BoxFit.fill,
                                  ),
                                  border: Border.all(color: Colors.white, width: 2),
                                  borderRadius: BorderRadius.circular(7.0),
                                ),
                                child: const Text("Ver Foto", style: TextStyle(color: Colors.white),)
                              ),
                            ),
                            GestureDetector(
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  image: const DecorationImage(
                                    image: AssetImage('assets/fondo_1_1.png'),
                                    fit: BoxFit.fill,
                                  ),
                                  border: Border.all(color: Colors.white, width: 2),
                                  borderRadius: BorderRadius.circular(7.0),
                                ),
                                child: const Text("Ver Mapa", style: TextStyle(color: Colors.white),)
                              ),
                            ),
                          ],
                        ),
                        Divider(
                          color: Colors.grey[700],
                          thickness: 2.5,
                        ),
                        ],
                    );           
                  },
                ),
              ],
            ),
          ),
        );
  }
}
