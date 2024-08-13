import 'package:flutter/material.dart';
import 'package:vicomv2/splashscreen.dart';

class AppPrincipal extends StatefulWidget {
  const AppPrincipal({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AppPrincipalState createState() => _AppPrincipalState();
}

class _AppPrincipalState extends State<AppPrincipal> {


  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      //theme: ThemeData.light(), //  Tema Claro
      theme: ThemeData.dark(), // Tema Obscuro
      home: const SplashScreen(),
    );
  }
}