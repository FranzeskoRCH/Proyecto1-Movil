import 'package:flutter/material.dart';

/// Control segmentado de dos o más pestañas con la opción activa en degradado.
class SegmentedTabs<T> extends StatelessWidget {
  const SegmentedTabs({
    super.key,
    required this.segments,
    required this.selected,
    required this.onSelected,
  });

  /// Etiqueta visible asociada al valor de cada pestaña (orden de inserción).
  final Map<String, T> segments;
  final T selected;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          for (final entry in segments.entries)
            Expanded(
              child: GestureDetector(
                onTap: () => onSelected(entry.value),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: entry.value == selected
                        ? const LinearGradient(
                            colors: [Color(0xFFFFA741), Color(0xFFFF5252)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          )
                        : null,
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: Text(
                    entry.key,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: entry.value == selected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: entry.value == selected
                          ? Colors.white
                          : const Color(0xFF2B2B2B),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
