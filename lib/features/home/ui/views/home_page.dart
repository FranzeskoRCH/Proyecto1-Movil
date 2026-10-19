import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/app_confirm_dialog.dart';
import '../../../../core/widgets/brand_logo.dart';
import '../../../workspace/ui/views/project_workspace_page.dart';
import '../../domain/models/enrolled_project.dart';
import '../viewmodels/home_controller.dart';
import '../widgets/action_card_row.dart';
import '../widgets/enrolled_project_card.dart';
import '../widgets/greeting_header.dart';

/// Contenido de la pestaña "Inicio".
///
/// Es "tonta": solo reacciona al estado que expone [HomeController]. La barra
/// de navegación y el cambio de pestaña los maneja [MainShell].
class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.onCreateTap,
    required this.onExploreTap,
    required this.onProfileTap,
  });

  final VoidCallback onCreateTap;
  final VoidCallback onExploreTap;
  final VoidCallback onProfileTap;

  static const String _subtitle =
      'Encuentra tu próximo proyecto interdisciplinario.';
  static const String _projectsTitle = 'Proyectos en los que participas';

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find();

    return Obx(() {
      if (controller.isLoading && controller.profile == null) {
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFFFF7043)),
        );
      }

      final profile = controller.profile;
      if (profile == null) {
        return const Center(child: Text('No se pudo cargar el perfil.'));
      }

      final members =
          controller.enrolledProjects.where((p) => p.isMember).toList();
      final applied =
          controller.enrolledProjects.where((p) => !p.isMember).toList();
      // Las etiquetas de grupo solo aportan cuando hay de los dos tipos.
      final showGroups = members.isNotEmpty && applied.isNotEmpty;

      return RefreshIndicator(
        color: const Color(0xFFFF7043),
        onRefresh: () => controller.loadHome(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            BrandLogo(avatarUrl: profile.avatarUrl, onAvatarTap: onProfileTap),
            const SizedBox(height: 16),
            GreetingHeader(name: profile.name, subtitle: _subtitle),
            const SizedBox(height: 20),
            ActionCardRow(onCreateTap: onCreateTap, onExploreTap: onExploreTap),
            const SizedBox(height: 28),
            const Text(
              _projectsTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2B2B2B),
              ),
            ),
            const SizedBox(height: 14),
            if (controller.enrolledProjects.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE0D8CF)),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.folder_open_rounded,
                      size: 40,
                      color: Color(0xFFBDBDBD),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Aún no participas en ningún proyecto.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Color(0xFF757575)),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: onExploreTap,
                      child: const Text(
                        'Explorar proyectos disponibles',
                        style: TextStyle(
                          color: Color(0xFFFF7043),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              if (members.isNotEmpty) ...[
                if (showGroups) _GroupLabel('En tu equipo'),
                for (final project in members) ...[
                  EnrolledProjectCard(
                    project: project,
                    onLeave: () => _confirmLeave(controller, project),
                    onOpenWorkspace: () => Get.to(
                      () => ProjectWorkspacePage(
                        projectId: project.id,
                        projectTitle: project.title,
                        isOwner: false,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
              ],
              if (applied.isNotEmpty) ...[
                if (showGroups) _GroupLabel('Tus postulaciones', divider: true),
                for (final project in applied) ...[
                  EnrolledProjectCard(project: project),
                  const SizedBox(height: 14),
                ],
              ],
            ],
            const SizedBox(height: 10),
          ],
        ),
      );
    });
  }

  Future<void> _confirmLeave(
    HomeController controller,
    EnrolledProject project,
  ) async {
    final bool confirmed = await showAppConfirmDialog(
      title: 'Salir del equipo',
      message: '¿Deseas salir de "${project.title}"?',
      confirmText: 'Sí, salir',
      confirmColor: const Color(0xFFD45A5A),
      icon: Icons.logout_rounded,
    );
    if (confirmed) controller.leaveProject(project);
  }
}

/// Etiqueta que separa los proyectos en los que eres miembro de aquellos a los
/// que solo te postulaste.
class _GroupLabel extends StatelessWidget {
  const _GroupLabel(this.text, {this.divider = false});

  final String text;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (divider)
          const Divider(height: 26, thickness: 1, color: Color(0xFFE0D8CF)),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            text.toUpperCase(),
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF9E9E9E),
              letterSpacing: 0.6,
            ),
          ),
        ),
      ],
    );
  }
}
