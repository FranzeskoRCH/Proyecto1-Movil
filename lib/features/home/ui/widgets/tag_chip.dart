import 'package:flutter/material.dart';

/// Etiqueta tipo píldora reutilizable.
class TagChip extends StatelessWidget {
  const TagChip({
    super.key,
    required this.label,
    this.variant = TagChipVariant.neutral,
  });

  final String label;
  final TagChipVariant variant;

  @override
  Widget build(BuildContext context) {
    final bool outlined = variant == TagChipVariant.accent;
    final textColor = outlined
        ? const Color(0xFFC0615E)
        : const Color(0xFF2B2B2B);
    final borderColor = outlined
        ? const Color(0xFFE8B5B2)
        : const Color(0xFFE3E3E3);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: outlined ? Colors.white.withValues(alpha: 0.4) : Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }
}

enum TagChipVariant { neutral, accent }
