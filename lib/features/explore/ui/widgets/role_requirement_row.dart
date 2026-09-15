import 'package:flutter/material.dart';

import '../../domain/models/project_role.dart';

/// Fila de un rol requerido en el detalle: check verde si el colaborador ya
/// cumple el requisito, círculo vacío si aún no.
class RoleRequirementRow extends StatelessWidget {
  const RoleRequirementRow({super.key, required this.role});

  final ProjectRole role;

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF2E9E5B);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFECECEC), width: 1.2),
      ),
      child: Row(
        children: [
          Icon(
            role.hasSkill
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked,
            size: 20,
            color: role.hasSkill ? green : const Color(0xFFBFBFBF),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              role.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2B2B2B),
              ),
            ),
          ),
          if (role.hasSkill)
            const Text(
              'Tienes Éxito',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: green,
              ),
            ),
        ],
      ),
    );
  }
}
