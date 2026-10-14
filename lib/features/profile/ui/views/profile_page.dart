import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/widgets/app_confirm_dialog.dart';
import '../viewmodels/profile_controller.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _showAddDialog({
    required String title,
    required String hint,
    required Function(String) onAdd,
  }) async {
    final value = await showAppInputDialog(
      title: title,
      hint: hint,
      confirmText: 'Agregar',
      icon: Icons.add_circle_outline,
    );
    if (value != null) onAdd(value);
  }

  Future<void> _showLogoutDialog(ProfileController controller) async {
    final confirmed = await showAppConfirmDialog(
      title: 'Cerrar sesión',
      message: '¿Estás seguro de que deseas salir de tu cuenta?',
      confirmText: 'Salir',
      confirmColor: const Color(0xFFD32F2F),
      icon: Icons.logout_rounded,
    );
    if (confirmed) controller.logout();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F2EC),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value && controller.profile == null) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF7043)),
            );
          }

          final profile = controller.profile;
          final name = profile?.name ?? 'Colaborador';
          final career = profile?.career ?? 'Estudiante';
          final avatarUrl = profile?.avatarUrl ?? '';
          final skills = profile?.skills ?? [];
          final interests = profile?.interests ?? [];

          return RefreshIndicator(
            color: const Color(0xFFFF7043),
            onRefresh: () => controller.loadProfile(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  // Header de Perfil
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 46,
                          backgroundColor:
                              const Color(0xFFFF7043).withValues(alpha: 0.2),
                          backgroundImage: avatarUrl.isNotEmpty
                              ? NetworkImage(avatarUrl)
                              : null,
                          child: avatarUrl.isEmpty
                              ? const Icon(Icons.person,
                                  size: 48, color: Color(0xFFFF7043))
                              : null,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E1E1E),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          career,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF757575),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: () =>
                              Get.to(() => const EditProfilePage()),
                          icon: const Icon(Icons.edit_outlined, size: 16),
                          label: const Text('Editar Perfil'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFFF7043),
                            side: const BorderSide(color: Color(0xFFFF7043)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Estadísticas
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                            'Creados', controller.stats['created'] ?? 0),
                        _buildDivider(),
                        _buildStatItem(
                            'Miembro', controller.stats['member'] ?? 0),
                        _buildDivider(),
                        _buildStatItem(
                            'Postulado', controller.stats['applied'] ?? 0),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Sección Habilidades
                  _buildChipCard(
                    title: 'Habilidades',
                    icon: Icons.psychology_outlined,
                    items: skills,
                    onAddTap: () => _showAddDialog(
                      title: 'Nueva Habilidad',
                      hint: 'Ej. Flutter, Figma, Python...',
                      onAdd: controller.addSkill,
                    ),
                    onDeleteTap: controller.removeSkill,
                  ),
                  const SizedBox(height: 18),

                  // Sección Intereses
                  _buildChipCard(
                    title: 'Áreas de Interés',
                    icon: Icons.star_border_rounded,
                    items: interests,
                    onAddTap: () => _showAddDialog(
                      title: 'Nuevo Interés',
                      hint: 'Ej. Inteligencia Artificial, Sostenibilidad...',
                      onAdd: controller.addInterest,
                    ),
                    onDeleteTap: controller.removeInterest,
                  ),
                  const SizedBox(height: 28),

                  // Botón Cerrar Sesión
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () => _showLogoutDialog(controller),
                      icon: const Icon(Icons.logout, color: Colors.redAccent),
                      label: const Text(
                        'Cerrar Sesión',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(
                              color: Colors.redAccent.withValues(alpha: 0.3)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStatItem(String label, int value) {
    return Column(
      children: [
        Text(
          '$value',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Color(0xFFFF7043),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF757575),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 32,
      width: 1,
      color: const Color(0xFFE0D8CF),
    );
  }

  Widget _buildChipCard({
    required String title,
    required IconData icon,
    required List<String> items,
    required VoidCallback onAddTap,
    required Function(String) onDeleteTap,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: const Color(0xFFFF7043), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: onAddTap,
                icon: const Icon(Icons.add_circle_outline,
                    color: Color(0xFFFF7043)),
                tooltip: 'Agregar',
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Aún no has agregado ninguno.',
                style: TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: items.map((item) {
                return Chip(
                  label: Text(item),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  onDeleted: () => onDeleteTap(item),
                  backgroundColor:
                      const Color(0xFFFF7043).withValues(alpha: 0.08),
                  labelStyle: const TextStyle(
                    color: Color(0xFFFF7043),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Color(0xFFFFCCBC)),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
