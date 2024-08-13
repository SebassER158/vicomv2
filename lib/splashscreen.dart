import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vicomv2/configuracionscreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 4), _onShowLogin);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _onShowLogin() {
    if(mounted){
      Navigator.of(context).pushReplacement(ConfiguracionScreen.route());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      
      body: Container(
        decoration: const BoxDecoration(
          // color: Color(0xff515fff)
          image: DecorationImage(
            image: AssetImage("assets/splashscreen.png"),
            fit: BoxFit.fill,
          ),
        ),
        // child: Center(
        //   child: Image.asset('assets/logow.png',
        //     scale: 3.0,
        //   )
        // ),
      ),
    );
  }
}