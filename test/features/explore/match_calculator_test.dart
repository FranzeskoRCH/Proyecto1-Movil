import 'package:flutter_test/flutter_test.dart';
import 'package:movil_proyecto/features/explore/domain/match_calculator.dart';

void main() {
  group('MatchCalculator', () {
    test('sin categorías ni roles devuelve 0', () {
      final match = MatchCalculator.compute(
        userSkills: ['Flutter'],
        userInterests: ['Tech'],
        projectRoles: [],
        projectCategories: [],
      );

      expect(match, 0);
    });

    test('sin perfil del usuario devuelve 0', () {
      final match = MatchCalculator.compute(
        userSkills: [],
        userInterests: [],
        projectRoles: ['Desarrollo Frontend'],
        projectCategories: ['Tech'],
      );

      expect(match, 0);
    });

    test('coincidencia total de intereses y habilidades da 100', () {
      final match = MatchCalculator.compute(
        userSkills: ['Flutter'],
        userInterests: ['Tech'],
        projectRoles: ['Flutter'],
        projectCategories: ['Tech'],
      );

      expect(match, 100);
    });

    test('solo coincidencia de categorías da 50', () {
      final match = MatchCalculator.compute(
        userSkills: ['Flutter'],
        userInterests: ['Tech'],
        projectRoles: ['Diseño UI/UX'],
        projectCategories: ['Tech'],
      );

      expect(match, 50);
    });

    test('solo coincidencia de roles da 50', () {
      final match = MatchCalculator.compute(
        userSkills: ['Flutter'],
        userInterests: ['Salud'],
        projectRoles: ['Flutter'],
        projectCategories: ['Tech'],
      );

      expect(match, 50);
    });

    test('coincidencia parcial se pondera por fracción del proyecto', () {
      final match = MatchCalculator.compute(
        userSkills: ['Flutter'],
        userInterests: ['Tech'],
        projectRoles: ['Flutter', 'Diseño UI/UX'],
        projectCategories: ['Tech', 'Medio Ambiente'],
      );

      // 1/2 categorías + 1/2 roles => (0.5*0.5 + 0.5*0.5) = 0.5 => 50
      expect(match, 50);
    });

    test('ignora acentos, mayúsculas y puntuación', () {
      final match = MatchCalculator.compute(
        userSkills: ['DISEÑO UI/UX'],
        userInterests: ['tecnologia'],
        projectRoles: ['Diseno UI UX'],
        projectCategories: ['Tecnología'],
      );

      expect(match, 100);
    });

    test('coincide por palabra compartida', () {
      final match = MatchCalculator.compute(
        userSkills: ['Diseño Gráfico'],
        userInterests: [],
        projectRoles: ['Diseño UI/UX'],
        projectCategories: [],
      );

      expect(match, 100);
    });

    test('sin relación devuelve 0', () {
      final match = MatchCalculator.compute(
        userSkills: ['Contabilidad'],
        userInterests: ['Negocios'],
        projectRoles: ['Desarrollo Backend'],
        projectCategories: ['Tech'],
      );

      expect(match, 0);
    });
  });
}
