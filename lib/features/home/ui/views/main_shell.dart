import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:movil_proyecto/features/create/ui/views/create_project_page.dart';
import 'package:movil_proyecto/features/explore/ui/views/explore_projects_page.dart';
import 'package:movil_proyecto/features/profile/ui/views/profile_page.dart';
import 'package:movil_proyecto/features/project/ui/views/my_projects_page.dart';

import '../viewmodels/home_controller.dart';
import '../widgets/app_bottom_nav_bar.dart';
import 'home_page.dart';

/// Contenedor raíz que muestra la pestaña activa manteniendo siempre visible
/// la barra de navegación inferior.
///
/// Índices: 0 Inicio · 1 Explorar · 2 Crear · 3 Proyectos · 4 Perfil.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  static const int _profileIndex = 4;

  int _index = 0;

  void _onTabSelected(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    final HomeController homeController = Get.find();

    return Scaffold(
      body: SafeArea(
        child: Obx(
          () => IndexedStack(
            index: _index,
            children: [
              HomePage(
                onCreateTap: () => _onTabSelected(2),
                onExploreTap: () => _onTabSelected(1),
                onProfileTap: () => _onTabSelected(_profileIndex),
              ),
              ExploreProjectsPage(
                avatarUrl: homeController.profile?.avatarUrl ?? '',
                onProfileTap: () => _onTabSelected(_profileIndex),
              ),
              const CreateProjectPage(),
              MyProjectsPage(
                avatarUrl: homeController.profile?.avatarUrl ?? '',
                onProfileTap: () => _onTabSelected(_profileIndex),
              ),
              const ProfilePage(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _index,
        onTap: _onTabSelected,
      ),
    );
  }
}
