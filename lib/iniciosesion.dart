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
import 'package:vicomv2/configuracionscreen.dart';

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
  bool _obscureText = true;

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

  Future<void> _resetAConfiguracion() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Regresar a Configuración"),
        content: const Text(
            "Esto borrará todos los datos guardados (cuenta, sesión, tienda) y regresará a la pantalla de configuración inicial. ¿Continuar?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Continuar"),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;
    Navigator.of(context)
        .pushAndRemoveUntil(ConfiguracionScreen.route(), (route) => false);
  }

  Future userLogin(user, pass) async {
    print("$user and $pass");
    try {
      var response = await Api().getUserLoginInfo(cuenta, user, pass);
      if (response.statusCode == 200) {
        print("Entro en response 200");
        String respuesta = response.body;
        var data = jsonDecode(respuesta);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        if (data is List && data.isNotEmpty) {
          String nip = (data[0]["nip"] ?? "").toString();
          String nombre = (data[0]["nombre"] ?? "").toString();
          await prefs.setString('nip', nip);
          await prefs.setString('nombre', nombre);
          await prefs.setBool('iniciosesion', true);
          setState(() {
            isLoading = false;
          });
          Navigator.of(context).pushAndRemoveUntil(LoginScreen.route(), (route) => false);
        } else {
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
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error de conexión: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (newuser == false) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          textSelectionTheme: const TextSelectionThemeData(
            // Set text cursor and selection handle color to corporate cyan
            cursorColor: Color(0xff007DA4),
            selectionColor: Color(0x4D007DA4),
            selectionHandleColor: Color(0xff007DA4),
          ),
        ),
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
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
                                  GestureDetector(
                                    onLongPress: _resetAConfiguracion,
                                    child: Container(
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
                                        // color: Colors.white, // Uncomment if logo needs to be white
                                      ),
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
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Center(
            child: Text(
              'INICIA SESIÓN',
              style: TextStyle(
                fontFamily: "Montserrat",
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Color(0xff060024),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Container(
              height: 4,
              width: 50,
              decoration: BoxDecoration(
                color: const Color(0xff007DA4),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 40),

          // Campo de texto para Usuario
          Form(
            key: _key,
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Usuario",
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                    prefixIcon: const Icon(Icons.person_outline_rounded, color: Color(0xff060024)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: Colors.grey.withOpacity(0.5) != null 
                          ? BorderSide(color: Colors.grey.withOpacity(0.5)) 
                          : const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Color(0xff007DA4), width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  style: const TextStyle(fontFamily: "Montserrat"),
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
                const SizedBox(height: 20),

                // Campo de texto para Contraseña
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Contraseña",
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                    prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xff060024)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                        color: const Color(0xff060024).withOpacity(0.6),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: Colors.grey.withOpacity(0.5) != null 
                          ? BorderSide(color: Colors.grey.withOpacity(0.5)) 
                          : const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Color(0xff007DA4), width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  obscureText: _obscureText,
                  style: const TextStyle(fontFamily: "Montserrat"),
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
              ],
            ),
          ),
          
          const SizedBox(height: 40),

          // LOGIN BUTTON
          !isLoading
              ? SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_key.currentState!.validate()) {
                        _key.currentState!.save();
                        setState(() {
                          isLoading = true;
                        });
                        userLogin(_usuario, _password);
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
                      "ENTRAR",
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

          const SizedBox(height: 30),

          // PRIVACY POLICY
          Center(
            child: GestureDetector(
              onTap: _launchUrl,
              child: Text(
                "Aviso de privacidad",
                style: TextStyle(
                  fontFamily: "Montserrat",
                  color: Colors.grey[600],
                  decoration: TextDecoration.underline,
                  fontSize: 13,
                ),
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
