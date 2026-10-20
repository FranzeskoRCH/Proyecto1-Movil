import 'package:test/test.dart';
import 'package:movil_proyecto/core/date_labels.dart';

void main() {
  group('DateLabels', () {
    test('normaliza una fecha a medianoche local', () {
      final result = DateLabels.dateOnly(DateTime(2026, 10, 24, 18, 42));

      expect(result, DateTime(2026, 10, 24));
    });

    test('formatea fechas y fechas relativas de forma determinista', () {
      final date = DateTime(2026, 10, 24, 9, 5);

      expect(DateLabels.short(date), '24 Oct');
      expect(DateLabels.shortWithTime(date), '24 Oct, 09:05');
      expect(DateLabels.relative(date, now: DateTime(2026, 10, 23)), endsWith('ana'));
    });

    test('serializa y analiza fechas ISO sin desplazar el día', () {
      final date = DateTime(2026, 10, 24, 23, 59);

      expect(DateLabels.toIsoDate(date), '2026-10-24');
      expect(DateLabels.parse('2026-10-24'), DateTime(2026, 10, 24));
      expect(DateLabels.parse(null), isNull);
      expect(DateLabels.parse(''), isNull);
      expect(DateLabels.parse('no-es-fecha'), isNull);
    });
  });
}
