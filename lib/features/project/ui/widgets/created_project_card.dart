import 'package:flutter/material.dart';

import '../../domain/models/created_project.dart';
import 'status_badge.dart';

/// Tarjeta de un proyecto propio en la pestaña "Creados".
class CreatedProjectCard extends StatelessWidget {
  const CreatedProjectCard({
    super.key,
    required this.project,
    required this.onManageTeam,
    required this.onEdit,
    required this.onDelete,
    required this.onShare,
    this.onOpenWorkspace,
    this.onStartProject,
  });

  final CreatedProject project;
  final VoidCallback onManageTeam;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onShare;

  /// Abre el espacio de trabajo (tareas, calendario y progreso).
  final VoidCallback? onOpenWorkspace;

  /// Pasa el proyecto de "Reclutando" a "Activo".
  final VoidCallback? onStartProject;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  project.title,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2B2B2B),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              StatusBadge.project(project.status),
              SizedBox(
                height: 28,
                width: 28,
                child: PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  iconSize: 20,
                  icon: const Icon(
                    Icons.more_vert,
                    color: Color(0xFF9E9E9E),
                  ),
                  tooltip: 'Opciones',
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit();
                    } else if (value == 'share') {
                      onShare();
                    } else if (value == 'delete') {
                      onDelete();
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 18),
                          SizedBox(width: 10),
                          Text('Editar'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'share',
                      child: Row(
                        children: [
                          Icon(Icons.share_outlined, size: 18),
                          SizedBox(width: 10),
                          Text('Compartir'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: Color(0xFFD32F2F),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Eliminar',
                            style: TextStyle(color: Color(0xFFD32F2F)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            project.description,
            style: const TextStyle(
              fontSize: 13.5,
              height: 1.4,
              color: Color(0xFF6B6B6B),
            ),
          ),
          const SizedBox(height: 16),
          if (project.status == CreatedProjectStatus.recruiting &&
              onStartProject != null) ...[
            _CardAction(
              label: 'Iniciar proyecto',
              icon: Icons.rocket_launch_outlined,
              onTap: onStartProject!,
              outlined: true,
            ),
            const SizedBox(height: 14),
          ] else if (project.status != CreatedProjectStatus.recruiting &&
              onOpenWorkspace != null) ...[
            _CardAction(
              label: 'Espacio de trabajo',
              icon: Icons.dashboard_customize_outlined,
              onTap: onOpenWorkspace!,
            ),
            const SizedBox(height: 14),
          ],
          const Divider(height: 1, thickness: 1, color: Color(0xFFECECEC)),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '${project.vacancies} vacantes · '
                '${project.pendingApplicants.length} postulantes',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF9E9E9E),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onManageTeam,
                child: const Row(
                  children: [
                    Text(
                      'Gestionar Equipo',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFF0552F),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: Color(0xFFF0552F),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Botón ancho de la tarjeta: en degradado, o con borde si [outlined].
class _CardAction extends StatelessWidget {
  const _CardAction({
    required this.label,
    required this.icon,
    required this.onTap,
    this.outlined = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final Color foreground =
        outlined ? const Color(0xFFF0552F) : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: outlined
              ? null
              : const LinearGradient(
                  colors: [Color(0xFFFFA741), Color(0xFFFF5252)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
          color: outlined ? const Color(0xFFFFF4EF) : null,
          borderRadius: BorderRadius.circular(30),
          border: outlined
              ? Border.all(color: const Color(0xFFFFCCBC), width: 1.2)
              : null,
          boxShadow: outlined
              ? null
              : const [
                  BoxShadow(
                    color: Color(0x33FF5252),
                    blurRadius: 12,
                    offset: Offset(0, 5),
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: foreground),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
