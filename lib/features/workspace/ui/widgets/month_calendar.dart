import 'package:flutter/material.dart';

import '../../../../core/date_labels.dart';

/// Marcas que se pintan debajo de un día del calendario.
class DayMarkers {
  const DayMarkers({this.hasEvent = false, this.hasDeadline = false});

  final bool hasEvent;
  final bool hasDeadline;

  bool get isEmpty => !hasEvent && !hasDeadline;
}

/// Calendario mensual con la semana empezando en lunes. Marca con puntos los
/// días que tienen fechas importantes (naranja) o deadlines (gris oscuro).
class MonthCalendar extends StatelessWidget {
  const MonthCalendar({
    super.key,
    required this.month,
    required this.selectedDay,
    required this.markersFor,
    required this.onDaySelected,
    required this.onPreviousMonth,
    required this.onNextMonth,
  });

  /// Cualquier fecha dentro del mes que se muestra.
  final DateTime month;
  final DateTime selectedDay;
  final DayMarkers Function(DateTime day) markersFor;
  final ValueChanged<DateTime> onDaySelected;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  static const Color _eventColor = Color(0xFFFF7043);
  static const Color _deadlineColor = Color(0xFF5C5C5C);

  @override
  Widget build(BuildContext context) {
    final first = DateTime(month.year, month.month);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leading = first.weekday - 1; // lunes = 0
    final cellCount = ((leading + daysInMonth) / 7).ceil() * 7;
    final today = DateLabels.dateOnly(DateTime.now());

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _ArrowButton(icon: Icons.chevron_left, onTap: onPreviousMonth),
              Expanded(
                child: Text(
                  DateLabels.monthYear(month),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2B2B2B),
                  ),
                ),
              ),
              _ArrowButton(icon: Icons.chevron_right, onTap: onNextMonth),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              for (final initial in DateLabels.weekdayInitials)
                Expanded(
                  child: Center(
                    child: Text(
                      initial,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFBDBDBD),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          for (int row = 0; row < cellCount ~/ 7; row++)
            Row(
              children: [
                for (int col = 0; col < 7; col++)
                  Expanded(
                    child: _buildCell(
                      index: row * 7 + col,
                      leading: leading,
                      daysInMonth: daysInMonth,
                      today: today,
                    ),
                  ),
              ],
            ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Legend(color: _eventColor, label: 'Fecha importante'),
              SizedBox(width: 16),
              _Legend(color: _deadlineColor, label: 'Deadline de tarea'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCell({
    required int index,
    required int leading,
    required int daysInMonth,
    required DateTime today,
  }) {
    final dayNumber = index - leading + 1;
    if (dayNumber < 1 || dayNumber > daysInMonth) {
      return const SizedBox(height: 46);
    }

    final day = DateTime(month.year, month.month, dayNumber);
    final selected = DateLabels.isSameDay(day, selectedDay);
    final isToday = DateLabels.isSameDay(day, today);
    final markers = markersFor(day);

    return GestureDetector(
      onTap: () => onDaySelected(day),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 46,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 32,
              width: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: selected
                    ? const LinearGradient(
                        colors: [Color(0xFFFFA741), Color(0xFFFF5252)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                border: isToday && !selected
                    ? Border.all(color: _eventColor, width: 1.5)
                    : null,
              ),
              child: Text(
                '$dayNumber',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight:
                      selected || isToday ? FontWeight.w800 : FontWeight.w500,
                  color: selected
                      ? Colors.white
                      : isToday
                          ? _eventColor
                          : const Color(0xFF2B2B2B),
                ),
              ),
            ),
            const SizedBox(height: 3),
            SizedBox(
              height: 5,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (markers.hasEvent) const _Dot(color: _eventColor),
                  if (markers.hasEvent && markers.hasDeadline)
                    const SizedBox(width: 3),
                  if (markers.hasDeadline) const _Dot(color: _deadlineColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        width: 36,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: Color(0xFFF8F2EC),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 22, color: const Color(0xFF2B2B2B)),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 5,
      width: 5,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Dot(color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11.5, color: Color(0xFF9E9E9E)),
        ),
      ],
    );
  }
}
