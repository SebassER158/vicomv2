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
                const Text(
                  "Vistas",
                  style: TextStyle(
                    fontFamily: "Montserrat",
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
          ),

          /// 🔘 LISTA
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: vistas.length,
                    itemBuilder: (context, index) {
                      final item = vistas[index];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: const Color(0xff060024),
                            foregroundColor: Colors.white,
                          ),
                          // 🟢 MODIFICADO: Convertimos a async para procesar la URL
                          onPressed: () async {
                            // Llamamos a la función constructora
                            String urlFinal = await _generarUrlDinamica(
                              item['url'], 
                              item['params'] // Pasamos el string de la BD
                            );

                            if (!mounted) return; // Seguridad de contexto

                            Navigator.of(context).push(
                              VistaWebViewScreen.route(
                                item['nombre'],
                                urlFinal, // Enviamos la URL con variables
                              ),
                            );
                          },
                          child: Text(
                            item['nombre'],
                            style: const TextStyle(fontSize: 16),
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