import 'package:flutter/material.dart';

/// Saludo de bienvenida al usuario.
class GreetingHeader extends StatelessWidget {
  const GreetingHeader({super.key, required this.name, required this.subtitle});

  final String name;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '¡Hola, $name! 👋',
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: Color(0xFF2B2B2B),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 15,
            color: Color(0xFF6B6B6B),
          ),
        ),
      ],
    );
  }
}
