import 'package:flutter/material.dart';

import '../../../../core/date_labels.dart';
import '../../domain/models/project_event.dart';
import '../viewmodels/workspace_controller.dart';

/// Fila de una fecha importante o de un deadline dentro del calendario.
class CalendarEntryTile extends StatelessWidget {
  const CalendarEntryTile({
    super.key,
    required this.entry,
    this.showDate = false,
    this.onDelete,
  });

  final CalendarEntry entry;

  /// Muestra la fecha a la izquierda (para la lista de próximas fechas).
  final bool showDate;
  final VoidCallback? onDelete;

  static IconData _iconFor(ProjectEventKind kind) {
    switch (kind) {
      case ProjectEventKind.milestone:
        return Icons.flag_rounded;
      case ProjectEventKind.meeting:
        return Icons.groups_rounded;
      case ProjectEventKind.delivery:
        return Icons.inventory_2_outlined;
      case ProjectEventKind.other:
        return Icons.star_border_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final task = entry.task;
    final event = entry.event;
    final bool isTask = task != null;
    final bool done = task?.isDone ?? false;

    final Color accent = isTask
        ? (done ? const Color(0xFF2E9E5B) : const Color(0xFF5C5C5C))
        : const Color(0xFFFF7043);
    final String subtitle = isTask
        ? (done
            ? 'Tarea completada'
            : task.assigneeName.isEmpty
                ? 'Deadline de tarea'
                : 'Deadline · ${task.assigneeName}')
        : event!.description.isEmpty
            ? event.kind.label
            : '${event.kind.label} · ${event.description}';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          if (showDate) ...[
            SizedBox(
              width: 44,
              child: Column(
                children: [
                  Text(
                    '${entry.date.day}',
                    style: const TextStyle(
                      fontSize: 18,
                      height: 1.1,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF2B2B2B),
                    ),
                  ),
                  Text(
                    DateLabels.short(entry.date).split(' ').last,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF9E9E9E),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
          ],
          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isTask
                  ? (done ? Icons.check_circle_rounded : Icons.task_alt_rounded)
                  : _iconFor(event!.kind),
              size: 20,
              color: accent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2B2B2B),
                    decoration: done ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9E9E9E),
                  ),
                ),
              ],
            ),
          ),
          if (onDelete != null)
            IconButton(
              onPressed: onDelete,
              tooltip: 'Eliminar fecha',
              icon: const Icon(
                Icons.delete_outline,
                size: 20,
                color: Color(0xFFBDBDBD),
              ),
            ),
        ],
      ),
    );
  }
}
