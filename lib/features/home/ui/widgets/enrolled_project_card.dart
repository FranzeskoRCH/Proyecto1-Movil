import 'package:flutter/material.dart';

import '../../domain/models/enrolled_project.dart';

/// Tarjeta de un proyecto en el que el colaborador ya participa (aceptado).
class EnrolledProjectCard extends StatelessWidget {
  const EnrolledProjectCard({super.key, required this.project, this.onLeave});

  final EnrolledProject project;

  /// Si se provee y es miembro, muestra "Salir del equipo".
  final VoidCallback? onLeave;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFFEADFD6),
                backgroundImage: NetworkImage(project.authorAvatarUrl),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.authorName,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2B2B2B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Creador',
                      style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
                    ),
                  ],
                ),
              ),
              if (project.isMember)
                const _AcceptedBadge()
              else
                _StatusChip(label: project.role),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            project.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF2B2B2B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            project.description,
            style: const TextStyle(
              fontSize: 13.5,
              height: 1.4,
              color: Color(0xFF6B6B6B),
            ),
          ),
          if (project.isMember) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                _RolePill(label: 'Tu rol: ${project.role}'),
                const Spacer(),
                if (onLeave != null)
                  GestureDetector(
                    onTap: onLeave,
                    child: const Row(
                      children: [
                        Icon(Icons.logout, size: 15, color: Color(0xFFD45A5A)),
                        SizedBox(width: 4),
                        Text(
                          'Salir del equipo',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFD45A5A),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final bool rejected = label.toLowerCase().contains('rechaz');
    final Color color = rejected
        ? const Color(0xFFD45A5A)
        : const Color(0xFFC98A2B);
    final Color background = rejected
        ? const Color(0xFFFBE4E4)
        : const Color(0xFFFDF1DC);

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
          color: color,
        ),
      ),
    );
  }
}

class _AcceptedBadge extends StatelessWidget {
  const _AcceptedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F5EA),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_rounded, size: 13, color: Color(0xFF2E9E5B)),
          SizedBox(width: 4),
          Text(
            'Aceptado',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2E9E5B),
            ),
          ),
        ],
      ),
    );
  }
}

class _RolePill extends StatelessWidget {
  const _RolePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF4EFEA),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: Color(0xFF6B6B6B),
        ),
      ),
    );
  }
}
