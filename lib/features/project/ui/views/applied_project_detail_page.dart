import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/section_label.dart';
import '../../../../core/widgets/tag_chip.dart';
import '../../../explore/ui/widgets/project_hero_header.dart';
import '../../domain/models/application_status.dart';
import '../../domain/models/applied_project.dart';
import '../widgets/status_badge.dart';

/// Detalle de solo lectura de un proyecto aplicado, con el seguimiento del
/// estado de la postulación.
class AppliedProjectDetailPage extends StatelessWidget {
  const AppliedProjectDetailPage({super.key, required this.project});

  final AppliedProject project;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          ProjectHeroHeader(onBack: Get.back),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (project.categories.isNotEmpty) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: project.categories
                        .map((category) => TagChip(label: category))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                ],
                Text(
                  project.title,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2B2B2B),
                  ),
                ),
                const SizedBox(height: 10),
                _AuthorRow(
                  name: project.authorName,
                  career: project.authorCareer,
                  avatarUrl: project.authorAvatarUrl,
                ),
                const SizedBox(height: 24),
                const SectionLabel('TU POSTULACIÓN'),
                const SizedBox(height: 12),
                _ApplicationStatusCard(
                  status: project.status,
                  appliedDate: project.appliedDate,
                ),
                const SizedBox(height: 24),
                const SectionLabel('DESCRIPCIÓN'),
                const SizedBox(height: 10),
                _Paragraph(project.description),
                if (project.vision.isNotEmpty &&
                    project.vision != project.description) ...[
                  const SizedBox(height: 24),
                  const SectionLabel('VISIÓN DEL PROYECTO'),
                  const SizedBox(height: 10),
                  _Paragraph(project.vision),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthorRow extends StatelessWidget {
  const _AuthorRow({
    required this.name,
    required this.career,
    required this.avatarUrl,
  });

  final String name;
  final String career;
  final String avatarUrl;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: const Color(0xFFEADFD6),
          backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
          child: avatarUrl.isEmpty
              ? const Icon(Icons.person, size: 20, color: Color(0xFF9E9E9E))
              : null,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Propuesto por $name',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4A4A4A),
                ),
              ),
              if (career.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  'Carrera: $career',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF9E9E9E),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Paragraph extends StatelessWidget {
  const _Paragraph(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.isEmpty ? 'Sin descripción.' : text,
      style: const TextStyle(
        fontSize: 14,
        height: 1.5,
        color: Color(0xFF4A4A4A),
      ),
    );
  }
}

// ── Tarjeta con el estado y la línea de tiempo de la postulación ───────────
class _ApplicationStatusCard extends StatelessWidget {
  const _ApplicationStatusCard({
    required this.status,
    required this.appliedDate,
  });

  final ApplicationStatus status;
  final String appliedDate;

  @override
  Widget build(BuildContext context) {
    final style = _StatusStyle.of(status);
    final bool resolved = status != ApplicationStatus.underReview;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: style.background,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(style.icon, color: style.foreground, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StatusBadge.application(status),
                    const SizedBox(height: 8),
                    Text(
                      style.message,
                      style: const TextStyle(
                        fontSize: 13.5,
                        height: 1.4,
                        color: Color(0xFF4A4A4A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(height: 1, color: Color(0xFFF0EBE6)),
          const SizedBox(height: 18),
          _TimelineStep(
            title: 'Postulación enviada',
            subtitle: appliedDate.isEmpty ? null : 'El $appliedDate',
            color: const Color(0xFF2E9E5B),
            done: true,
          ),
          _TimelineStep(
            title: 'En revisión por el autor',
            color: resolved ? const Color(0xFF2E9E5B) : style.foreground,
            done: resolved,
            current: !resolved,
          ),
          _TimelineStep(
            title: resolved ? status.label : 'Respuesta del equipo',
            color: resolved ? style.foreground : const Color(0xFFBDBDBD),
            done: resolved,
            current: resolved,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.title,
    required this.color,
    this.subtitle,
    this.done = false,
    this.current = false,
    this.isLast = false,
  });

  final String title;
  final String? subtitle;
  final Color color;
  final bool done;
  final bool current;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final bool active = done || current;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                height: 20,
                width: 20,
                decoration: BoxDecoration(
                  color: active ? color : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: active ? color : const Color(0xFFE0D8CF),
                    width: 2,
                  ),
                ),
                child: done
                    ? const Icon(Icons.check, size: 12, color: Colors.white)
                    : null,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: done ? color : const Color(0xFFE0D8CF),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: current ? FontWeight.w700 : FontWeight.w600,
                      color: active
                          ? const Color(0xFF2B2B2B)
                          : const Color(0xFF9E9E9E),
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF9E9E9E),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusStyle {
  const _StatusStyle({
    required this.foreground,
    required this.background,
    required this.icon,
    required this.message,
  });

  final Color foreground;
  final Color background;
  final IconData icon;
  final String message;

  static _StatusStyle of(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.accepted:
        return const _StatusStyle(
          foreground: Color(0xFF2E9E5B),
          background: Color(0xFFE3F5EA),
          icon: Icons.celebration_outlined,
          message: '¡Felicidades! Ya formas parte del equipo de este proyecto.',
        );
      case ApplicationStatus.underReview:
        return const _StatusStyle(
          foreground: Color(0xFFC98A2B),
          background: Color(0xFFFDF1DC),
          icon: Icons.hourglass_top_rounded,
          message:
              'El autor está revisando tu perfil. Verás el resultado aquí en cuanto responda.',
        );
      case ApplicationStatus.rejected:
        return const _StatusStyle(
          foreground: Color(0xFFD45A5A),
          background: Color(0xFFFBE4E4),
          icon: Icons.info_outline_rounded,
          message:
              'Esta vez no fuiste seleccionado. Sigue explorando otros proyectos afines a ti.',
        );
    }
  }
}
