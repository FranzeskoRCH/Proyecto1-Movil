import 'package:flutter/material.dart';

import '../../domain/models/project_member.dart';

/// Avatar con nombre y disciplina de un integrante del equipo actual.
class MemberAvatar extends StatelessWidget {
  const MemberAvatar({super.key, required this.member});

  final ProjectMember member;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: const Color(0xFFEADFD6),
          backgroundImage: member.avatarUrl.isEmpty
              ? null
              : NetworkImage(member.avatarUrl),
        ),
        const SizedBox(height: 6),
        Text(
          '${member.name} (${member.discipline})',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6B6B6B),
          ),
        ),
      ],
    );
  }
}
