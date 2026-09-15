import 'package:flutter/material.dart';

import '../../../../core/widgets/tag_chip.dart';
import '../../domain/models/project.dart';
import 'match_badge.dart';

/// Tarjeta de un proyecto dentro de la lista de exploración.
class ProjectCard extends StatelessWidget {
  const ProjectCard({
    super.key,
    required this.project,
    required this.onViewProject,
  });

  final Project project;
  final VoidCallback onViewProject;

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
          _AuthorRow(project: project),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (int i = 0; i < project.categories.length; i++)
                TagChip(
                  label: project.categories[i],
                  variant: i == 0
                      ? TagChipVariant.accent
                      : TagChipVariant.neutral,
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            project.title,
            style: const TextStyle(
              fontSize: 20,
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
          if (project.roles.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 18,
              runSpacing: 10,
              children: project.roles
                  .map((role) => _RolePreview(name: role.name))
                  .toList(),
            ),
          ],
          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 1, color: Color(0xFFECECEC)),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '${project.vacancies} vacantes',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF9E9E9E),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onViewProject,
                child: const Row(
                  children: [
                    Text(
                      'Ver Proyecto',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFF0552F),
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: Color(0xFFF0552F),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AuthorRow extends StatelessWidget {
  const _AuthorRow({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 22,
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
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2B2B2B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                project.authorCareer,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF9E9E9E),
                ),
              ),
            ],
          ),
        ),
        MatchBadge(matchPercentage: project.matchPercentage),
      ],
    );
  }
}

/// Vista previa de un rol requerido con un icono según su temática.
class _RolePreview extends StatelessWidget {
  const _RolePreview({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(_iconFor(name), size: 16, color: const Color(0xFF9E9E9E)),
        const SizedBox(width: 6),
        Text(
          name,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            color: Color(0xFF4A4A4A),
          ),
        ),
      ],
    );
  }

  IconData _iconFor(String role) {
    final value = role.toLowerCase();
    if (value.contains('visión') || value.contains('computadora')) {
      return Icons.visibility_outlined;
    }
    if (value.contains('diseño') || value.contains('ui')) {
      return Icons.brush_outlined;
    }
    if (value.contains('ciencias')) {
      return Icons.science_outlined;
    }
    if (value.contains('modelo') || value.contains('negocio')) {
      return Icons.trending_up;
    }
    if (value.contains('biomédica')) {
      return Icons.biotech_outlined;
    }
    if (value.contains('iot')) {
      return Icons.memory_outlined;
    }
    if (value.contains('gestión')) {
      return Icons.groups_outlined;
    }
    return Icons.work_outline;
  }
}
