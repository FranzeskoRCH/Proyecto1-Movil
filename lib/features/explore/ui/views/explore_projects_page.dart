import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/brand_logo.dart';
import '../viewmodels/explore_controller.dart';
import '../widgets/filter_chip_row.dart';
import '../widgets/project_card.dart';
import 'project_detail_page.dart';

/// Contenido de la pestaña "Explorar": lista de proyectos con búsqueda y
/// filtros por categoría.
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

    return RefreshIndicator(
      color: const Color(0xFFFF7043),
      onRefresh: () => controller.loadProjects(),
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.pixels >=
              notification.metrics.maxScrollExtent - 300) {
            controller.loadMore();
          }
          return false;
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            BrandLogo(avatarUrl: avatarUrl, onAvatarTap: onProfileTap),
            const SizedBox(height: 18),
            _SearchField(onChanged: controller.setSearchQuery),
            const SizedBox(height: 14),
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
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFFFF7043)),
                  ),
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
                final query = controller.searchQuery.trim();
                return Padding(
                  padding: const EdgeInsets.only(top: 60),
                  child: Center(
                    child: Text(
                      query.isEmpty
                          ? 'No hay proyectos para esta categoría.'
                          : 'No se encontraron proyectos para "$query".',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFF6B6B6B)),
                    ),
                  ),
                );
              }

              return Column(
                children: [
                  for (final project in controller.projects) ...[
                    ProjectCard(
                      project: project,
                      onViewProject: () => Get.to(
                          () => ProjectDetailPage(projectId: project.id)),
                    ),
                    const SizedBox(height: 16),
                  ],
                  _buildLoadMoreFooter(controller),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadMoreFooter(ExploreController controller) {
    if (controller.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFFFF7043)),
        ),
      );
    }
    if (!controller.hasMore && controller.projects.isNotEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Text(
            'No hay más proyectos.',
            style: TextStyle(color: Color(0xFF9E9E9E)),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

/// Campo de búsqueda por título, categoría o rol.
class _SearchField extends StatefulWidget {
  const _SearchField({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    widget.onChanged('');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: (value) {
        widget.onChanged(value);
        setState(() {});
      },
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Buscar proyectos, roles o categorías',
        hintStyle: const TextStyle(fontSize: 13.5, color: Color(0xFF9E9E9E)),
        prefixIcon: const Icon(Icons.search, color: Color(0xFF9E9E9E)),
        suffixIcon: _controller.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(
                  Icons.close,
                  size: 18,
                  color: Color(0xFF9E9E9E),
                ),
                onPressed: _clear,
              ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE0D8CF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFFF7043), width: 1.5),
        ),
      ),
    );
  }
}
