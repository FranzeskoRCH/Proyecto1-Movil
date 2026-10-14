import 'dart:convert';

import 'package:loggy/loggy.dart';
import 'package:movil_proyecto/core/roble_service.dart';
import 'package:movil_proyecto/features/explore/domain/match_calculator.dart';
import 'package:movil_proyecto/features/explore/domain/models/project.dart';
import 'package:movil_proyecto/features/explore/domain/models/project_member.dart';
import 'package:movil_proyecto/features/explore/domain/models/project_role.dart';
import 'i_explore_source.dart';
import 'local/local_explore_source.dart';

/// Datos auxiliares usados por el camino de respaldo (lectura por tablas).
///
/// `read` de Roble solo admite filtros de igualdad, así que en vez de pedir las
/// categorías, roles, miembros y colaboradores de cada proyecto por separado
/// (un N+1), se traen las tablas completas una sola vez y se agrupan en memoria.
class _ExploreLookups {
  _ExploreLookups({
    required this.collaborators,
    required this.categoriesByProject,
    required this.rolesByProject,
    required this.membersByProject,
    required this.userSkills,
    required this.userInterests,
    required this.appliedProjectIds,
  });

  final Map<String, Map<String, dynamic>> collaborators;
  final Map<String, List<String>> categoriesByProject;
  final Map<String, List<String>> rolesByProject;
  final Map<String, List<Map<String, dynamic>>> membersByProject;
  final List<String> userSkills;
  final List<String> userInterests;
  final Set<String> appliedProjectIds;
}

class RobleExploreSource with NetworkLoggy implements IExploreSource {
  final RobleService _roble = RobleService();
  final LocalExploreSource _fallbackSource = LocalExploreSource();

  static const String _defaultAvatar =
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150';

  static const String _forYouCategory = 'Para Ti';
  static const List<String> _defaultCategories = [
    _forYouCategory,
    'Medio Ambiente',
    'Tech',
    'Arte y Diseño',
    'Salud',
    'Investigación Académica',
  ];

  /// Consultas guardadas en la consola de Roble. La de detalle devuelve, por
  /// proyecto, el autor, las categorías, los roles, los miembros y la actividad
  /// del usuario actual (todo en una sola petición).
  static const String _projectsQueryName = 'proyectos_completos';
  static const String _projectByIdQueryName = 'proyecto_completo';

  /// Consultas antiguas (solo proyecto + paginado), usadas por el respaldo.
  static const String _pagedQueryName = 'proyectos_paginados';
  static const String _searchQueryName = 'buscar_proyectos';

  /// UUID válido y sin filas, para cuando no hay sesión: evita mandar `''` a una
  /// comparación de tipo `uuid` en Postgres.
  static const String _noUser = '00000000-0000-0000-0000-000000000000';

  @override
  Future<List<String>> getCategories() async {
    final categories = Set<String>.from(_defaultCategories);
    try {
      final records = await _roble.db.read('project_category');
      for (final r in records) {
        final cat =
            (r['category_name'] ?? r['categoryName'] ?? r['name'])?.toString();
        if (cat != null && cat.isNotEmpty) {
          categories.add(cat);
        }
      }
    } catch (_) {
      // Usar categorías por defecto
    }
    return categories.toList();
  }

  @override
  Future<List<Project>> getProjects({
    String? category,
    String? search,
    int limit = 20,
    int offset = 0,
  }) async {
    // El texto de búsqueda tiene prioridad; si no, se usa la categoría activa
    // (la consulta guardada también busca dentro de las categorías del proyecto).
    final trimmedSearch = search?.trim() ?? '';
    final term = trimmedSearch.isNotEmpty
        ? trimmedSearch
        : (category != null && category != _forYouCategory ? category : '');
    final userId = _roble.currentUserId;

    try {
      return await _fetchProjectsViaQuery(
        term: term,
        limit: limit,
        offset: offset,
        userId: userId.isEmpty ? _noUser : userId,
      );
    } catch (e) {
      loggy.warning(
          '[ROBLE_EXPLORE] Consulta guardada "$_projectsQueryName" no disponible '
          '($e); usando lectura por tablas.');
    }

    try {
      return await _fetchProjectsViaTables(
        term: term,
        limit: limit,
        offset: offset,
        userId: userId,
      );
    } catch (_) {
      return await _fallbackSource.getProjects(
        category: category,
        search: search,
        limit: limit,
        offset: offset,
      );
    }
  }

  /// Camino rápido: una sola consulta guardada devuelve la página ya armada.
  Future<List<Project>> _fetchProjectsViaQuery({
    required String term,
    required int limit,
    required int offset,
    required String userId,
  }) async {
    final result = await _roble.db.executeQueryByName(
      _projectsQueryName,
      params: [term, limit, offset, userId],
    );
    return _rowsToProjects(result.rows);
  }

  /// Convierte las filas de la consulta guardada en [Project]s.
  List<Project> _rowsToProjects(List<dynamic> rows) {
    final projects = <Project>[];
    for (final raw in rows) {
      if (raw is! Map) continue;
      final row = Map<String, dynamic>.from(raw);
      final project = _projectFromQueryRow(row);
      if (project.id.isNotEmpty) projects.add(project);
    }
    return projects;
  }

  /// Arma un [Project] a partir de una fila que ya trae autor, categorías,
  /// roles, miembros y actividad del usuario (nombres de la consulta guardada).
  Project _projectFromQueryRow(Map<String, dynamic> row) {
    final categories = _stringList(row['categories']);
    final roleNames = _stringList(row['roles']);

    return Project(
      id: (row['id'] ?? '').toString(),
      authorId: (row['author_id'] ?? '').toString(),
      title: (row['title'] ?? 'Sin titulo').toString(),
      description: (row['description'] ?? '').toString(),
      vision: (row['vision'] ?? row['description'] ?? '').toString(),
      authorName: (row['author_name'] ?? 'Autor').toString(),
      authorCareer: (row['author_career'] ?? 'Estudiante').toString(),
      authorAvatarUrl: (row['author_avatar_url'] ?? _defaultAvatar).toString(),
      categories: categories.isNotEmpty ? categories : const ['Tech'],
      matchPercentage: MatchCalculator.compute(
        userSkills: _stringList(row['user_skills']),
        userInterests: _stringList(row['user_interests']),
        projectRoles: roleNames,
        projectCategories: categories,
      ),
      imageUrl: (row['image_url'] ?? row['imageUrl'])?.toString(),
      vacancies: int.tryParse(row['vacancies']?.toString() ?? '') ?? 2,
      roles: roleNames.map((name) => ProjectRole(name: name)).toList(),
      members: _memberList(row['members']),
      requestedToJoin: row['requested_to_join'] == true,
    );
  }

  /// Camino de respaldo: página + tablas completas leídas en paralelo.
  Future<List<Project>> _fetchProjectsViaTables({
    required String term,
    required int limit,
    required int offset,
    required String userId,
  }) async {
    final results = await Future.wait<Object?>([
      _queryProjectPage(term: term, limit: limit, offset: offset),
      _loadLookups(userId),
    ]);
    final projectRows = results[0] as List<Map<String, dynamic>>;
    final lookups = results[1] as _ExploreLookups;

    return projectRows
        .map((row) => _projectFromRow(row, lookups))
        .where((project) => project.id.isNotEmpty)
        .toList();
  }

  /// Lee de una sola vez todo lo que la lista necesita para armar los
  /// proyectos: colaboradores (autores y miembros), categorías, roles y la
  /// actividad del usuario actual.
  Future<_ExploreLookups> _loadLookups(String userId) async {
    final results = await Future.wait<Object?>([
      _safeRead('collaborator'),
      _safeRead('project_category'),
      _safeRead('project_role'),
      _safeRead('project_member'),
      _readUserTags('collaborator_skill', 'skill_name', userId),
      _readUserTags('collaborator_interest', 'interest_name', userId),
      _readMyApplications(userId),
    ]);

    final collaborators = <String, Map<String, dynamic>>{};
    for (final c in results[0] as List<Map<String, dynamic>>) {
      // En Roble el UUID del usuario vive en `id`; `_id` es el id interno y se
      // indexa igual para tolerar datos antiguos.
      for (final key in [c['id'], c['_id']]) {
        final id = key?.toString();
        if (id != null && id.isNotEmpty) {
          collaborators.putIfAbsent(id, () => c);
        }
      }
    }

    return _ExploreLookups(
      collaborators: collaborators,
      categoriesByProject: _groupStrings(
          results[1] as List<Map<String, dynamic>>, 'category_name'),
      rolesByProject:
          _groupStrings(results[2] as List<Map<String, dynamic>>, 'role_name'),
      membersByProject: _groupRows(results[3] as List<Map<String, dynamic>>),
      userSkills: results[4] as List<String>,
      userInterests: results[5] as List<String>,
      appliedProjectIds: results[6] as Set<String>,
    );
  }

  /// Arma un [Project] a partir de una fila y los datos auxiliares ya leídos.
  Project _projectFromRow(Map<String, dynamic> row, _ExploreLookups lookups) {
    // Preferir 'id' (PK real del DDL) sobre '_id' (ID interno de Roble)
    final id = (row['id'] ?? row['_id'] ?? '').toString();

    final projectCategories = lookups.categoriesByProject[id] ?? const [];
    final roleNames = lookups.rolesByProject[id] ?? const [];

    final members = <ProjectMember>[];
    for (final m in lookups.membersByProject[id] ?? const []) {
      final collaboratorId =
          (m['collaborator_id'] ?? m['collaboratorId'] ?? '').toString();
      final profile = lookups.collaborators[collaboratorId];
      members.add(ProjectMember(
        name: profile?['name']?.toString() ?? 'Miembro',
        avatarUrl:
            (profile?['avatar_url'] ?? profile?['avatarUrl'])?.toString() ??
                _defaultAvatar,
        discipline: (m['discipline'] ?? m['role'] ?? 'Miembro').toString(),
      ));
    }

    final authorId = (row['author_id'] ?? row['authorId'])?.toString();
    final author = authorId == null ? null : lookups.collaborators[authorId];

    return Project(
      id: id,
      authorId: authorId ?? '',
      title: (row['title'] ?? 'Sin titulo').toString(),
      description: (row['description'] ?? '').toString(),
      vision: (row['vision'] ?? row['description'] ?? '').toString(),
      authorName: author?['name']?.toString() ?? 'Autor',
      authorCareer: author?['career']?.toString() ?? 'Estudiante',
      authorAvatarUrl:
          (author?['avatar_url'] ?? author?['avatarUrl'])?.toString() ??
              _defaultAvatar,
      categories:
          projectCategories.isNotEmpty ? projectCategories : const ['Tech'],
      matchPercentage: MatchCalculator.compute(
        userSkills: lookups.userSkills,
        userInterests: lookups.userInterests,
        projectRoles: roleNames,
        projectCategories: projectCategories,
      ),
      imageUrl: (row['image_url'] ?? row['imageUrl'])?.toString(),
      vacancies: int.tryParse(row['vacancies']?.toString() ?? '') ?? 2,
      roles: roleNames.map((name) => ProjectRole(name: name)).toList(),
      members: members,
      requestedToJoin: lookups.appliedProjectIds.contains(id),
    );
  }

  /// Obtiene una página de proyectos usando las consultas guardadas antiguas.
  Future<List<Map<String, dynamic>>> _queryProjectPage({
    required String term,
    required int limit,
    required int offset,
  }) async {
    final result = term.isEmpty
        ? await _roble.db.executeQueryByName(
            _pagedQueryName,
            params: [limit, offset],
          )
        : await _roble.db.executeQueryByName(
            _searchQueryName,
            params: [term, limit, offset],
          );
    return result.rows
        .whereType<Map>()
        .map((row) => Map<String, dynamic>.from(row))
        .toList();
  }

  /// Lee una tabla completa; devuelve vacío si falla, para que una sola tabla
  /// caída no tumbe toda la pantalla.
  Future<List<Map<String, dynamic>>> _safeRead(String table) async {
    try {
      return await _roble.db.read(table);
    } catch (_) {
      return const [];
    }
  }

  /// Helper: lee las etiquetas (habilidades o intereses) del usuario actual.
  Future<List<String>> _readUserTags(
    String table,
    String valueField,
    String userId,
  ) async {
    if (userId.isEmpty) return const [];
    try {
      final rows =
          await _roble.db.read(table, filters: {'collaborator_id': userId});
      return rows
          .map((r) => (r[valueField] ?? r['name'] ?? '').toString())
          .where((v) => v.isNotEmpty)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  /// Proyectos a los que el usuario actual ya se postuló.
  Future<Set<String>> _readMyApplications(String userId) async {
    if (userId.isEmpty) return {};
    try {
      final apps = await _roble.db
          .read('application', filters: {'applicant_id': userId});
      return apps
          .map((a) => (a['project_id'] ?? a['projectId'] ?? '').toString())
          .where((id) => id.isNotEmpty)
          .toSet();
    } catch (_) {
      return {};
    }
  }

  /// Agrupa filas con `project_id` + un campo de texto en `{projectId: [valores]}`.
  Map<String, List<String>> _groupStrings(
    List<Map<String, dynamic>> rows,
    String valueField,
  ) {
    final grouped = <String, List<String>>{};
    for (final row in rows) {
      final projectId = (row['project_id'] ?? row['projectId'])?.toString();
      final value = (row[valueField] ?? row['name'])?.toString();
      if (projectId == null || projectId.isEmpty) continue;
      if (value == null || value.isEmpty) continue;
      grouped.putIfAbsent(projectId, () => []).add(value);
    }
    return grouped;
  }

  /// Agrupa filas de `project_member` en `{projectId: [filas]}`.
  Map<String, List<Map<String, dynamic>>> _groupRows(
    List<Map<String, dynamic>> rows,
  ) {
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final row in rows) {
      final projectId = (row['project_id'] ?? row['projectId'])?.toString();
      if (projectId == null || projectId.isEmpty) continue;
      grouped.putIfAbsent(projectId, () => []).add(row);
    }
    return grouped;
  }

  /// Interpreta un agregado `json_agg` como lista de textos. Tolera que Roble
  /// lo entregue como array o como string JSON.
  List<String> _stringList(dynamic value) {
    return _jsonList(value).map((e) => e.toString()).toList();
  }

  /// Interpreta un agregado `json_agg` de objetos como lista de miembros.
  List<ProjectMember> _memberList(dynamic value) {
    return _jsonList(value).map((e) {
      if (e is Map) {
        return ProjectMember(
          name: (e['name'] ?? 'Miembro').toString(),
          avatarUrl:
              (e['avatar_url'] ?? e['avatarUrl'] ?? _defaultAvatar).toString(),
          discipline: (e['discipline'] ?? 'Miembro').toString(),
        );
      }
      return ProjectMember(
        name: 'Miembro',
        avatarUrl: _defaultAvatar,
        discipline: 'Miembro',
      );
    }).toList();
  }

  List<dynamic> _jsonList(dynamic value) {
    if (value is List) return value;
    if (value is String && value.isNotEmpty) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is List) return decoded;
      } catch (_) {}
    }
    return const [];
  }

  @override
  Future<Project> getProjectById(String id) async {
    final userId = _roble.currentUserId;

    // Camino rápido: la consulta de detalle ya trae todo.
    try {
      final result = await _roble.db.executeQueryByName(
        _projectByIdQueryName,
        params: [id, userId.isEmpty ? _noUser : userId],
      );
      final rows = result.rows.whereType<Map>().toList();
      if (rows.isNotEmpty) {
        final project =
            _projectFromQueryRow(Map<String, dynamic>.from(rows.first));
        if (project.id.isNotEmpty) return project;
      }
    } catch (e) {
      loggy.warning(
          '[ROBLE_EXPLORE] Consulta guardada "$_projectByIdQueryName" no '
          'disponible ($e); usando lectura por tablas.');
    }

    try {
      final projects = await _fetchProjectsViaTables(
        term: '',
        limit: 50,
        offset: 0,
        userId: userId,
      ).catchError((_) => <Project>[]);
      final match = projects.where((p) => p.id == id);
      if (match.isNotEmpty) return match.first;

      // Si no estaba en la página actual, buscarlo directamente en la BD
      // (por `_id`, interno de Roble, y también por `id`, PK real del DDL).
      var rows = await _roble.db.read('project', filters: {'_id': id});
      if (rows.isEmpty) {
        rows = await _roble.db.read('project', filters: {'id': id});
      }
      if (rows.isNotEmpty) {
        final lookups = await _loadLookups(userId);
        return _projectFromRow(rows.first, lookups);
      }
    } catch (e) {
      throw Exception('Error al cargar el proyecto $id: $e');
    }
    throw Exception('Proyecto no encontrado: $id');
  }

  @override
  Future<void> requestToJoin(String projectId, {String? role}) async {
    final userId = _roble.currentUserId;
    if (userId.isEmpty) throw Exception('Usuario no autenticado');

    // Garantizar que el postulante exista en collaborator (FK fk_app_applicant)
    try {
      final existing = await _roble.findCollaborator(userId);
      if (existing == null) {
        final cached = _roble.cachedUser;
        await _roble.db.create('collaborator', {
          'id': userId,
          'name': (cached?['name'] ?? cached?['userName'] ?? 'Colaborador')
              .toString(),
          'career': (cached?['career'] ?? 'Estudiante').toString(),
          'avatar_url':
              (cached?['avatar_url'] ?? cached?['avatarUrl'] ?? _defaultAvatar)
                  .toString(),
        });
      }
    } catch (e) {
      // Si ya existe (duplicado), continuar de todas formas
    }

    final now = DateTime.now();
    final dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    await _roble.db.create('application', {
      'project_id': projectId,
      'applicant_id': userId,
      'requested_role': (role != null && role.trim().isNotEmpty)
          ? role.trim()
          : 'Colaborador',
      'status': 'underReview',
      'applied_date': dateStr,
    });
  }

  @override
  Future<void> cancelRequest(String projectId) async {
    final userId = _roble.currentUserId;
    if (userId.isEmpty) throw Exception('Usuario no autenticado');
    final apps = await _roble.db.read('application', filters: {
      'project_id': projectId,
      'applicant_id': userId,
    });
    for (final app in apps) {
      final appId = app['_id'] ?? app['id'];
      if (appId != null) {
        await _roble.db.delete('application', appId);
      }
    }
  }
}
