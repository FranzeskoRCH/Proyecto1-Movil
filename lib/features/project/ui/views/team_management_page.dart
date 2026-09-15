import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/section_label.dart';
import '../viewmodels/team_management_controller.dart';
import '../widgets/applicant_tile.dart';

/// Gestión del equipo de un proyecto propio: postulantes pendientes y
/// equipo actual.
class TeamManagementPage extends StatefulWidget {
  const TeamManagementPage({super.key, required this.projectId});

  final String projectId;

  @override
  State<TeamManagementPage> createState() => _TeamManagementPageState();
}

class _TeamManagementPageState extends State<TeamManagementPage> {
  final TeamManagementController controller = Get.find();

  @override
  void initState() {
    super.initState();
    controller.loadProject(widget.projectId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading && controller.project == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final project = controller.project;
          if (project == null) {
            return const Center(
              child: Text(
                'No se pudo cargar el proyecto.',
                style: TextStyle(color: Color(0xFF6B6B6B)),
              ),
            );
          }

          final pending = project.pendingApplicants;
          final team = project.teamMembers;

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              _Header(onBack: Get.back, title: project.title),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _SummaryChip(
                    icon: Icons.work_outline,
                    label: '${project.vacancies} vacantes',
                  ),
                  _SummaryChip(
                    icon: Icons.groups_outlined,
                    label: '${team.length} en equipo',
                  ),
                  _SummaryChip(
                    icon: Icons.hourglass_empty,
                    label: '${pending.length} pendientes',
                  ),
                ],
              ),
              const SizedBox(height: 26),
              const SectionLabel('POSTULANTES PENDIENTES'),
              const SizedBox(height: 12),
              if (pending.isEmpty)
                const _EmptyText('No hay postulantes pendientes.')
              else
                for (final applicant in pending) ...[
                  ApplicantTile(
                    applicant: applicant,
                    isProcessing: controller.processingId == applicant.id,
                    onAccept: () => controller.accept(applicant.id),
                    onReject: () => controller.reject(applicant.id),
                  ),
                  const SizedBox(height: 10),
                ],
              const SizedBox(height: 16),
              const SectionLabel('EQUIPO ACTUAL'),
              const SizedBox(height: 12),
              if (team.isEmpty)
                const _EmptyText('Aún no hay integrantes en el equipo.')
              else
                for (final member in team) ...[
                  ApplicantTile(
                    applicant: member,
                    isProcessing: controller.processingId == member.id,
                    onRemove: () => controller.remove(member.id),
                  ),
                  const SizedBox(height: 10),
                ],
            ],
          );
        }),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack, required this.title});

  final VoidCallback onBack;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
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
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Gestionar Equipo',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF9E9E9E),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF2B2B2B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFECECEC), width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF9E9E9E)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4A4A4A),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyText extends StatelessWidget {
  const _EmptyText(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: const TextStyle(
        fontSize: 13.5,
        color: Color(0xFF9E9E9E),
      ),
    );
  }
}
