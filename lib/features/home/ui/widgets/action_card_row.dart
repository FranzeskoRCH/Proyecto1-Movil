import 'package:flutter/material.dart';

import 'action_card.dart';

/// Contenedor con las dos tarjetas de acción principales de la home.
///
/// Usa [IntrinsicHeight] para que ambas tarjetas tengan la misma altura,
/// ya que dentro de un [ListView] la altura es ilimitada y un `stretch`
/// directo produciría restricciones infinitas.
class ActionCardRow extends StatelessWidget {
  const ActionCardRow({
    super.key,
    required this.onCreateTap,
    required this.onExploreTap,
  });

  final VoidCallback onCreateTap;
  final VoidCallback onExploreTap;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: ActionCard(
              icon: Icons.add,
              title: 'Crear Proyecto',
              subtitle: 'Publica tu idea y recluta colaboradores',
              onTap: onCreateTap,
              gradient: const LinearGradient(
                colors: [Color(0xFFFFA741), Color(0xFFFF5252)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            flex: 2,
            child: ActionCard(
              icon: Icons.search,
              title: 'Explorar Proyectos',
              subtitle: 'Únete a equipos de estudiantes',
              onTap: onExploreTap,
              elevated: true,
            ),
          ),
        ],
      ),
    );
  }
}
