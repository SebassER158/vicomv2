import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vicomv2/homescreen.dart';
import 'package:vicomv2/loginscreen.dart';
import 'package:vicomv2/iniciosesion.dart';
import 'package:vicomv2/services/tareas_badge_controller.dart';
import 'package:vicomv2/tareas.dart';
import 'package:vicomv2/tareasglobal.dart';

/// Barra de navegación inferior compartida por las pantallas internas
/// (Inicio / Tiendas / Tareas / Cerrar Sesión). Editar aquí afecta a todas
/// las pantallas que la usan.
///
/// "Tiendas" solo cambia de tienda (vuelve a LoginScreen) manteniendo la
/// cuenta iniciada; "Cerrar Sesión" sí cierra la sesión por completo y
/// regresa a Iniciosesion, igual que en HomeScreen.
///
/// [isLoginContext] indica que la barra se muestra en LoginScreen (antes de
/// seleccionar tienda) o en una pantalla alcanzada desde ahí (TareasGlobal):
/// "Inicio" y "Tiendas" no tienen función ahí (ya estamos en esa pantalla),
/// así que se ocultan y solo quedan "Tareas" (índice 0, lleva a TareasGlobal)
/// y "Cerrar Sesión" (índice 1).
class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;
  final bool isLoginContext;

  const AppBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onIndexChanged,
    this.isLoginContext = false,
  }) : super(key: key);

  Future<void> _irATiendas(BuildContext context) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove("logueado");
    // "nip" identifica al usuario (se guarda en Iniciosesion) y lo usa
    // TareasGlobal; no debe borrarse al solo cambiar de tienda.
    await preferences.remove("id_sucursal");
    await preferences.remove("usuario");
    await preferences.remove("id_usuario");
    await preferences.remove("alias");

    if (context.mounted) {
      Navigator.of(context).pushReplacement(LoginScreen.route());
    }
  }

  Future<void> _cerrarSesion(BuildContext context) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove("logueado");
    await preferences.remove("nip");
    await preferences.remove("id_sucursal");
    await preferences.remove("usuario");
    await preferences.remove("id_usuario");
    await preferences.remove("alias");
    await preferences.remove("iniciosesion");

    if (context.mounted) {
      Navigator.of(context).pushReplacement(Iniciosesion.route());
    }
  }

  Widget _iconConBadge(IconData icon, ValueNotifier<int> contador) {
    return ValueListenableBuilder<int>(
      valueListenable: contador,
      builder: (context, count, _) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(icon),
            if (count > 0)
              Positioned(
                right: -7,
                top: -4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xff060024), width: 1.5),
                  ),
                  child: Text(
                    count > 99 ? '99+' : '$count',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xff060024),
      selectedItemColor: const Color(0xff007DA4),
      unselectedItemColor: Colors.white60,
      showUnselectedLabels: true,
      selectedLabelStyle: const TextStyle(fontFamily: "Montserrat", fontWeight: FontWeight.bold, fontSize: 12),
      unselectedLabelStyle: const TextStyle(fontFamily: "Montserrat", fontSize: 11),
      currentIndex: currentIndex,
      onTap: (index) {
        if (isLoginContext) {
          switch (index) {
            case 0:
              Navigator.of(context).push(TareasGlobal.route());
              break;
            case 1:
              _cerrarSesion(context);
              break;
          }
        } else {
          switch (index) {
            case 0:
              if (currentIndex == index) {
                Navigator.of(context).pushAndRemoveUntil(
                    HomeScreen.route(""), (route) => false);
              }
              break;
            case 1:
              _irATiendas(context);
              break;
            case 2:
              Navigator.of(context).push(Tareas.route(""));
              break;
            case 3:
              _cerrarSesion(context);
              break;
          }
        }
        onIndexChanged(index);
      },
      items: isLoginContext
          ? [
              BottomNavigationBarItem(
                  icon: _iconConBadge(Icons.public_rounded,
                      TareasBadgeController.instance.global),
                  label: 'Tareas'),
              const BottomNavigationBarItem(
                  icon: Icon(Icons.logout), label: 'Cerrar Sesión'),
            ]
          : [
              const BottomNavigationBarItem(
                  icon: Icon(Icons.home), label: 'Inicio'),
              const BottomNavigationBarItem(
                  icon: Icon(Icons.store_mall_directory_rounded),
                  label: 'Tiendas'),
              BottomNavigationBarItem(
                  icon: _iconConBadge(Icons.assignment_rounded,
                      TareasBadgeController.instance.porTienda),
                  label: 'Tareas'),
              const BottomNavigationBarItem(
                  icon: Icon(Icons.logout), label: 'Cerrar Sesión'),
            ],
    );
  }
}
