import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../viewmodels/home_controller.dart';
import '../widgets/action_card_row.dart';
import '../widgets/brand_logo.dart';
import '../widgets/greeting_header.dart';
import '../widgets/profile_card.dart';

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
  static const String _title = 'Tu Perfil de Colaborador';

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
            _title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2B2B2B),
            ),
          ),
          const SizedBox(height: 14),
          ProfileCard(profile: profile),
          const SizedBox(height: 24),
        ],
      );
    });
  }
}
