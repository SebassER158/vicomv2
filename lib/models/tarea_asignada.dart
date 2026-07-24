import 'package:intl/intl.dart';
import 'package:vicomv2/apis/api.dart';

class TareaAsignada {
  final String tienda;
  final String imageUrl;
  final String? retroImageUrl;
  final DateTime fecha;
  final String opcion;
  final String comentario;
  final bool isCompleted;
  final DateTime? fechaRetro;
  final String? comentarioRetro;
  final String? promotor;

  TareaAsignada({
    required this.tienda,
    required this.imageUrl,
    this.retroImageUrl,
    required this.fecha,
    required this.opcion,
    required this.comentario,
    required this.isCompleted,
    this.fechaRetro,
    this.comentarioRetro,
    this.promotor,
  });

  factory TareaAsignada.fromJson(Map<String, dynamic> json,
      {required bool isCompleted}) {
    final fecha = DateTime.parse(json['fecha']).toLocal().add(
        Duration(hours: isCompleted ? -2 : -1));

    DateTime? fechaRetro;
    if (isCompleted && json['fecha_retro'] != null) {
      fechaRetro = DateTime.parse(json['fecha_retro'])
          .toLocal()
          .add(const Duration(hours: -2));
    }

    return TareaAsignada(
      tienda: json['tienda']?.toString() ?? '',
      imageUrl: Api.buildImageUrl(json['imgF']),
      retroImageUrl:
          isCompleted ? Api.buildImageUrl(json['imgF_retro']) : null,
      fecha: fecha,
      opcion: json['opcion']?.toString() ?? '',
      comentario: json['comentario']?.toString() ?? '',
      isCompleted: isCompleted,
      fechaRetro: fechaRetro,
      comentarioRetro: json['comentario_retro']?.toString(),
      promotor: isCompleted ? json['promotor']?.toString() : null,
    );
  }

  String get fechaDisplay => isCompleted
      ? DateFormat('dd-MM-yyyy HH:mm').format(fecha)
      : DateFormat('dd-MM-yyyy').format(fecha);

  String? get fechaRetroDisplay =>
      fechaRetro != null ? DateFormat('dd-MM-yyyy HH:mm').format(fechaRetro!) : null;
}
