import 'package:flutter/material.dart';

/// Contenido de la pestaña "Proyectos" (placeholder hasta implementar el flujo).
class ProjectsPage extends StatelessWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Aquí verás tus proyectos.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Color(0xFF6B6B6B)),
        ),
      ),
    );
  }
}
