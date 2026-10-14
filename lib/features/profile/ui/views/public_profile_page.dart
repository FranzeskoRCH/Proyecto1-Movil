import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/section_label.dart';
import '../../../../core/widgets/tag_chip.dart';
import '../viewmodels/collaborator_profile_controller.dart';

/// Perfil público de otro colaborador (autor de un proyecto, postulante…).
///
/// Muestra su información y habilidades antes de aceptar o contactar.
class PublicProfilePage extends StatefulWidget {
  const PublicProfilePage({
    super.key,
    required this.userId,
    this.fallbackName,
    this.fallbackCareer,
    this.fallbackAvatarUrl,
  });

  final String userId;
  final String? fallbackName;
  final String? fallbackCareer;
  final String? fallbackAvatarUrl;

  @override
  State<PublicProfilePage> createState() => _PublicProfilePageState();
}

class _PublicProfilePageState extends State<PublicProfilePage> {
  final CollaboratorProfileController controller = Get.find();

  @override
  void initState() {
    super.initState();
    controller.load(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F2EC),
      body: SafeArea(
        child: Obx(() {
          final profile = controller.profile;
          final name = profile?.name ?? widget.fallbackName ?? 'Colaborador';
          final career =
              profile?.career ?? widget.fallbackCareer ?? 'Estudiante';
          final avatarUrl =
              profile?.avatarUrl ?? widget.fallbackAvatarUrl ?? '';
          final skills = profile?.skills ?? [];
          final interests = profile?.interests ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: Get.back,
                  child: Container(
                    height: 40,
                    width: 40,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x1A000000),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      size: 20,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
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
                            ? const Icon(
                                Icons.person,
                                size: 48,
                                color: Color(0xFFFF7043),
                              )
                            : null,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        name,
                        textAlign: TextAlign.center,
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
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                if (controller.isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFF7043),
                      ),
                    ),
                  )
                else ...[
                  _StatsCard(stats: controller.stats),
                  const SizedBox(height: 24),
                  const SectionLabel('HABILIDADES'),
                  const SizedBox(height: 10),
                  if (skills.isEmpty)
                    const Text(
                      'Este colaborador aún no ha agregado habilidades.',
                      style: TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: skills.map((s) => TagChip(label: s)).toList(),
                    ),
                  const SizedBox(height: 24),
                  const SectionLabel('ÁREAS DE INTERÉS'),
                  const SizedBox(height: 10),
                  if (interests.isEmpty)
                    const Text(
                      'Sin áreas de interés registradas.',
                      style: TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: interests
                          .map(
                            (i) => TagChip(
                              label: i,
                              variant: TagChipVariant.accent,
                            ),
                          )
                          .toList(),
                    ),
                  if (controller.error != null) ...[
                    const SizedBox(height: 20),
                    Text(
                      controller.error!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF9E9E9E),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          );
        }),
      ),
    );
  }
}

/// Tarjeta con las estadísticas públicas del colaborador.
class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.stats});

  final Map<String, int> stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
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
          _StatItem(label: 'Creados', value: stats['created'] ?? 0),
          const _StatDivider(),
          _StatItem(label: 'Miembro', value: stats['member'] ?? 0),
          const _StatDivider(),
          _StatItem(label: 'Postulado', value: stats['applied'] ?? 0),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
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
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(height: 32, width: 1, color: const Color(0xFFE0D8CF));
  }
}
