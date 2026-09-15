import 'package:flutter/material.dart';

import '../../domain/models/application_status.dart';
import '../../domain/models/created_project.dart';

/// Insignia de estado con color según la situación de la postulación o del
/// proyecto.
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    required this.foreground,
    required this.background,
  });

  /// Estado de una postulación (Aceptado / En revisión / Rechazado).
  factory StatusBadge.application(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.accepted:
        return StatusBadge(
          label: status.label,
          foreground: const Color(0xFF2E9E5B),
          background: const Color(0xFFE3F5EA),
        );
      case ApplicationStatus.underReview:
        return StatusBadge(
          label: status.label,
          foreground: const Color(0xFFC98A2B),
          background: const Color(0xFFFDF1DC),
        );
      case ApplicationStatus.rejected:
        return StatusBadge(
          label: status.label,
          foreground: const Color(0xFFD45A5A),
          background: const Color(0xFFFBE4E4),
        );
    }
  }

  /// Estado de un proyecto propio (Reclutando / Activo / Completado).
  factory StatusBadge.project(CreatedProjectStatus status) {
    switch (status) {
      case CreatedProjectStatus.recruiting:
        return StatusBadge(
          label: status.label,
          foreground: const Color(0xFFC98A2B),
          background: const Color(0xFFFDF1DC),
        );
      case CreatedProjectStatus.active:
        return StatusBadge(
          label: status.label,
          foreground: const Color(0xFF2E9E5B),
          background: const Color(0xFFE3F5EA),
        );
      case CreatedProjectStatus.completed:
        return StatusBadge(
          label: status.label,
          foreground: const Color(0xFF6B6B6B),
          background: const Color(0xFFECECEC),
        );
    }
  }

  final String label;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: foreground,
        ),
      ),
    );
  }
}
