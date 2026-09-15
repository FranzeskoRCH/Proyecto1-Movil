import 'package:flutter/material.dart';

import '../../domain/models/applicant.dart';

/// Fila de un postulante o integrante del equipo con sus acciones.
///
/// Si [onRemove] está presente muestra la acción de eliminar del equipo; si
/// [onAccept]/[onReject] están presentes muestra aprobar/rechazar.
class ApplicantTile extends StatelessWidget {
  const ApplicantTile({
    super.key,
    required this.applicant,
    this.isProcessing = false,
    this.onAccept,
    this.onReject,
    this.onRemove,
  });

  final Applicant applicant;
  final bool isProcessing;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFECECEC), width: 1.2),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFFEADFD6),
            backgroundImage:
                applicant.avatarUrl.isEmpty ? null : NetworkImage(applicant.avatarUrl),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  applicant.name,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2B2B2B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  applicant.career,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9E9E9E),
                  ),
                ),
                const SizedBox(height: 6),
                _RolePill(label: applicant.requestedRole),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildActions() {
    if (isProcessing) {
      return const SizedBox(
        height: 22,
        width: 22,
        child: CircularProgressIndicator(strokeWidth: 2.2),
      );
    }

    if (onRemove != null) {
      return _IconAction(
        icon: Icons.person_remove_outlined,
        color: const Color(0xFFD45A5A),
        onTap: onRemove!,
      );
    }

    if (onAccept != null && onReject != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _IconAction(
            icon: Icons.check_rounded,
            color: const Color(0xFF2E9E5B),
            onTap: onAccept!,
          ),
          const SizedBox(width: 8),
          _IconAction(
            icon: Icons.close_rounded,
            color: const Color(0xFFD45A5A),
            onTap: onReject!,
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}

class _RolePill extends StatelessWidget {
  const _RolePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF4EFEA),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Color(0xFF6B6B6B),
        ),
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        width: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }
}
