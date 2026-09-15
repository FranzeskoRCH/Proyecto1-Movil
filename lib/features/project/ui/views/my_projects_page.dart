import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/brand_logo.dart';
import '../viewmodels/my_projects_controller.dart';
import '../widgets/applied_project_card.dart';
import '../widgets/created_project_card.dart';
import '../widgets/segmented_tabs.dart';
import 'applied_project_detail_page.dart';
import 'team_management_page.dart';

/// Contenido de la pestaña "Proyectos": Mis Proyectos (Creados / Aplicados).
class MyProjectsPage extends StatelessWidget {
  const MyProjectsPage({
    super.key,
    required this.avatarUrl,
    required this.onProfileTap,
  });

  final String avatarUrl;
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    final MyProjectsController controller = Get.find();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      children: [
        BrandLogo(avatarUrl: avatarUrl, onAvatarTap: onProfileTap),
        const SizedBox(height: 18),
        const Text(
          'Mis Proyectos',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: Color(0xFF2B2B2B),
          ),
        ),
        const SizedBox(height: 18),
        Obx(
          () => SegmentedTabs<MyProjectsTab>(
            segments: const {
              'Creados': MyProjectsTab.created,
              'Aplicados': MyProjectsTab.applied,
            },
            selected: controller.tab,
            onSelected: controller.selectTab,
          ),
        ),
        const SizedBox(height: 18),
        Obx(() {
          if (controller.isLoading &&
              controller.createdProjects.isEmpty &&
              controller.appliedProjects.isEmpty) {
            return const Padding(
              padding: EdgeInsets.only(top: 60),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return _buildList(controller);
        }),
      ],
    );
  }

  Widget _buildList(MyProjectsController controller) {
    if (controller.tab == MyProjectsTab.created) {
      if (controller.createdProjects.isEmpty) {
        return const _EmptyText('Aún no has creado proyectos.');
      }
      return Column(
        children: [
          for (final project in controller.createdProjects) ...[
            CreatedProjectCard(
              project: project,
              onManageTeam: () async {
                await Get.to(
                  () => TeamManagementPage(projectId: project.id),
                );
                controller.loadProjects();
              },
            ),
            const SizedBox(height: 16),
          ],
        ],
      );
    }

    if (controller.appliedProjects.isEmpty) {
      return const _EmptyText('Aún no has aplicado a proyectos.');
    }
    return Column(
      children: [
        for (final project in controller.appliedProjects) ...[
          AppliedProjectCard(
            project: project,
            onViewDetails: () => Get.to(
              () => AppliedProjectDetailPage(project: project),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class _EmptyText extends StatelessWidget {
  const _EmptyText(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Center(
        child: Text(
          message,
          style: const TextStyle(color: Color(0xFF6B6B6B)),
        ),
      ),
    );
  }
}
