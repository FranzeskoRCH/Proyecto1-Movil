import 'package:flutter/material.dart';

/// Encabezado con el logo "Nexus" (degradado) y el avatar del usuario.
class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, required this.avatarUrl, this.onAvatarTap});

  final String avatarUrl;
  final VoidCallback? onAvatarTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFFFB300), Color(0xFFFF5252)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ).createShader(bounds),
          child: const Text(
            'Nexus',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
        ),
        GestureDetector(
          onTap: onAvatarTap,
          child: CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFFEADFD6),
            backgroundImage: NetworkImage(avatarUrl),
          ),
        ),
      ],
    );
  }
}
