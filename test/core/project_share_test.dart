import 'package:flutter_test/flutter_test.dart';
import 'package:movil_proyecto/core/project_share.dart';

void main() {
  group('buildProjectShareMessage', () {
    test('incluye título, descripción y enlace', () {
      final message = buildProjectShareMessage(
        projectId: 'abc-123',
        title: 'EcoCampus',
        description: 'Clasificación de residuos con IA.',
      );

      expect(message, contains('"EcoCampus"'));
      expect(message, contains('Clasificación de residuos con IA.'));
      expect(message, contains('$projectLinkBase/abc-123'));
    });

    test('omite la descripción cuando está vacía', () {
      final message = buildProjectShareMessage(
        projectId: 'p1',
        title: 'Solo Título',
        description: '   ',
      );

      expect(message, contains('"Solo Título"'));
      expect(message, contains('$projectLinkBase/p1'));
      expect(message.trim().split('\n').where((l) => l.trim().isEmpty).length,
          greaterThan(0));
    });

    test('el enlace del proyecto usa la base configurada', () {
      expect(projectShareLink('xyz'), '$projectLinkBase/xyz');
    });
  });
}
