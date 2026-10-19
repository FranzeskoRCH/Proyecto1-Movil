import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/app_confirm_dialog.dart';
import '../../../../core/widgets/section_label.dart';
import '../../../explore/ui/widgets/project_hero_header.dart';
import '../../../profile/ui/views/public_profile_page.dart';
import '../../domain/models/applicant.dart';
import '../viewmodels/team_management_controller.dart';
import '../widgets/applicant_tile.dart';
import '../widgets/segmented_tabs.dart';
import '../widgets/status_badge.dart';

enum _TeamTab { pending, team }

/// Gestión del equipo de un proyecto propio: postulantes pendientes y
/// equipo actual.
class TeamManagementPage extends StatefulWidget {
  const TeamManagementPage({super.key, required this.projectId});

  final String projectId;

  @override
  State<TeamManagementPage> createState() => _TeamManagementPageState();
}

class _TeamManagementPageState extends State<TeamManagementPage> {
  final TeamManagementController controller = Get.find();
  _TeamTab _tab = _TeamTab.pending;

  @override
  void initState() {
    super.initState();
    controller.loadProject(widget.projectId);
  }

  void _openProfile(Applicant applicant) {
    Get.to(
      () => PublicProfilePage(
        userId: applicant.collaboratorId,
        fallbackName: applicant.name,
        fallbackCareer: applicant.career,
        fallbackAvatarUrl: applicant.avatarUrl,
      ),
    );
  }

  Future<void> _confirmReject(Applicant applicant) async {
    final confirmed = await showAppConfirmDialog(
      title: 'Rechazar postulación',
      message: '¿Rechazar a ${applicant.name} para el rol '
          '"${applicant.requestedRole}"?',
      confirmText: 'Sí, rechazar',
      confirmColor: const Color(0xFFD32F2F),
      icon: Icons.person_off_outlined,
    );
    if (confirmed) controller.reject(applicant.id);
  }

  Future<void> _confirmRemove(Applicant member) async {
    final confirmed = await showAppConfirmDialog(
      title: 'Retirar del equipo',
      message: '¿Retirar a ${member.name} del equipo? Su cupo quedará '
          'disponible de nuevo.',
      confirmText: 'Sí, retirar',
      confirmColor: const Color(0xFFD32F2F),
      icon: Icons.person_remove_outlined,
    );
    if (confirmed) controller.remove(member.id);
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
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CircleBackButton(onTap: Get.back),
                  const Expanded(
                    child: Center(
                      child: _EmptyState(
                        icon: Icons.cloud_off_outlined,
                        title: 'No se pudo cargar el proyecto',
                        message: 'Revisa tu conexión e inténtalo de nuevo.',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final pending = project.pendingApplicants;
        final team = project.teamMembers;
        final bool canAccept =
            project.vacancies <= 0 || team.length < project.vacancies;

        return ListView(
          padding: EdgeInsets.zero,
          children: [
            ProjectHeroHeader(imageUrl: project.imageUrl, onBack: Get.back),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const SectionLabel('GESTIONAR EQUIPO'),
                      const Spacer(),
                      StatusBadge.project(project.status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    project.title,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2B2B2B),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _CapacityCard(
                    teamCount: team.length,
                    pendingCount: pending.length,
                    vacancies: project.vacancies,
                  ),
                  const SizedBox(height: 24),
                  SegmentedTabs<_TeamTab>(
                    segments: {
                      'Postulantes (${pending.length})': _TeamTab.pending,
                      'Equipo (${team.length})': _TeamTab.team,
                    },
                    selected: _tab,
                    onSelected: (tab) => setState(() => _tab = tab),
                  ),
                  const SizedBox(height: 18),
                  if (_tab == _TeamTab.pending)
                    ..._buildPending(pending, canAccept)
                  else
                    ..._buildTeam(team),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  List<Widget> _buildPending(List<Applicant> pending, bool canAccept) {
    if (pending.isEmpty) {
      return const [
        _EmptyState(
          icon: Icons.inbox_outlined,
          title: 'Sin postulantes pendientes',
          message: 'Cuando alguien solicite unirse a tu proyecto, '
              'aparecerá aquí para que lo revises.',
        ),
      ];
    }
    return [
      for (final applicant in pending) ...[
        ApplicantTile(
          applicant: applicant,
          isProcessing: controller.processingId == applicant.id,
          acceptEnabled: canAccept,
          onAccept: () => controller.accept(applicant.id),
          onReject: () => _confirmReject(applicant),
          onViewProfile: applicant.collaboratorId.isEmpty
              ? null
              : () => _openProfile(applicant),
        ),
        const SizedBox(height: 12),
      ],
    ];
  }

  List<Widget> _buildTeam(List<Applicant> team) {
    if (team.isEmpty) {
      return const [
        _EmptyState(
          icon: Icons.groups_outlined,
          title: 'Aún no hay integrantes',
          message: 'Acepta postulantes para empezar a armar tu equipo.',
        ),
      ];
    }
    return [
      for (final member in team) ...[
        ApplicantTile(
          applicant: member,
          isProcessing: controller.processingId == member.id,
          onRemove: () => _confirmRemove(member),
          onViewProfile: member.collaboratorId.isEmpty
              ? null
              : () => _openProfile(member),
        ),
        const SizedBox(height: 12),
      ],
    ];
  }
}

// ── Capacidad: cupos ocupados, barra de progreso y resumen ──────────────────
class _CapacityCard extends StatelessWidget {
  const _CapacityCard({
    required this.teamCount,
    required this.pendingCount,
    required this.vacancies,
  });

  final int teamCount;
  final int pendingCount;
  final int vacancies;

  @override
  Widget build(BuildContext context) {
    final bool limited = vacancies > 0;
    final bool full = limited && teamCount >= vacancies;
    final double progress =
        limited ? (teamCount / vacancies).clamp(0.0, 1.0) : 0;
    final int free = limited ? (vacancies - teamCount).clamp(0, vacancies) : 0;

    return Container(
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
            children: [
              const Icon(
                Icons.groups_rounded,
                size: 20,
                color: Color(0xFFFF7043),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Capacidad del equipo',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
              ),
              Text(
                limited ? '$teamCount / $vacancies' : '$teamCount',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFFF7043),
                ),
              ),
            ],
          ),
          if (limited) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                children: [
                  Container(height: 10, color: const Color(0xFFF4EFEA)),
                  FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(
                      height: 10,
                      decoration: BoxDecoration(
                        gradient: full
                            ? null
                            : const LinearGradient(
                                colors: [
                                  Color(0xFFFFA741),
                                  Color(0xFFFF5252),
                                ],
                              ),
                        color: full ? const Color(0xFF2E9E5B) : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              full
                  ? '¡Equipo completo! Ya no quedan cupos libres.'
                  : 'Quedan $free ${free == 1 ? 'cupo libre' : 'cupos libres'}.',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: full ? FontWeight.w600 : FontWeight.w400,
                color: full
                    ? const Color(0xFF2E9E5B)
                    : const Color(0xFF9E9E9E),
              ),
            ),
          ],
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF0EBE6)),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(label: 'En equipo', value: '$teamCount'),
              const _StatDivider(),
              _StatItem(label: 'Pendientes', value: '$pendingCount'),
              const _StatDivider(),
              _StatItem(
                label: 'Vacantes',
                value: limited ? '$vacancies' : '∞',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE0D8CF), width: 1.2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFFF7043).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 28, color: const Color(0xFFFF7043)),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2B2B2B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              height: 1.4,
              color: Color(0xFF9E9E9E),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleBackButton extends StatelessWidget {
  const _CircleBackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
          color: Color(0xFF2B2B2B),
        ),
      ),
    );
  }
}
