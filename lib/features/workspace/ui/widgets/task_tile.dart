import 'package:flutter/material.dart';

import '../../../../core/date_labels.dart';
import '../../domain/models/project_task.dart';

/// Tarjeta de una tarea: casilla para completarla, responsable y deadline.
class TaskTile extends StatelessWidget {
  const TaskTile({
    super.key,
    required this.task,
    required this.onToggle,
    this.onDelete,
  });

  final ProjectTask task;
  final VoidCallback onToggle;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final bool overdue = task.isOverdue();

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 8, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: overdue
            ? Border.all(color: const Color(0xFFF3C4C4), width: 1.2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CheckCircle(done: task.isDone, onTap: onToggle),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: task.isDone
                        ? const Color(0xFF9E9E9E)
                        : const Color(0xFF2B2B2B),
                    decoration:
                        task.isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (task.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    task.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.35,
                      color: Color(0xFF757575),
                    ),
                  ),
                ],
                if (task.hasAssignee || task.dueDate != null) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      if (task.dueDate != null) _DueChip(task: task),
                      if (task.hasAssignee)
                        _MetaChip(
                          icon: Icons.person_outline,
                          label: task.assigneeName.isEmpty
                              ? 'Asignada'
                              : task.assigneeName,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (onDelete != null)
            SizedBox(
              height: 32,
              width: 32,
              child: PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                iconSize: 20,
                tooltip: 'Opciones',
                icon: const Icon(Icons.more_vert, color: Color(0xFFBDBDBD)),
                onSelected: (_) => onDelete!(),
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: Color(0xFFD32F2F),
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Eliminar tarea',
                          style: TextStyle(color: Color(0xFFD32F2F)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _CheckCircle extends StatelessWidget {
  const _CheckCircle({required this.done, required this.onTap});

  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 26,
        width: 26,
        margin: const EdgeInsets.only(top: 1),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: done
              ? const LinearGradient(
                  colors: [Color(0xFFFFA741), Color(0xFFFF5252)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          border: done
              ? null
              : Border.all(color: const Color(0xFFD6CCC2), width: 2),
        ),
        child: done
            ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
            : null,
      ),
    );
  }
}

class _DueChip extends StatelessWidget {
  const _DueChip({required this.task});

  final ProjectTask task;

  @override
  Widget build(BuildContext context) {
    final due = task.dueDate!;
    final daysLeft = DateLabels.dateOnly(due)
        .difference(DateLabels.dateOnly(DateTime.now()))
        .inDays;

    Color fg = const Color(0xFF6B6B6B);
    Color bg = const Color(0xFFF4EFEA);
    if (task.isDone) {
      fg = const Color(0xFF2E9E5B);
      bg = const Color(0xFFE3F5EA);
    } else if (daysLeft < 0) {
      fg = const Color(0xFFD45A5A);
      bg = const Color(0xFFFBE4E4);
    } else if (daysLeft <= 2) {
      fg = const Color(0xFFC98A2B);
      bg = const Color(0xFFFDF1DC);
    }

    return _MetaChip(
      icon: daysLeft < 0 && !task.isDone
          ? Icons.warning_amber_rounded
          : Icons.event_outlined,
      label: daysLeft < 0 && !task.isDone
          ? 'Venció ${DateLabels.relative(due).toLowerCase()}'
          : DateLabels.relative(due),
      foreground: fg,
      background: bg,
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
    this.foreground = const Color(0xFF6B6B6B),
    this.background = const Color(0xFFF4EFEA),
  });

  final IconData icon;
  final String label;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: foreground),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}
