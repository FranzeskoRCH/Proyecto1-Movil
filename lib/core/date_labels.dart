/// Utilidades para mostrar fechas en español sin depender de `intl`.
abstract final class DateLabels {
  static const List<String> _shortMonths = [
    'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
    'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
  ];

  static const List<String> _longMonths = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
  ];

  /// Iniciales de lunes a domingo.
  static const List<String> weekdayInitials = [
    'L', 'M', 'M', 'J', 'V', 'S', 'D',
  ];

  /// La fecha sin hora (medianoche local).
  static DateTime dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// "24 Oct".
  static String short(DateTime date) =>
      '${date.day} ${_shortMonths[date.month - 1]}';

  /// "24 Oct, 14:05".
  static String shortWithTime(DateTime date) {
    final hh = date.hour.toString().padLeft(2, '0');
    final mm = date.minute.toString().padLeft(2, '0');
    return '${short(date)}, $hh:$mm';
  }

  /// "Octubre 2026".
  static String monthYear(DateTime date) =>
      '${_longMonths[date.month - 1]} ${date.year}';

  /// "Hoy", "Mañana", "Ayer", "En 3 días", "Hace 2 días" o "24 Oct".
  static String relative(DateTime date, {DateTime? now}) {
    final today = dateOnly(now ?? DateTime.now());
    final days = dateOnly(date).difference(today).inDays;
    if (days == 0) return 'Hoy';
    if (days == 1) return 'Mañana';
    if (days == -1) return 'Ayer';
    if (days > 1 && days < 7) return 'En $days días';
    if (days < -1 && days > -7) return 'Hace ${-days} días';
    return short(date);
  }

  /// "2026-10-24", el formato de una columna `date` de Postgres.
  static String toIsoDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  /// Interpreta una fecha que viene de Roble (`date` o `timestamptz`).
  ///
  /// Las fechas sin hora se leen como día local para que "2026-10-24" no se
  /// corra al día anterior por la zona horaria.
  static DateTime? parse(Object? value) {
    if (value == null) return null;
    final text = value.toString().trim();
    if (text.isEmpty) return null;
    if (text.length == 10) {
      final parsed = DateTime.tryParse(text);
      return parsed == null ? null : dateOnly(parsed);
    }
    return DateTime.tryParse(text)?.toLocal();
  }
}
