/// Calcula el porcentaje de afinidad ("% Match") entre el perfil de un
/// colaborador y los requisitos de un proyecto.
///
/// El puntaje combina dos señales, cada una con el mismo peso:
///
///  * **Intereses ↔ Categorías** del proyecto.
///  * **Habilidades ↔ Roles** que busca el proyecto.
///
/// Para cada dimensión se mide qué fracción de los elementos del proyecto
/// encuentran una coincidencia en el perfil del usuario; el resultado se
/// expresa como un porcentaje entre 0 y 100.
///
/// La comparación es difusa: se normalizan mayúsculas, acentos y puntuación, y
/// dos etiquetas coinciden si son iguales o si comparten alguna palabra
/// significativa (p. ej. "Diseño UI/UX" y "Diseño Gráfico" comparten "diseño").
class MatchCalculator {
  const MatchCalculator._();

  /// Peso de la afinidad por intereses/categorías y de habilidades/roles.
  static const double _half = 0.5;

  /// Devuelve el % de match (0-100) entre el perfil del usuario y el proyecto.
  static int compute({
    required List<String> userSkills,
    required List<String> userInterests,
    required List<String> projectRoles,
    required List<String> projectCategories,
  }) {
    final skills = _normalizeAll(userSkills);
    final interests = _normalizeAll(userInterests);
    final roles = _normalizeAll(projectRoles);
    final categories = _normalizeAll(projectCategories);

    final categoryScore = _overlapRatio(interests, categories);
    final roleScore = _overlapRatio(skills, roles);

    final hasCategories = categories.isNotEmpty;
    final hasRoles = roles.isNotEmpty;

    final double score;
    if (hasCategories && hasRoles) {
      score = _half * categoryScore + _half * roleScore;
    } else if (hasCategories) {
      score = categoryScore;
    } else if (hasRoles) {
      score = roleScore;
    } else {
      return 0;
    }

    return (score * 100).round().clamp(0, 100);
  }

  /// Fracción (0-1) de etiquetas del proyecto que tienen coincidencia en el perfil.
  static double _overlapRatio(Set<String> userTags, Set<String> projectTags) {
    if (projectTags.isEmpty) return 0;
    var matched = 0;
    for (final project in projectTags) {
      if (userTags.any((user) => _matches(user, project))) {
        matched++;
      }
    }
    return matched / projectTags.length;
  }

  /// Dos etiquetas normalizadas coinciden si son iguales o comparten una palabra.
  static bool _matches(String a, String b) {
    if (a == b) return true;
    return _tokens(a).intersection(_tokens(b)).isNotEmpty;
  }

  /// Normaliza una lista descartando entradas vacías.
  static Set<String> _normalizeAll(List<String> values) =>
      values.map(_normalize).where((value) => value.isNotEmpty).toSet();

  /// Palabras significativas (3+ caracteres) de una etiqueta normalizada.
  static Set<String> _tokens(String normalized) =>
      normalized.split(' ').where((token) => token.length >= 3).toSet();

  /// Minúsculas, sin acentos ni puntuación, con espacios simples.
  static String _normalize(String value) {
    final buffer = StringBuffer();
    for (final char in value.toLowerCase().split('')) {
      buffer.write(_accents[char] ?? char);
    }
    return buffer
        .toString()
        .replaceAll(RegExp(r'[^a-z0-9 ]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static const Map<String, String> _accents = {
    'á': 'a',
    'à': 'a',
    'ä': 'a',
    'â': 'a',
    'ã': 'a',
    'é': 'e',
    'è': 'e',
    'ë': 'e',
    'ê': 'e',
    'í': 'i',
    'ì': 'i',
    'ï': 'i',
    'î': 'i',
    'ó': 'o',
    'ò': 'o',
    'ö': 'o',
    'ô': 'o',
    'õ': 'o',
    'ú': 'u',
    'ù': 'u',
    'ü': 'u',
    'û': 'u',
    'ñ': 'n',
    'ç': 'c',
  };
}
