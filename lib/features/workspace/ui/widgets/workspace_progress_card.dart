import 'package:flutter/material.dart';

import '../../../../core/date_labels.dart';
import '../../domain/models/project_task.dart';

/// Tarjeta en degradado con el porcentaje de avance del proyecto, la barra de
/// progreso y un resumen de deadlines.
class WorkspaceProgressCard extends StatelessWidget {
  const WorkspaceProgressCard({
    super.key,
    required this.progress,
    required this.doneCount,
    required this.totalCount,
    required this.overdueCount,
    this.nextDeadline,
  });

  final double progress;
  final int doneCount;
  final int totalCount;
  final int overdueCount;
  final ProjectTask? nextDeadline;

  @override
  Widget build(BuildContext context) {
    final int percent = (progress * 100).round();
    final bool finished = totalCount > 0 && doneCount == totalCount;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFA741), Color(0xFFFF5252)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33FF5252),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Progreso del proyecto',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xE6FFFFFF),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      totalCount == 0
                          ? 'Aún no hay tareas'
                          : finished
                              ? '¡Todas las tareas listas!'
                              : '$doneCount de $totalCount tareas completadas',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$percent%',
                style: const TextStyle(
                  fontSize: 36,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              children: [
                Container(height: 10, color: const Color(0x40FFFFFF)),
                AnimatedFractionallySizedBox(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(height: 10, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoPill(
                icon: Icons.flag_outlined,
                label: nextDeadline == null
                    ? 'Sin deadlines próximos'
                    : 'Próximo: ${DateLabels.relative(nextDeadline!.dueDate!)}',
              ),
              if (overdueCount > 0)
                _InfoPill(
                  icon: Icons.warning_amber_rounded,
                  label: overdueCount == 1
                      ? '1 tarea vencida'
                      : '$overdueCount tareas vencidas',
                  strong: true,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.icon,
    required this.label,
    this.strong = false,
  });

  final IconData icon;
  final String label;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: strong ? Colors.white : const Color(0x33FFFFFF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: strong ? const Color(0xFFD45A5A) : Colors.white,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: strong ? const Color(0xFFD45A5A) : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
