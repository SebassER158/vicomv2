import 'package:flutter/material.dart';
import 'package:vicomv2/asignaciontareas.dart';
import 'package:vicomv2/biscreen.dart';
import 'package:vicomv2/exhibiciones.dart';
import 'package:vicomv2/frentes.dart';
import 'package:vicomv2/homescreen.dart';
import 'package:vicomv2/puntoscontrol.dart';
import 'package:vicomv2/tareas.dart';
import 'package:vicomv2/vistas_screen.dart';

class AppDrawer extends StatelessWidget {
  final VoidCallback onLogout;
  final Map<String, bool> availableModules;

  const AppDrawer({
    Key? key,
    required this.onLogout,
    required this.availableModules,
  }) : super(key: key);

  bool hasModule(String key) => availableModules[key] == true;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          /// 🔷 HEADER CON LOGO
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xff060024),
            ),
            child: Center(
              child: Image.asset(
                "assets/logo_app.png",
                scale: 6,
              ),
            ),
          ),

          /// 🏠 INICIO
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Inicio'),
            onTap: () {
              Navigator.of(context).pushAndRemoveUntil(
                HomeScreen.route(""),
                (route) => false,
              );
            },
          ),

          /// 🏪 TIENDAS
          ListTile(
            leading: const Icon(Icons.store),
            title: const Text('Tiendas'),
            onTap: onLogout,
          ),

          /// 📌 PUNTOS DE CONTROL
          if (hasModule('puntos_control'))
            ListTile(
              leading: const Icon(Icons.view_module),
              title: const Text('Puntos de control'),
              onTap: () {
                Navigator.of(context).push(PuntosControl.route(""));
              },
            ),

          /// 🖼 EXHIBICIONES
          if (hasModule('exhibiciones'))
            ListTile(
              leading: const Icon(Icons.view_module),
              title: const Text('Exhibiciones'),
              onTap: () {
                Navigator.of(context).push(Exhibiciones.route(""));
              },
            ),

          /// 📏 FRENTES / LINEAL
          if (hasModule('lineal'))
            ListTile(
              leading: const Icon(Icons.view_module),
              title: const Text('Frentes'),
              onTap: () {
                Navigator.of(context).push(Frentes.route(""));
              },
            ),

          /// 📝 ASIGNACIÓN DE TAREAS
          if (hasModule('tareas_asignadas'))
            ListTile(
              leading: const Icon(Icons.list_alt),
              title: const Text('Asignación de tareas'),
              onTap: () {
                Navigator.of(context)
                    .push(AsignacionTareas.route(""));
              },
            ),

          /// ✅ TAREAS
          if (hasModule('tareas_asignadas'))
            ListTile(
              leading: const Icon(Icons.list_alt),
              title: const Text('Tareas'),
              onTap: () {
                Navigator.of(context).push(Tareas.route(""));
              },
            ),

          /// 📊 BI / VISTAS
          if (hasModule('vistas'))
            ListTile(
              leading: const Icon(Icons.list_alt),
              title: const Text('Vistas'),
              onTap: () {
                // Navigator.of(context).push(BiScreen.route(""));
                Navigator.of(context).push(VistasScreen.route(""));
              },
            ),
        ],
      ),
    );
  }
}
