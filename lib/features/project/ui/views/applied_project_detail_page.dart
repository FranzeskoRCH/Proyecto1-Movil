import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/section_label.dart';
import '../../../../core/widgets/tag_chip.dart';
import '../../domain/models/applied_project.dart';
import '../widgets/status_badge.dart';

/// Detalle de solo lectura de un proyecto aplicado.
class AppliedProjectDetailPage extends StatelessWidget {
  const AppliedProjectDetailPage({super.key, required this.project});

  final AppliedProject project;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            _BackButton(onBack: Get.back),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: StatusBadge.application(project.status),
            ),
            const SizedBox(height: 14),
            Text(
              project.title,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Color(0xFF2B2B2B),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Propuesto por ${project.authorName}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4A4A4A),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Carrera: ${project.authorCareer}',
              style: const TextStyle(
                fontSize: 12.5,
                color: Color(0xFF9E9E9E),
              ),
            ),
            if (project.categories.isNotEmpty) ...[
              const SizedBox(height: 18),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: project.categories
                    .map((category) => TagChip(label: category))
                    .toList(),
              ),
            ],
            const SizedBox(height: 24),
            const SectionLabel('POSTULACIÓN'),
            const SizedBox(height: 8),
            Text(
              'Aplicaste el ${project.appliedDate}',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF4A4A4A),
              ),
            ),
            const SizedBox(height: 24),
            const SectionLabel('DESCRIPCIÓN'),
            const SizedBox(height: 10),
            Text(
              project.description,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Color(0xFF4A4A4A),
              ),
            ),
            if (project.vision.isNotEmpty) ...[
              const SizedBox(height: 24),
              const SectionLabel('VISIÓN DEL PROYECTO'),
              const SizedBox(height: 10),
              Text(
                project.vision,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Color(0xFF4A4A4A),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onBack,
      child: Container(
        height: 40,
        width: 40,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.arrow_back,
          size: 20,
          color: Color(0xFF2B2B2B),
        ),
      ),
    );
  }
}
