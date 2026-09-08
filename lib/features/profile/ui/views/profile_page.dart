import 'package:flutter/material.dart';

/// Contenido de la pestaña "Perfil" (placeholder hasta implementar el flujo).
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Aquí verás tu perfil de colaborador.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Color(0xFF6B6B6B)),
        ),
      ),
    );
  }
}
