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
      backgroundColor: Colors.grey[100],
      drawer: AppDrawer(
        onLogout: () {},
        availableModules: const {},
      ),
      body: Column(
        children: [
          // PREMIUM HEADER
          Stack(
            children: [
              Container(
                height: 160,
                decoration: const BoxDecoration(
                  color: Color(0xff060024),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Text(
                          widget.nombre,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Builder(
                        builder: (ctx) => IconButton(
                          icon: const Icon(Icons.menu, color: Colors.white),
                          onPressed: () => Scaffold.of(ctx).openDrawer(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // WEBVIEW
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(0),
                topRight: Radius.circular(0),
              ),
              child: WebViewWidget(controller: controller),
            ),
          ),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xff060024),
        selectedItemColor: const Color(0xff007DA4),
        unselectedItemColor: Colors.white60,
        currentIndex: _selectedIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.refresh), label: 'Recargar'),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).pushAndRemoveUntil(
              HomeScreen.route(''),
              (route) => false,
            );
          } else if (index == 1) {
            controller.reload();
          }
        },
      ),
    );
  }
}
