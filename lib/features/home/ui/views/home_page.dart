import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/brand_logo.dart';
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
        return const Center(child: CircularProgressIndicator());
      }

      final profile = controller.profile;
      if (profile == null) {
        return const Center(child: Text('No se pudo cargar el perfil.'));
      }

      return ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          BrandLogo(
            avatarUrl: profile.avatarUrl,
            onAvatarTap: onProfileTap,
          ),
          const SizedBox(height: 16),
          GreetingHeader(name: profile.name, subtitle: _subtitle),
          const SizedBox(height: 20),
          ActionCardRow(
            onCreateTap: onCreateTap,
            onExploreTap: onExploreTap,
          ),
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
            const Text(
              'Aún no participas en ningún proyecto.',
              style: TextStyle(fontSize: 13.5, color: Color(0xFF9E9E9E)),
            )
          else
            for (final project in controller.enrolledProjects) ...[
              EnrolledProjectCard(project: project),
              const SizedBox(height: 14),
            ],
          const SizedBox(height: 10),
        ],
      );
    });
  }
}
