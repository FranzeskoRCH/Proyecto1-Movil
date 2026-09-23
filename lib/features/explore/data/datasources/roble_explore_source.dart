import 'package:movil_proyecto/core/roble_service.dart';
import 'package:movil_proyecto/features/explore/domain/models/project.dart';
import 'package:movil_proyecto/features/explore/domain/models/project_member.dart';
import 'package:movil_proyecto/features/explore/domain/models/project_role.dart';
import 'i_explore_source.dart';
import 'local/local_explore_source.dart';

class RobleExploreSource implements IExploreSource {
  final RobleService _roble = RobleService();
  final LocalExploreSource _fallbackSource = LocalExploreSource();

  /// Helper: obtiene un colaborador por su _id usando read con filter.
  /// getById no esta en la API publica documentada del SDK.
  Future<Map<String, dynamic>?> _getCollaboratorById(String id) async {
    try {
      final rows = await _roble.db.read('collaborator', filters: {'_id': id});
      return rows.isNotEmpty ? rows.first : null;
    } catch (_) {
      return null;
    }
  }

  static const String _forYouCategory = 'Para Ti';
  static const List<String> _defaultCategories = [
    _forYouCategory,
    'Medio Ambiente',
    'Tech',
    'Arte y Diseño',
    'Salud',
    'Investigación Académica',
  ];

  @override
  Future<List<String>> getCategories() async {
    final categories = Set<String>.from(_defaultCategories);
    try {
      final records = await _roble.db.read('project_category');
      for (final r in records) {
        final cat = (r['category_name'] ?? r['categoryName'] ?? r['name'])?.toString();
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
  Future<List<Project>> getProjects({String? category}) async {
    final userId = _roble.currentUserId;
    List<Project> projects = [];

    try {
      final projectRows = await _roble.db.read('project');

      if (projectRows.isNotEmpty) {
        // Leer aplicaciones del usuario actual para saber si ya solicitó unirse
        final Set<String> appliedProjectIds = {};
        if (userId.isNotEmpty) {
          try {
            final applications = await _roble.db.read('application', filters: {'applicant_id': userId});
            for (final app in applications) {
              final pId = (app['project_id'] ?? app['projectId'] ?? '').toString();
              if (pId.isNotEmpty) appliedProjectIds.add(pId);
            }
          } catch (_) {}
        }

        for (final row in projectRows) {
          // Preferir 'id' (PK real del DDL) sobre '_id' (ID interno de Roble)
          final id = (row['id'] ?? row['_id'] ?? '').toString();
          if (id.isEmpty) continue;

          // Leer categorías del proyecto
          List<String> projectCategories = [];
          try {
            final catRows = await _roble.db.read('project_category', filters: {'project_id': id});
            projectCategories = catRows
                .map((c) => (c['category_name'] ?? c['categoryName'] ?? c['name'] ?? '').toString())
                .where((c) => c.isNotEmpty)
                .toList();
          } catch (_) {}

          // Si el filtro de categoría aplica y no coincide, saltar
          if (category != null && category != _forYouCategory && !projectCategories.contains(category)) {
            continue;
          }

          // Leer roles del proyecto
          List<ProjectRole> roles = [];
          try {
            final roleRows = await _roble.db.read('project_role', filters: {'project_id': id});
            roles = roleRows
                .map((r) => ProjectRole(
                      name: (r['role_name'] ?? r['roleName'] ?? r['name'] ?? 'Colaborador').toString(),
                    ))
                .toList();
          } catch (_) {}

          // Leer miembros del proyecto
          List<ProjectMember> members = [];
          try {
            final memberRows = await _roble.db.read('project_member', filters: {'project_id': id});
            for (final m in memberRows) {
              // collaborator_id en la tabla project_member apunta al _id de collaborator
              final memberCollabId = (m['collaborator_id'] ?? m['collaboratorId'] ?? '').toString();
              String memberName = 'Miembro';
              String memberAvatar = 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150';
          if (memberCollabId.isNotEmpty) {
                // En Roble, el _id de collaborator coincide con el userId del auth
                try {
                  final memProfile = await _getCollaboratorById(memberCollabId);
                  if (memProfile != null) {
                    memberName = memProfile['name']?.toString() ?? memberName;
                    memberAvatar = (memProfile['avatar_url'] ?? memProfile['avatarUrl'])?.toString() ?? memberAvatar;
                  }
                } catch (_) {}
              }
              members.add(
                ProjectMember(
                  name: memberName,
                  avatarUrl: memberAvatar,
                  discipline: (m['discipline'] ?? m['role'] ?? 'Miembro').toString(),
                ),
              );
            }
          } catch (_) {}

          // Autor del proyecto
          String authorName = 'Autor';
          String authorCareer = 'Estudiante';
          String authorAvatar = 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150';
          // author_id en project apunta al _id de collaborator (que = UUID del usuario auth)
          final authorId = (row['author_id'] ?? row['authorId'])?.toString();
          if (authorId != null && authorId.isNotEmpty) {
            try {
              final authorProfile = await _getCollaboratorById(authorId);
              if (authorProfile != null) {
                authorName = authorProfile['name']?.toString() ?? authorName;
                authorCareer = authorProfile['career']?.toString() ?? authorCareer;
                authorAvatar = (authorProfile['avatar_url'] ?? authorProfile['avatarUrl'])?.toString() ?? authorAvatar;
              }
            } catch (_) {}
          }

          projects.add(
            Project(
              id: id,
              authorId: authorId ?? '',
              title: (row['title'] ?? 'Sin titulo').toString(),
              description: (row['description'] ?? '').toString(),
              vision: (row['vision'] ?? row['description'] ?? '').toString(),
              authorName: authorName,
              authorCareer: authorCareer,
              authorAvatarUrl: authorAvatar,
              categories: projectCategories.isNotEmpty ? projectCategories : ['Tech'],
              matchPercentage: 85,
              imageUrl: (row['image_url'] ?? row['imageUrl'])?.toString(),
              vacancies: int.tryParse(row['vacancies']?.toString() ?? '') ?? 2,
              roles: roles,
              members: members,
              requestedToJoin: appliedProjectIds.contains(id),
            ),
          );
        }
      }
      return projects;
    } catch (_) {
      return await _fallbackSource.getProjects(category: category);
    }
  }

  @override
  Future<Project> getProjectById(String id) async {
    try {
      final projects = await getProjects();
      final match = projects.where((p) => p.id == id);
      if (match.isNotEmpty) return match.first;

      // Si no estaba en el filtro actual, buscarlo directamente en la BD
      // Buscar por _id (interno de Roble) y también por id (PK real del DDL)
      List<Map<String, dynamic>> rows = await _roble.db.read('project', filters: {'_id': id});
      if (rows.isEmpty) {
        rows = await _roble.db.read('project', filters: {'id': id});
      }
      if (rows.isNotEmpty) {
        final row = rows.first;
        // Preferir 'id' (PK real del DDL) sobre '_id' (ID interno de Roble)
        final rowId = (row['id'] ?? row['_id'] ?? id).toString();
        final authorId = (row['author_id'] ?? row['authorId'])?.toString();
        String authorName = 'Autor';
        String authorCareer = 'Estudiante';
        String authorAvatar = 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150';
        if (authorId != null && authorId.isNotEmpty) {
          final authorProfile = await _getCollaboratorById(authorId);
          if (authorProfile != null) {
            authorName = authorProfile['name']?.toString() ?? authorName;
            authorCareer = authorProfile['career']?.toString() ?? authorCareer;
            authorAvatar = (authorProfile['avatar_url'] ?? authorProfile['avatarUrl'])?.toString() ?? authorAvatar;
          }
        }
        return Project(
          id: rowId,
          authorId: authorId ?? '',
          title: (row['title'] ?? 'Sin titulo').toString(),
          description: (row['description'] ?? '').toString(),
          vision: (row['vision'] ?? row['description'] ?? '').toString(),
          authorName: authorName,
          authorCareer: authorCareer,
          authorAvatarUrl: authorAvatar,
          categories: ['General'],
          matchPercentage: 85,
          imageUrl: (row['image_url'] ?? row['imageUrl'])?.toString(),
          vacancies: int.tryParse(row['vacancies']?.toString() ?? '') ?? 2,
          roles: [],
          members: [],
        );
      }
    } catch (e) {
      throw Exception('Error al cargar el proyecto $id: $e');
    }
    throw Exception('Proyecto no encontrado: $id');
  }

  @override
  Future<void> requestToJoin(String projectId) async {
    final userId = _roble.currentUserId;
    if (userId.isEmpty) throw Exception('Usuario no autenticado');

    // Garantizar que el postulante exista en collaborator (FK fk_app_applicant)
    try {
      final existing = await _roble.db.read('collaborator', filters: {'_id': userId});
      if (existing.isEmpty) {
        final cached = _roble.cachedUser;
        await _roble.db.create('collaborator', {
          'id': userId,
          'name': (cached?['name'] ?? cached?['userName'] ?? 'Colaborador').toString(),
          'career': (cached?['career'] ?? 'Estudiante').toString(),
          'avatar_url': (cached?['avatar_url'] ?? cached?['avatarUrl'] ??
              'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150').toString(),
        });
      }
    } catch (e) {
      // Si ya existe (duplicado), continuar de todas formas
    }

    final now = DateTime.now();
    final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    await _roble.db.create('application', {
      'project_id': projectId,
      'applicant_id': userId,
      'requested_role': 'Colaborador',
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
