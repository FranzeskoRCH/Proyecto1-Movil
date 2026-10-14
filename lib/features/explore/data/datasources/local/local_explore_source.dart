import '../../../domain/models/project.dart';
import '../i_explore_source.dart';

/// Fuente de datos local (offline).
///
/// Devuelve proyectos simulando la respuesta de la API. Mantiene el estado de
/// las solicitudes en memoria para que "Solicitar" y "Cancelar" se comporten
/// como lo haría el backend. [RobleExploreSource] la usa como respaldo cuando
/// falla la lectura contra Roble, y las pruebas la usan como doble.
class LocalExploreSource implements IExploreSource {
  LocalExploreSource() : _projects = _seedProjects();

  final List<Project> _projects;

  static const String _forYouCategory = 'Para Ti';

  static const List<String> _categories = [
    _forYouCategory,
    'Medio Ambiente',
    'Tech',
    'Arte y Diseño',
    'Salud',
    'Investigación Académica',
  ];

  @override
  Future<List<String>> getCategories() async {
    return List<String>.unmodifiable(_categories);
  }

  @override
  Future<List<Project>> getProjects({
    String? category,
    String? search,
    int limit = 20,
    int offset = 0,
  }) async {
    Iterable<Project> result = _projects;

    if (category != null && category != _forYouCategory) {
      result = result.where((project) => project.categories.contains(category));
    }

    final term = search?.trim().toLowerCase() ?? '';
    if (term.isNotEmpty) {
      result = result.where(
        (project) =>
            project.title.toLowerCase().contains(term) ||
            project.categories.any((c) => c.toLowerCase().contains(term)) ||
            project.roles.any((r) => r.name.toLowerCase().contains(term)),
      );
    }

    final list = result.toList();
    final start = offset.clamp(0, list.length);
    final end = (start + limit).clamp(start, list.length);
    return List<Project>.unmodifiable(list.sublist(start, end));
  }

  @override
  Future<Project> getProjectById(String id) async {
    return _projects.firstWhere(
      (project) => project.id == id,
      orElse: () => throw Exception('Proyecto no encontrado: $id'),
    );
  }

  @override
  Future<void> requestToJoin(String projectId, {String? role}) async {
    _projects
        .firstWhere(
          (project) => project.id == projectId,
          orElse: () => throw Exception('Proyecto no encontrado: $projectId'),
        )
        .requestedToJoin = true;
  }

  @override
  Future<void> cancelRequest(String projectId) async {
    _projects
        .firstWhere(
          (project) => project.id == projectId,
          orElse: () => throw Exception('Proyecto no encontrado: $projectId'),
        )
        .requestedToJoin = false;
  }

  // ---------------------------------------------------------------------------
  // Datos mock que retornaría el endpoint.
  // ---------------------------------------------------------------------------
  static List<Project> _seedProjects() => _projectsJson
      .map((json) => Project.fromJson(json))
      .toList(growable: true);

  static const List<Map<String, dynamic>> _projectsJson = [
    {
      'id': 'p1',
      'title': 'EcoCampus Sorter',
      'description':
          'Una estación de clasificación con IA enfocada en plástico y residuos de comercio para maximizar los flujos de reciclaje directo.',
      'vision':
          'El EcoCampus Smart Sorter busca colocar nodos de clasificación con visión por computadora en los principales puntos de comida del campus. Identificará visualmente residuos compostables, reciclables y de relleno para guiar a los usuarios al instante, reduciendo las tasas de contaminación de residuos en el campus.',
      'authorName': 'Kira Vance',
      'authorCareer': 'Ciencias Ambientales',
      'authorAvatarUrl': 'https://i.pravatar.cc/150?img=47',
      'categories': ['Impacto Social', 'Medio Ambiente', 'Tech'],
      'matchPercentage': 87,
      'imageUrl': 'https://picsum.photos/seed/ecocampus/800/400',
      'vacancies': 3,
      'roles': [
        {'name': 'Visión por Computadora', 'hasSkill': true},
        {'name': 'Diseño UI/UX', 'hasSkill': true},
        {'name': 'Ciencias Ambientales', 'hasSkill': false},
        {'name': 'Modelo de Negocio', 'hasSkill': false},
      ],
      'members': [
        {
          'name': 'Kira',
          'avatarUrl': 'https://i.pravatar.cc/150?img=47',
          'discipline': 'Arte',
        },
        {
          'name': 'Tyler',
          'avatarUrl': 'https://i.pravatar.cc/150?img=12',
          'discipline': 'Sist. Embebidos',
        },
      ],
      'requestedToJoin': false,
    },
    {
      'id': 'p2',
      'title': 'MetaAlert Smart Watch',
      'description':
          'Monitoreo biométrico de bajo coste para detectar emergencias, diseñado específicamente para centros de atención a adultos mayores.',
      'vision':
          'MetaAlert es un reloj inteligente de bajo coste que monitorea signos vitales y detecta caídas o emergencias médicas en adultos mayores. El objetivo es alertar de inmediato a cuidadores y centros de atención, reduciendo los tiempos de respuesta ante incidentes críticos.',
      'authorName': 'Marcos Chen',
      'authorCareer': 'Ingeniería Biomédica',
      'authorAvatarUrl': 'https://i.pravatar.cc/150?img=15',
      'categories': ['Investigación Académica', 'Salud', 'Tecnología'],
      'matchPercentage': 84,
      'imageUrl': 'https://picsum.photos/seed/metaalert/800/400',
      'vacancies': 2,
      'roles': [
        {'name': 'Ingeniería Biomédica', 'hasSkill': true},
        {'name': 'IoT', 'hasSkill': false},
        {'name': 'Gestión', 'hasSkill': false},
      ],
      'members': [
        {
          'name': 'Marcos',
          'avatarUrl': 'https://i.pravatar.cc/150?img=15',
          'discipline': 'Biomédica',
        },
      ],
      'requestedToJoin': false,
    },
  ];
}
