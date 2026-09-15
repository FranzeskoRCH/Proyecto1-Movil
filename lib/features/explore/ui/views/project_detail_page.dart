import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/section_label.dart';
import '../../../../core/widgets/tag_chip.dart';
import '../viewmodels/project_detail_controller.dart';
import '../widgets/member_avatar.dart';
import '../widgets/project_hero_header.dart';
import '../widgets/role_requirement_row.dart';
import 'request_sent_page.dart';

/// Detalle de un proyecto: visión, roles requeridos y equipo actual.
class ProjectDetailPage extends StatefulWidget {
  const ProjectDetailPage({super.key, required this.projectId});

  final String projectId;

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
  final ProjectDetailController controller = Get.find();

  @override
  void initState() {
    super.initState();
    controller.loadProject(widget.projectId);
  }

  Future<void> _onJoinPressed() async {
    if (controller.project?.requestedToJoin ?? false) return;

    final bool success = await controller.requestToJoin();
    if (success) {
      Get.to(() => RequestSentPage(projectId: widget.projectId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading && controller.project == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final project = controller.project;
        if (project == null) {
          return SafeArea(
            child: Center(
              child: Text(
                'No se pudo cargar el proyecto.',
                style: const TextStyle(color: Color(0xFF6B6B6B)),
              ),
            ),
          );
        }

        return ListView(
          padding: EdgeInsets.zero,
          children: [
            ProjectHeroHeader(imageUrl: project.imageUrl, onBack: Get.back),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: project.categories
                        .map((category) => TagChip(label: category))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    project.title,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2B2B2B),
                    ),
                  ),
                  const SizedBox(height: 8),
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
                  const SizedBox(height: 24),
                  const SectionLabel('ROLES Y HABILIDADES REQUERIDAS'),
                  const SizedBox(height: 12),
                  for (final role in project.roles) ...[
                    RoleRequirementRow(role: role),
                    const SizedBox(height: 10),
                  ],
                  const SizedBox(height: 14),
                  const SectionLabel('EQUIPO ACTUAL'),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 20,
                    runSpacing: 12,
                    children: project.members
                        .map((member) => MemberAvatar(member: member))
                        .toList(),
                  ),
                  const SizedBox(height: 28),
                  _JoinButton(
                    alreadyRequested: project.requestedToJoin,
                    isSubmitting: controller.isSubmitting,
                    onTap: _onJoinPressed,
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _JoinButton extends StatelessWidget {
  const _JoinButton({
    required this.alreadyRequested,
    required this.isSubmitting,
    required this.onTap,
  });

  final bool alreadyRequested;
  final bool isSubmitting;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool disabled = alreadyRequested || isSubmitting;

    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: Container(
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: alreadyRequested
              ? null
              : const LinearGradient(
                  colors: [Color(0xFFFFA741), Color(0xFFFF5252)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
          color: alreadyRequested ? const Color(0xFFE3F5EA) : null,
          borderRadius: BorderRadius.circular(30),
          boxShadow: alreadyRequested
              ? null
              : const [
                  BoxShadow(
                    color: Color(0x33FF5252),
                    blurRadius: 14,
                    offset: Offset(0, 6),
                  ),
                ],
        ),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (isSubmitting) {
      return const SizedBox(
        height: 22,
        width: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.4,
          valueColor: AlwaysStoppedAnimation(Colors.white),
        ),
      );
    }

    if (alreadyRequested) {
      return const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_rounded,
            size: 20,
            color: Color(0xFF2E9E5B),
          ),
          SizedBox(width: 8),
          Text(
            'Solicitud Enviada',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2E9E5B),
            ),
          ),
        ],
      );
    }

    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Solicitar Unirse al Equipo',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        SizedBox(width: 8),
        Icon(Icons.send_rounded, size: 18, color: Colors.white),
      ],
    );
  }
}
