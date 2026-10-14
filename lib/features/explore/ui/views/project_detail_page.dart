import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/project_share.dart';
import '../../../../core/roble_error_handler.dart';
import '../../../../core/roble_service.dart';
import '../../../../core/widgets/app_confirm_dialog.dart';
import '../../../../core/widgets/section_label.dart';
import '../../../../core/widgets/tag_chip.dart';
import '../../../profile/ui/views/public_profile_page.dart';
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

  Future<void> _confirmCancel(String title) async {
    final bool confirmed = await showAppConfirmDialog(
      title: 'Cancelar postulación',
      message: '¿Retirar tu postulación a "$title"?',
      confirmText: 'Sí, cancelar',
      confirmColor: const Color(0xFFD32F2F),
      icon: Icons.cancel_outlined,
    );
    if (confirmed) {
      await _onCancelPressed();
    }
  }

  Future<void> _onCancelPressed() async {
    final bool ok = await controller.cancelRequest();
    if (!mounted) return;
    if (ok) {
      RobleErrorHandler.showSuccessSnackbar(
        title: 'Postulación cancelada',
        message: 'Ya no apareces como postulante en este proyecto.',
      );
    } else {
      RobleErrorHandler.showErrorSnackbar(
        title: 'No se pudo cancelar',
        error: 'Intenta de nuevo en unos segundos.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading && controller.project == null) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFFF7043)),
          );
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
            ProjectHeroHeader(
              imageUrl: project.imageUrl,
              onBack: Get.back,
              onShare: () => shareProject(
                context,
                projectId: project.id,
                title: project.title,
                description: project.description,
              ),
            ),
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
                  _AuthorTile(
                    authorName: project.authorName,
                    authorCareer: project.authorCareer,
                    authorAvatarUrl: project.authorAvatarUrl,
                    onTap: project.authorId.isEmpty
                        ? null
                        : () => Get.to(
                              () => PublicProfilePage(
                                userId: project.authorId,
                                fallbackName: project.authorName,
                                fallbackCareer: project.authorCareer,
                                fallbackAvatarUrl: project.authorAvatarUrl,
                              ),
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
                  if (project.roles.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    const Text(
                      'Elige el rol al que quieres postularte.',
                      style:
                          TextStyle(fontSize: 12.5, color: Color(0xFF9E9E9E)),
                    ),
                  ],
                  const SizedBox(height: 12),
                  for (final role in project.roles) ...[
                    RoleRequirementRow(
                      role: role,
                      selected: controller.selectedRole == role.name,
                      onTap: () => controller.selectRole(role.name),
                    ),
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
                  Builder(
                    builder: (_) {
                      final currentUserId = RobleService().currentUserId;
                      final isOwner = project.authorId.isNotEmpty &&
                          project.authorId == currentUserId;
                      if (isOwner) return const _OwnerBadge();
                      if (project.requestedToJoin) {
                        return _CancelRequestButton(
                          isSubmitting: controller.isSubmitting,
                          onTap: () => _confirmCancel(project.title),
                        );
                      }
                      return _JoinButton(
                        alreadyRequested: project.requestedToJoin,
                        isSubmitting: controller.isSubmitting,
                        canSubmit: project.roles.isEmpty ||
                            controller.selectedRole != null,
                        onTap: _onJoinPressed,
                      );
                    },
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

// ── Autor del proyecto (tappable → perfil público) ──────────────────────────
class _AuthorTile extends StatelessWidget {
  const _AuthorTile({
    required this.authorName,
    required this.authorCareer,
    required this.authorAvatarUrl,
    this.onTap,
  });

  final String authorName;
  final String authorCareer;
  final String authorAvatarUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFFEADFD6),
            backgroundImage: authorAvatarUrl.isNotEmpty
                ? NetworkImage(authorAvatarUrl)
                : null,
            child: authorAvatarUrl.isEmpty
                ? const Icon(Icons.person, size: 20, color: Color(0xFF9E9E9E))
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Propuesto por $authorName',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4A4A4A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Carrera: $authorCareer',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF9E9E9E),
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null)
            const Icon(Icons.chevron_right, size: 20, color: Color(0xFF9E9E9E)),
        ],
      ),
    );
  }
}

// ── Badge mostrado al creador del proyecto ─────────────────────────────────
class _OwnerBadge extends StatelessWidget {
  const _OwnerBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(30),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.star_rounded, size: 20, color: Color(0xFFFFAA00)),
          SizedBox(width: 8),
          Text(
            'Eres el creador de este proyecto',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF6B6B6B),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Botón para retirar una postulación enviada ──────────────────────────────
class _CancelRequestButton extends StatelessWidget {
  const _CancelRequestButton({
    required this.isSubmitting,
    required this.onTap,
  });

  final bool isSubmitting;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isSubmitting ? null : onTap,
      child: Container(
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFFDECEA),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFFD32F2F), width: 1.4),
        ),
        child: isSubmitting
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: Color(0xFFD32F2F),
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cancel_outlined,
                    size: 18,
                    color: Color(0xFFD32F2F),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Cancelar postulación',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFD32F2F),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ── Botón de solicitud ───────────────────────────────────────────────────────
class _JoinButton extends StatelessWidget {
  const _JoinButton({
    required this.alreadyRequested,
    required this.isSubmitting,
    required this.canSubmit,
    required this.onTap,
  });

  final bool alreadyRequested;
  final bool isSubmitting;
  final bool canSubmit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool disabled = alreadyRequested || isSubmitting || !canSubmit;

    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: Container(
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: (!alreadyRequested && canSubmit)
              ? const LinearGradient(
                  colors: [Color(0xFFFFA741), Color(0xFFFF5252)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          color: alreadyRequested
              ? const Color(0xFFE3F5EA)
              : (canSubmit ? null : const Color(0xFFE6E6E6)),
          borderRadius: BorderRadius.circular(30),
          boxShadow: (!alreadyRequested && canSubmit)
              ? const [
                  BoxShadow(
                    color: Color(0x33FF5252),
                    blurRadius: 14,
                    offset: Offset(0, 6),
                  ),
                ]
              : null,
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
          Icon(Icons.check_circle_rounded, size: 20, color: Color(0xFF2E9E5B)),
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
