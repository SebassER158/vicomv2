import 'package:flutter/material.dart';
import 'package:vicomv2/models/tarea_asignada.dart';
import 'package:vicomv2/widgets/tarea_card.dart';
import 'package:vicomv2/widgets/tienda_filter_chips.dart';

/// Lista completa (sin límite) de tareas asignadas realizadas o pendientes,
/// con filtro por tienda. Se llega aquí desde el "Ver más" de TareasGlobal.
class TareasGlobalDetalle extends StatefulWidget {
  final String titulo;
  final List<TareaAsignada> tareas;
  final String? tiendaInicial;

  const TareasGlobalDetalle({
    Key? key,
    required this.titulo,
    required this.tareas,
    this.tiendaInicial,
  }) : super(key: key);

  static Route<dynamic> route({
    required String titulo,
    required List<TareaAsignada> tareas,
    String? tiendaInicial,
  }) {
    return MaterialPageRoute(
      builder: (context) => TareasGlobalDetalle(
          titulo: titulo, tareas: tareas, tiendaInicial: tiendaInicial),
    );
  }

  @override
  State<TareasGlobalDetalle> createState() => _TareasGlobalDetalleState();
}

class _TareasGlobalDetalleState extends State<TareasGlobalDetalle> {
  late String? _tiendaSeleccionada = widget.tiendaInicial;

  List<String> get _tiendas {
    final nombres = widget.tareas
        .map((t) => t.tienda)
        .where((t) => t.isNotEmpty)
        .toSet()
        .toList();
    nombres.sort();
    return nombres;
  }

  List<TareaAsignada> get _tareasFiltradas {
    final ordenadas = [...widget.tareas]
      ..sort((a, b) => b.fecha.compareTo(a.fecha));
    if (_tiendaSeleccionada == null) return ordenadas;
    return ordenadas.where((t) => t.tienda == _tiendaSeleccionada).toList();
  }

  @override
  Widget build(BuildContext context) {
    final tareasFiltradas = _tareasFiltradas;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Montserrat'),
      home: Scaffold(
        backgroundColor: Colors.grey[100],
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Container(
                color: const Color(0xff060024),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        widget.titulo,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              // FILTRO POR TIENDA
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: TiendaFilterChips(
                  tiendas: _tiendas,
                  seleccionada: _tiendaSeleccionada,
                  onChanged: (tienda) =>
                      setState(() => _tiendaSeleccionada = tienda),
                ),
              ),

              Expanded(
                child: tareasFiltradas.isEmpty
                    ? Center(
                        child: Text(
                          'Sin tareas para esta tienda',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: tareasFiltradas.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (ctx, i) =>
                            TareaCard(tarea: tareasFiltradas[i]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
