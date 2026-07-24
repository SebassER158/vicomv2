import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:vicomv2/models/tarea_asignada.dart';

/// Tarjeta compartida para mostrar una tarea asignada (realizada o
/// pendiente), usada tanto en el resumen global como en el detalle
/// filtrado por tienda.
class TareaCard extends StatelessWidget {
  final TareaAsignada tarea;

  const TareaCard({Key? key, required this.tarea}) : super(key: key);

  void _openImage(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            PhotoView(
              imageProvider: NetworkImage(url),
              backgroundDecoration: const BoxDecoration(color: Colors.black87),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 2.5,
            ),
            Positioned(
              top: 40,
              right: 12,
              child: GestureDetector(
                onTap: () => Navigator.pop(ctx),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20)),
                  child: const Icon(Icons.close, color: Colors.white, size: 22),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _brokenImage(double width, double height) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: Icon(Icons.image_not_supported_outlined,
          color: Colors.grey[400], size: width * 0.4),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = tarea.isCompleted ? Colors.green : Colors.orange;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3))
        ],
        border: Border.all(color: accent.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (tarea.tienda.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xff060024).withOpacity(0.06),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.store_mall_directory_rounded,
                          size: 13, color: Color(0xff060024)),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          tarea.tienda,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Color(0xff060024),
                              fontSize: 11,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => _openImage(context, tarea.imageUrl),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        tarea.imageUrl,
                        width: 60,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _brokenImage(60, 80),
                      )),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              size: 13, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(tarea.fechaDisplay,
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(tarea.opcion,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Color(0xff060024),
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                      const SizedBox(height: 4),
                      Text(tarea.comentario,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(tarea.isCompleted ? 'Realizada' : 'Pendiente',
                      style: TextStyle(
                          color: accent,
                          fontSize: 11,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            if (tarea.isCompleted && tarea.fechaRetroDisplay != null) ...[
              const Divider(height: 20),
              Row(
                children: [
                  if (tarea.retroImageUrl != null)
                    GestureDetector(
                      onTap: () => _openImage(context, tarea.retroImageUrl!),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            tarea.retroImageUrl!,
                            width: 50,
                            height: 65,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _brokenImage(50, 65),
                          )),
                    ),
                  if (tarea.retroImageUrl != null) const SizedBox(width: 12),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Retroalimentación',
                          style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 11,
                              fontWeight: FontWeight.bold)),
                      if (tarea.promotor != null && tarea.promotor!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2, bottom: 2),
                          child: Row(
                            children: [
                              const Icon(Icons.person_rounded,
                                  size: 12, color: Color(0xff007DA4)),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  tarea.promotor!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: Color(0xff007DA4),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      Text(tarea.fechaRetroDisplay!,
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 11)),
                      if (tarea.comentarioRetro != null &&
                          tarea.comentarioRetro!.isNotEmpty)
                        Text(tarea.comentarioRetro!,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Color(0xff060024), fontSize: 12)),
                    ],
                  )),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
