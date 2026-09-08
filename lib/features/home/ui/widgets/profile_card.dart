import 'package:flutter/material.dart';

import '../../domain/models/collaborator_profile.dart';
import 'tag_chip.dart';

/// Tarjeta que muestra el perfil del colaborador.
///
/// Recibe el modelo [CollaboratorProfile] como parámetro, por lo que los
/// valores provienen de la API y no están hardcodeados dentro del widget.
class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key, required this.profile});

  final CollaboratorProfile profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('CARRERA / TRAYECTORIA'),
          const SizedBox(height: 10),
          Text(
            profile.career,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              height: 1.3,
              color: Color(0xFF2B2B2B),
            ),
          ),
          const _Divider(),
          const SectionLabel('HABILIDADES CLAVE'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: profile.skills
                .map((skill) => TagChip(label: skill))
                .toList(),
          ),
          const _Divider(),
          const SectionLabel('INTERESES ACTIVOS'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: profile.interests
                .map((interest) =>
                    TagChip(label: interest, variant: TagChipVariant.accent))
                .toList(),
          ),
        ],
      ),
    );
  }
}

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

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 18),
      child: Divider(height: 1, thickness: 1, color: Color(0xFFECECEC)),
    );
  }
}
