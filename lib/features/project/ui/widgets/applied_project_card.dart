import 'package:flutter/material.dart';

import '../../domain/models/application_status.dart';
import '../../domain/models/applied_project.dart';
import 'status_badge.dart';

/// Tarjeta de un proyecto aplicado en la pestaña "Aplicados".
class AppliedProjectCard extends StatelessWidget {
  const AppliedProjectCard({
    super.key,
    required this.project,
    required this.onViewDetails,
    this.onWithdraw,
  });

  final AppliedProject project;
  final VoidCallback onViewDetails;

  /// Si se provee, muestra "Cancelar postulación" (solo en revisión).
  final VoidCallback? onWithdraw;

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
              StatusBadge.application(project.status),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            project.title,
            style: const TextStyle(
              fontSize: 19,
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
          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 1, color: Color(0xFFECECEC)),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Aplicado el ${project.appliedDate}',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF9E9E9E),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onViewDetails,
                child: const Row(
                  children: [
                    Text(
                      'Ver detalles',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFF0552F),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: Color(0xFFF0552F),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (onWithdraw != null &&
              project.status == ApplicationStatus.underReview) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onWithdraw,
                icon: const Icon(Icons.undo_rounded, size: 16),
                label: const Text(
                  'Cancelar postulación',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFF0552F),
                  side: const BorderSide(color: Color(0xFFF0552F)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
