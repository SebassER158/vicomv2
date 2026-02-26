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
      backgroundColor: Colors.white,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                /// 🔷 HEADER CON LOGO
                Container(
                  padding: const EdgeInsets.only(top: 60, bottom: 40),
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
                  child: Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.1),
                          ),
                          child: Image.asset(
                            "assets/logo_app.png",
                            scale: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                /// 🏠 INICIO
                _buildDrawerItem(
                  context,
                  icon: Icons.home_rounded,
                  title: 'Inicio',
                  onTap: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      HomeScreen.route(""),
                      (route) => false,
                    );
                  },
                ),

                /// 🏪 TIENDAS
                _buildDrawerItem(
                  context,
                  icon: Icons.store_mall_directory_rounded,
                  title: 'Tiendas',
                  onTap: onLogout,
                ),

                if (hasModule('puntos_control') || hasModule('exhibiciones') || hasModule('lineal'))
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Divider(color: Colors.grey),
                  ),

                /// 📌 PUNTOS DE CONTROL
                if (hasModule('puntos_control'))
                  _buildDrawerItem(
                    context,
                    icon: Icons.fact_check_rounded,
                    title: 'Puntos de control',
                    onTap: () {
                      Navigator.of(context).push(PuntosControl.route(""));
                    },
                  ),

                /// 🖼 EXHIBICIONES
                if (hasModule('exhibiciones'))
                  _buildDrawerItem(
                    context,
                    icon: Icons.photo_camera_back_rounded,
                    title: 'Exhibiciones',
                    onTap: () {
                      Navigator.of(context).push(Exhibiciones.route(""));
                    },
                  ),

                /// 📏 FRENTES / LINEAL
                if (hasModule('lineal'))
                  _buildDrawerItem(
                    context,
                    icon: Icons.linear_scale_rounded,
                    title: 'Frentes',
                    onTap: () {
                      Navigator.of(context).push(Frentes.route(""));
                    },
                  ),

                if (hasModule('tareas_asignadas') || hasModule('vistas'))
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Divider(color: Colors.grey),
                  ),

                /// 📝 ASIGNACIÓN DE TAREAS
                if (hasModule('tareas_asignadas'))
                  _buildDrawerItem(
                    context,
                    icon: Icons.assignment_ind_rounded,
                    title: 'Asignación de tareas',
                    onTap: () {
                      Navigator.of(context).push(AsignacionTareas.route(""));
                    },
                  ),

                /// ✅ TAREAS
                if (hasModule('tareas_asignadas'))
                  _buildDrawerItem(
                    context,
                    icon: Icons.assignment_rounded,
                    title: 'Tareas',
                    onTap: () {
                      Navigator.of(context).push(Tareas.route(""));
                    },
                  ),

                /// 📊 BI / VISTAS
                if (hasModule('vistas'))
                  _buildDrawerItem(
                    context,
                    icon: Icons.bar_chart_rounded,
                    title: 'Vistas',
                    onTap: () {
                      // Navigator.of(context).push(BiScreen.route(""));
                      Navigator.of(context).push(VistasScreen.route(""));
                    },
                  ),
              ],
            ),
          ),
          
          /// FOOTER
          Container(
            padding: const EdgeInsets.all(20),
            alignment: Alignment.center,
            child: Text(
              "Vicom v2.0",
              style: TextStyle(
                fontFamily: "Montserrat",
                color: Colors.grey[400],
                fontSize: 12,
                fontWeight: FontWeight.bold
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xff007DA4).withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xff007DA4), size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: Color(0xff060024),
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      horizontalTitleGap: 15,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
