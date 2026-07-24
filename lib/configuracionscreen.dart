import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:vicomv2/Iniciosesion.dart';
import 'package:vicomv2/apis/api.dart';


class ConfiguracionScreen extends StatefulWidget {
  const ConfiguracionScreen({super.key});

  static Route<dynamic> route() {
    return MaterialPageRoute(
      builder: (context) => const ConfiguracionScreen(),
    );
  }

  @override
  // ignore: library_private_types_in_public_api
  _ConfiguracionScreenState createState() => _ConfiguracionScreenState();
}

class _ConfiguracionScreenState extends State<ConfiguracionScreen> {
  final GlobalKey<FormState> _key = GlobalKey();

  late String _nip;
  late SharedPreferences logindata;
  bool newuser = false;
  bool isLoading = false;

  bool conexion = false;

  //bool _configurado = false;

  @override
  void initState() {
    super.initState();
    loginState();
  }

  void loginState() async {
    logindata = await SharedPreferences.getInstance();
    newuser = (logindata.getBool('configurado') ?? false);
    if (newuser == true) {
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const Iniciosesion()));
      //Navigator.of(context).push(HomeScreen.route());
    }
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    super.dispose();
  }

  Future userLogin(nip) async {
    var url = "${Api().server}/getValuesTableByCuenta/sicom/cuentas/$nip";
    http.Response response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      if (response.body.length != 2) {
        jsonDecode(response.body);

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('cuenta', nip);
        await prefs.setBool('configurado', true);
        setState(() {
          isLoading = false;
        });

        // try {
        //   final response = await Api().getAvailableModules(nip);

        //   if (response.statusCode == 200) {
        //     final data = jsonDecode(response.body);

        //     if (data['success'] == true) {
        //       final prefs = await SharedPreferences.getInstance();

        //       // Guardamos el mapa completo como JSON
        //       await prefs.setString(
        //         'available_modules',
        //         jsonEncode(data['modules']),
        //       );
        //     }
        //   }
        // } catch (e) {
        //   print('Error cargando módulos: $e');
        // }

        //Se cambio a la seleccion de tiendas

        Navigator.of(context).pushReplacement(Iniciosesion.route());
      } else {
        Fluttertoast.showToast(
            msg: "No existe la cuenta",
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
      return const Scaffold(
        body: Iniciosesion(),
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
              'INGRESA LA CUENTA',
              style: TextStyle(
                fontFamily: "Montserrat",
                fontWeight: FontWeight.bold,
                fontSize: 20,
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
          const SizedBox(height: 50),

          // Campo de texto para NIP
          Form(
            key: _key,
            child: TextFormField(
              keyboardType: TextInputType.text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: "Montserrat",
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xff060024),
                letterSpacing: 2,
              ),
              decoration: InputDecoration(
                hintText: "CUENTA",
                hintStyle: TextStyle(
                  fontFamily: "Montserrat",
                  fontSize: 14,
                  color: Colors.grey[400],
                  letterSpacing: 1,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 18),
                fillColor: Colors.grey[50],
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Color(0xff007DA4), width: 2),
                ),
              ),
              validator: (text) {
                if (text!.isEmpty) {
                  return "Campo requerido";
                }
                return null;
              },
              onSaved: (text) => _nip = text!,
            ),
          ),
          
          const SizedBox(height: 50),

          // ENTER BUTTON
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
                        userLogin(_nip);
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
        ],
      ),
    );
  }
}
