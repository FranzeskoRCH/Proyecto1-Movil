import 'package:flutter/material.dart';

import '../../domain/models/applicant.dart';

/// Tarjeta de un postulante o integrante del equipo con sus acciones.
///
/// Si [onRemove] está presente muestra la acción de retirar del equipo; si
/// [onAccept]/[onReject] están presentes muestra aceptar/rechazar.
class ApplicantTile extends StatelessWidget {
  const ApplicantTile({
    super.key,
    required this.applicant,
    this.isProcessing = false,
    this.acceptEnabled = true,
    this.onAccept,
    this.onReject,
    this.onRemove,
    this.onViewProfile,
  });

  final Applicant applicant;
  final bool isProcessing;
  final bool acceptEnabled;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onRemove;
  final VoidCallback? onViewProfile;

  bool get _isPendingTile => onAccept != null && onReject != null;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: onViewProfile,
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                _Avatar(url: applicant.avatarUrl),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        applicant.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2B2B2B),
                        ),
                      ),
                      if (applicant.career.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          applicant.career,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF9E9E9E),
                          ),
                        ),
                      ],
                      if (applicant.requestedRole.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _RolePill(label: applicant.requestedRole),
                      ],
                    ],
                  ),
                ),
                if (onViewProfile != null)
                  const Icon(
                    Icons.chevron_right,
                    size: 22,
                    color: Color(0xFF9E9E9E),
                  )
                else if (!_isPendingTile)
                  _buildRemoveAction(),
              ],
            ),
          ),
          if (_isPendingTile) ...[
            const SizedBox(height: 14),
            _buildDecisionRow(),
          ] else if (onViewProfile != null && onRemove != null) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFF0EBE6)),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: _buildRemoveAction(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDecisionRow() {
    if (isProcessing) {
      return const SizedBox(
        height: 44,
        child: Center(
          child: SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color: Color(0xFFFF7043),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _PillButton(
                label: 'Rechazar',
                icon: Icons.close_rounded,
                foreground: const Color(0xFFD45A5A),
                background: const Color(0xFFFBE4E4),
                onTap: onReject!,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _PillButton(
                label: 'Aceptar',
                icon: Icons.check_rounded,
                foreground: Colors.white,
                gradient: acceptEnabled,
                background: const Color(0xFFE6E6E6),
                onTap: acceptEnabled ? onAccept : null,
              ),
            ),
          ],
        ),
        if (!acceptEnabled) ...[
          const SizedBox(height: 8),
          const Text(
            'Equipo completo: aumenta las vacantes para aceptar más.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
          ),
        ],
      ],
    );
  }

  Widget _buildRemoveAction() {
    if (onRemove == null) return const SizedBox.shrink();
    if (isProcessing) {
      return const SizedBox(
        height: 22,
        width: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.2,
          color: Color(0xFFD45A5A),
        ),
      );
    }
    return GestureDetector(
      onTap: onRemove,
      behavior: HitTestBehavior.opaque,
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person_remove_outlined,
              size: 18,
              color: Color(0xFFD45A5A),
            ),
            SizedBox(width: 6),
            Text(
              'Retirar del equipo',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFFD45A5A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 24,
      backgroundColor: const Color(0xFFEADFD6),
      backgroundImage: url.isEmpty ? null : NetworkImage(url),
      child: url.isEmpty
          ? const Icon(Icons.person, size: 24, color: Color(0xFF9E9E9E))
          : null,
    );
  }
}

class _RolePill extends StatelessWidget {
  const _RolePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFF7043).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFCCBC)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.work_outline,
            size: 12,
            color: Color(0xFFFF7043),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFFFF7043),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.label,
    required this.icon,
    required this.foreground,
    required this.background,
    required this.onTap,
    this.gradient = false,
  });

  final String label;
  final IconData icon;
  final Color foreground;
  final Color background;
  final VoidCallback? onTap;
  final bool gradient;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onTap != null;
    final Color effectiveForeground =
        enabled ? foreground : const Color(0xFF9E9E9E);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: gradient && enabled
              ? const LinearGradient(
                  colors: [Color(0xFFFFA741), Color(0xFFFF5252)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          color: gradient && enabled ? null : background,
          borderRadius: BorderRadius.circular(30),
          boxShadow: gradient && enabled
              ? const [
                  BoxShadow(
                    color: Color(0x33FF5252),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: effectiveForeground),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: effectiveForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
