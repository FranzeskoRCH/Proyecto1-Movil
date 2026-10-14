import 'package:flutter/material.dart';

import '../../domain/models/project_role.dart';

/// Fila de un rol requerido en el detalle.
///
/// Permite seleccionarlo para postularse a ese rol; si el colaborador ya
/// cumple el requisito ([ProjectRole.hasSkill]) se indica con "Tienes Éxito".
class RoleRequirementRow extends StatelessWidget {
  const RoleRequirementRow({
    super.key,
    required this.role,
    this.selected = false,
    this.onTap,
  });

  final ProjectRole role;
  final bool selected;
  final VoidCallback? onTap;

  static const Color _accent = Color(0xFFFF7043);
  static const Color _green = Color(0xFF2E9E5B);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? _accent.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? _accent : const Color(0xFFECECEC),
            width: selected ? 1.6 : 1.2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              size: 20,
              color: selected ? _accent : const Color(0xFFBFBFBF),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                role.name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: selected ? _accent : const Color(0xFF2B2B2B),
                ),
              ),
            ),
            if (role.hasSkill)
              const Text(
                'Tienes Éxito',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _green,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
