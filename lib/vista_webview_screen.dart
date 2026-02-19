import 'package:flutter/material.dart';
import 'package:vicomv2/widgets/app_drawer.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:vicomv2/homescreen.dart';

class VistaWebViewScreen extends StatefulWidget {
  final String nombre;
  final String url;

  static Route route(String nombre, String url) {
    return MaterialPageRoute(
      builder: (_) => VistaWebViewScreen(
        nombre: nombre,
        url: url,
      ),
    );
  }

  const VistaWebViewScreen({
    Key? key,
    required this.nombre,
    required this.url,
  }) : super(key: key);

  @override
  State<VistaWebViewScreen> createState() => _VistaWebViewScreenState();
}

class _VistaWebViewScreenState extends State<VistaWebViewScreen> {
  late WebViewController controller;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(
        onLogout: () {},
        availableModules: const {},
      ),
      body: Column(
        children: [
          /// 🔷 HEADER
          Container(
            color: const Color(0xff060024),
            padding: const EdgeInsets.only(
                top: 40, left: 20, right: 20, bottom: 30),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                Builder(
                  builder: (context) {
                    return GestureDetector(
                      onTap: () => Scaffold.of(context).openDrawer(),
                      child: Image.asset(
                        "assets/logo_modulo.png",
                        scale: 5,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 10),
                Text(
                  widget.nombre,
                  style: const TextStyle(
                    fontFamily: "Montserrat",
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
          ),

          /// 🌐 WEBVIEW
          Expanded(
            child: WebViewWidget(controller: controller),
          ),
        ],
      ),

      /// 🔽 BOTTOM BAR
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xff060024),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.open_in_new_rounded),
            label: 'Tiendas',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).pushAndRemoveUntil(
              HomeScreen.route(""),
              (route) => false,
            );
          }
        },
      ),
    );
  }
}
