import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:vicomv2/Iniciosesion.dart';

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
      print("Paso por configurado true");
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Iniciosesion()));
      //Navigator.of(context).push(HomeScreen.route());
    }
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    super.dispose();
  }

  Future userLogin(nip) async {
    var url = "http://72.167.33.202:2020/getValuesTableByCuenta/sicom/cuentas/$nip";
    http.Response response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      if (response.body.length != 2) {
        var data = jsonDecode(response.body);

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('cuenta', nip);
        await prefs.setBool('configurado', true);
        setState(() {
          isLoading = false;
        });
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
        home: Stack(
          children: [
            // Image.asset(
            //   "assets/background.png",
            //   height: MediaQuery.of(context).size.height,
            //   width: MediaQuery.of(context).size.width,
            //   fit: BoxFit.fill,
            // ),
            Scaffold(
              backgroundColor: Color(0xff060024),
              body: Center(
                child: SingleChildScrollView(child: Container(child: loginForm())),
              ),
            ),
          ],
        ),
      );
    } else {
      return const Scaffold(
        body: Iniciosesion(),
        //body: Text(""),
      );
    }
  }

  Widget loginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Image.asset('assets/logo_login.png',
          scale: 4,
        ),
        Container(
          height: 40,
        ),
        // Container(
        //   margin: const EdgeInsets.all(20),
        //   child: Column(
        //     children: const [
        //       Divider(
        //         color: Colors.white,
        //         thickness: 1.5,
        //       ),
        //       Text("CONFIGURACIÓN",
        //         style: TextStyle(fontFamily: "Montserrat",
        //           color: Colors.white,
        //           fontSize: 18,
        //           letterSpacing: 3
        //         )
        //       ),
        //       Divider(
        //         color: Colors.white,
        //         thickness: 1.5,
        //       )
        //     ],
        //   ),
        // ),
        SizedBox(
          width: 200.0,
          child: Form(
            key: _key,
            child: Column(
              children: <Widget>[
                //Container(margin: EdgeInsets.only(top: MediaQuery.of(context).size.height/2),),
                SizedBox(
                  height: 50.0,
                  child: TextFormField(
                    validator: (text) {
                      if (text!.isEmpty) {
                        Fluttertoast.showToast(
                            msg: "Campo requerido",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            fontSize: 16.0);
                        return "Campo requerido";
                      }
                      return null;
                    },
                    keyboardType: TextInputType.text,
                    textAlign: TextAlign.center,
                    textAlignVertical: TextAlignVertical.center,
                    style: const TextStyle(fontFamily: "Montserrat",
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      // hintText: '*****',
                      filled: true,
                      fillColor: Colors.white,
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xff007DA4), width: 2.5),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xff007DA4), width: 2.5),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                    onSaved: (text) => _nip = text!,
                  ),
                ),
                !isLoading
                    ? Container(
                      padding: const EdgeInsets.all(5),
                        margin: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 2),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            if (_key.currentState!.validate()) {
                              _key.currentState!.save();
                              setState(() {
                                isLoading = true;
                              });
                              userLogin(_nip);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            alignment: Alignment.center,
                            // ignore: sort_child_properties_last
                            child: const Text(
                              "ENTRAR",
                              style: TextStyle(fontFamily: "Montserrat",
                                fontSize: 20.0,
                                color: Colors.white,
                              ),
                            ),
                            color: Color(0xff007DA4)
                          ),
                        ),
                      )
                    : Container(
                        margin: const EdgeInsets.all(15),
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                        )),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
