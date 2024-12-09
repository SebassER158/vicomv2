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
import 'package:fluttertoast/fluttertoast.dart';
import 'package:vicomv2/loginscreen.dart';

class Iniciosesion extends StatefulWidget {
  const Iniciosesion({super.key});

  static Route<dynamic> route() {
    return MaterialPageRoute(
      builder: (context) => const Iniciosesion(),
    );
  }

  @override
  // ignore: library_private_types_in_public_api
  _IniciosesionState createState() => _IniciosesionState();
}

class _IniciosesionState extends State<Iniciosesion> {
  final GlobalKey<FormState> _key = GlobalKey();

  late SharedPreferences logindata;
  bool newuser = false;
  String cuenta = "";
  bool isLoading = false;

  bool conexion = false;
  String? selectedValueSingleDialog;
  String _usuario = "";
  String _password= "";

  final Uri _url = Uri.parse('https://mctree.com.mx/avisodeprivacidad/');

  bool _isSwitched = false;

  double latitude = 0.0;
  double longitude = 0.0;

  @override
  void initState() {
    super.initState();
    loginState();
  }

  void loginState() async {
    logindata = await SharedPreferences.getInstance();
    setState(() {
      newuser = (logindata.getBool('iniciosesion') ?? false);
      cuenta = (logindata.getString('cuenta') ?? "");
    });
    if (newuser == true) {
      print("Paso por iniciosesion true");
      // ignore: use_build_context_synchronously
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
      //Navigator.of(context).push(HomeScreen.route());
    }
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    super.dispose();
  }

  Future userLogin(user, pass) async {
    print("$user and $pass");
    try {
      var response = await Api().getUserLogin(cuenta, user, pass);
      if (response.statusCode == 200) {
        print("Entro en response 200");
        String respuesta = response.body;
        var data = jsonDecode(respuesta);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        if(data[0]["total"] == 1){
          await prefs.setBool('iniciosesion', true);
          setState(() {
            isLoading = false;
          });
          Navigator.of(context).pushAndRemoveUntil(LoginScreen.route(), (route) => false);
        }else{
          Fluttertoast.showToast(
            msg: "No existe el usuario",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 16.0);
            setState(() {
              isLoading = false;
            });
        }
      } else {
        print(response.statusCode);
      }
    } catch (e) {
      print("Error de conexión: $e");
    }
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
        body: LoginScreen(),
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
                      'INICIA SESIÓN',
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
                // Campo de texto para Usuario
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Usuario",
                    floatingLabelAlignment: FloatingLabelAlignment.center,
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu usuario';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _usuario = value!;
                  },
                ),
                Container(
                  height: 20,
                ),
                // Campo de texto para Contraseña
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Contraseña",
                    floatingLabelAlignment: FloatingLabelAlignment.center,
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu contraseña';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _password = value!;
                  },
                ),
                Container(
                  height: 20,
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
                              userLogin(_usuario, _password);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            alignment: Alignment.center,
                            color: Colors.transparent,
                            child: const Text(
                              "ENTRAR",
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
                ),
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
}
