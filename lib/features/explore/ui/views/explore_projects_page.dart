import 'package:flutter/material.dart';

/// Contenido de la pestaña "Explorar" (placeholder hasta implementar el flujo).
class ExploreProjectsPage extends StatelessWidget {
  const ExploreProjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Aquí explorarás proyectos de otros equipos.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Color(0xFF6B6B6B)),
        ),
      ),
    );
  }
}
