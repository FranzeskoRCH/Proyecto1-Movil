import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/brand_logo.dart';
import '../viewmodels/explore_controller.dart';
import '../widgets/filter_chip_row.dart';
import '../widgets/project_card.dart';
import 'project_detail_page.dart';

/// Contenido de la pestaña "Explorar": lista de proyectos filtrable.
///
/// Es "tonta": solo reacciona al estado que expone [ExploreController].
class ExploreProjectsPage extends StatelessWidget {
  const ExploreProjectsPage({
    super.key,
    required this.avatarUrl,
    required this.onProfileTap,
  });

  final String avatarUrl;
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    final ExploreController controller = Get.find();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      children: [
        BrandLogo(avatarUrl: avatarUrl, onAvatarTap: onProfileTap),
        const SizedBox(height: 18),
        Obx(
          () => FilterChipRow(
            categories: controller.categories,
            selected: controller.selectedCategory,
            onSelected: controller.selectCategory,
          ),
        ),
        const SizedBox(height: 18),
        Obx(() {
          if (controller.isLoading && controller.projects.isEmpty) {
            return const Padding(
              padding: EdgeInsets.only(top: 60),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (controller.error != null && controller.projects.isEmpty) {
            return Padding(
              padding: const EdgeInsets.only(top: 60),
              child: Center(
                child: Text(
                  controller.error!,
                  style: const TextStyle(color: Color(0xFF6B6B6B)),
                ),
              ),
            );
          }

          if (controller.projects.isEmpty) {
            return const Padding(
              padding: EdgeInsets.only(top: 60),
              child: Center(
                child: Text(
                  'No hay proyectos para esta categoría.',
                  style: TextStyle(color: Color(0xFF6B6B6B)),
                ),
              ),
            );
          }

          return Column(
            children: [
              for (final project in controller.projects) ...[
                ProjectCard(
                  project: project,
                  onViewProject: () =>
                      Get.to(() => ProjectDetailPage(projectId: project.id)),
                ),
                const SizedBox(height: 16),
              ],
            ],
          );
        }),
      ],
    );
  }
}
