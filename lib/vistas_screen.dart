import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vicomv2/apis/api.dart';
import 'package:vicomv2/vista_webview_screen.dart';
import 'package:vicomv2/widgets/app_drawer.dart';

class VistasScreen extends StatefulWidget {
  static Route route(String _) {
    return MaterialPageRoute(builder: (_) => const VistasScreen());
  }

  const VistasScreen({Key? key}) : super(key: key);

  @override
  State<VistasScreen> createState() => _VistasScreenState();
}

class _VistasScreenState extends State<VistasScreen> {
  List<dynamic> vistas = [];
  bool loading = true;
  String cuenta = "";

  @override
  void initState() {
    super.initState();
    _loadVistas();
  }

  Future<void> _loadVistas() async {
    final prefs = await SharedPreferences.getInstance();
    cuenta = prefs.getString('cuenta') ?? "";

    try {
      final response = await Api().getValoresTabla(cuenta, "vistas");

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        final hoy = DateTime.now();

        final filtradas = data.where((item) {
          if (item['activo'] != 1) return false;

          if (item['islapso'] == 0) return true;

          if (item['islapso'] == 1) {
            final fechaI = DateTime.parse(item['fecha_i']);
            final fechaF = DateTime.parse(item['fecha_f']);
            return hoy.isAfter(fechaI) && hoy.isBefore(fechaF);
          }

          return false;
        }).toList();

        setState(() {
          vistas = filtradas;
          loading = false;
        });
      }
    } catch (e) {
      setState(() { // Aseguramos que quite el loading si falla
        loading = false;
      });
      debugPrint("Error cargando vistas: $e");
    }
  }

  /// 🟢 NUEVO: Lógica para inyectar variables (tienda_id, etc.)
  Future<String> _generarUrlDinamica(String urlBase, String? paramsRaw) async {
    // 1. Si no hay parámetros requeridos, devolvemos la URL limpia
    if (paramsRaw == null || paramsRaw.isEmpty) {
      return urlBase;
    }

    final prefs = await SharedPreferences.getInstance();
    
    // 2. Convertimos "tienda_id, otra_cosa" en lista
    List<String> paramsRequeridos = paramsRaw.split(',');
    
    // 3. Preparamos la URL base y sus query params existentes
    Uri uriBase = Uri.parse(urlBase);
    Map<String, String> queryParams = Map.from(uriBase.queryParameters);

    // 4. Iteramos buscando qué pide la base de datos
    for (String param in paramsRequeridos) {
      String key = param.trim(); // Quitamos espacios

      if (key == 'tienda_id') {
        // 🔹 Aquí buscamos 'idTienda' en persistencia como pediste
        int idTienda = prefs.getInt('idTienda') ?? 0;
        
        // Lo agregamos a la URL como 'tienda_id=valor'
        queryParams['tienda_id'] = idTienda.toString();
      } 
      // Aquí puedes agregar más 'else if' en el futuro
    }

    // 5. Retornamos la URL construida
    return uriBase.replace(queryParameters: queryParams).toString();
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
                height: 180,
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
                      const Text(
                        'Vistas',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
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

          // LIST
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator(color: Color(0xff007DA4)))
                : vistas.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.dashboard_outlined, size: 60, color: Colors.grey),
                            const SizedBox(height: 12),
                            Text('No hay vistas disponibles', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(20),
                        itemCount: vistas.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = vistas[index];
                          return GestureDetector(
                            onTap: () async {
                              String urlFinal = await _generarUrlDinamica(
                                item['url'],
                                item['params'],
                              );
                              if (!mounted) return;
                              Navigator.of(context).push(
                                VistaWebViewScreen.route(item['nombre'], urlFinal),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3)),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xff007DA4).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.bar_chart, color: Color(0xff007DA4), size: 22),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      item['nombre'],
                                      style: const TextStyle(
                                        fontFamily: 'Montserrat',
                                        color: Color(0xff060024),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const Icon(Icons.arrow_forward_ios, color: Color(0xff007DA4), size: 16),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}