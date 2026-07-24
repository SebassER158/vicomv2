import 'package:flutter/material.dart';

/// Fila horizontal de chips para filtrar por tienda ("Todas" + una por
/// cada tienda). Se usa tanto en el resumen global como en los detalles
/// de "Ver más", así que cualquier ajuste visual se hace una sola vez aquí.
class TiendaFilterChips extends StatelessWidget {
  final List<String> tiendas;
  final String? seleccionada;
  final ValueChanged<String?> onChanged;

  const TiendaFilterChips({
    Key? key,
    required this.tiendas,
    required this.seleccionada,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _chip(label: 'Todas', value: null),
          for (final tienda in tiendas) _chip(label: tienda, value: tienda),
        ],
      ),
    );
  }

  Widget _chip({required String label, required String? value}) {
    final selected = seleccionada == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onChanged(value),
        selectedColor: const Color(0xff007DA4),
        backgroundColor: Colors.grey[200],
        labelStyle: TextStyle(
          color: selected ? Colors.white : const Color(0xff060024),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide.none,
        ),
      ),
    );
  }
}
