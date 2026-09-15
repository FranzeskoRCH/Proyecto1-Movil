import 'package:flutter/material.dart';

/// Etiqueta de sección en mayúsculas y gris (p. ej. "CARRERA / TRAYECTORIA").
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.1,
        color: Color(0xFF9E9E9E),
      ),
    );
  }
}
