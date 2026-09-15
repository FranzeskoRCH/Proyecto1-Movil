import 'package:flutter/material.dart';

/// Insignia con el porcentaje de compatibilidad del proyecto.
///
/// Verde para coincidencias altas (>= 85) y naranja para el resto.
class MatchBadge extends StatelessWidget {
  const MatchBadge({super.key, required this.matchPercentage});

  final int matchPercentage;

  @override
  Widget build(BuildContext context) {
    final bool high = matchPercentage >= 85;
    final Color color =
        high ? const Color(0xFF2E9E5B) : const Color(0xFFE8833A);
    final Color background =
        high ? const Color(0xFFE3F5EA) : const Color(0xFFFDEBDD);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$matchPercentage% Match',
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
