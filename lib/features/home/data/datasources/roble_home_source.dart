import '../../../../core/roble_service.dart';
import '../../domain/models/collaborator_profile.dart';
import '../../domain/models/enrolled_project.dart';
import 'i_home_source.dart';

class RobleHomeSource implements IHomeSource {
  final RobleService _roble = RobleService();

  @override
  Future<CollaboratorProfile> getCollaboratorProfile() async {
    final userId = _roble.currentUserId;
    final cached = _roble.cachedUser;

    String name = cached?['name'] ?? 'Colaborador';
    String avatarUrl = 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150';
    String career = 'Estudiante';
    List<String> skills = [];
    List<String> interests = [];

    try {
      if (userId.isNotEmpty) {
        // En Roble, _id en collaborator es el UUID del usuario
        final profiles = await _roble.db.read('collaborator', filters: {'_id': userId});
        if (profiles.isNotEmpty) {
          final p = profiles.first;
          name = p['name']?.toString() ?? name;
          avatarUrl = (p['avatar_url'] ?? p['avatarUrl'])?.toString() ?? avatarUrl;
          career = p['career']?.toString() ?? career;
        }

        // Leer skills
        final skillsData = await _roble.db.read('collaborator_skill', filters: {'collaborator_id': userId});
        final dbSkills = skillsData
            .map((s) => (s['skill_name'] ?? s['skillName'] ?? s['name'] ?? '').toString())
            .where((s) => s.isNotEmpty)
            .toList();
        if (dbSkills.isNotEmpty) skills = dbSkills;

        // Leer interests
        final interestsData = await _roble.db.read('collaborator_interest', filters: {'collaborator_id': userId});
        final dbInterests = interestsData
            .map((i) => (i['interest_name'] ?? i['interestName'] ?? i['name'] ?? '').toString())
            .where((i) => i.isNotEmpty)
            .toList();
        if (dbInterests.isNotEmpty) interests = dbInterests;
      }
    } catch (_) {
      // Si aún no existen datos o las tablas no están listas, mantener datos base seguros
    }

    if (skills.isEmpty) {
      skills = ['Flutter', 'Diseño UI/UX', 'Trabajo en equipo'];
    }
    if (interests.isEmpty) {
      interests = ['Tecnología', 'Innovación Social', 'Diseño'];
    }

    return CollaboratorProfile(
      name: name,
      avatarUrl: avatarUrl,
      career: career,
      skills: skills,
      interests: interests,
    );
  }

  @override
  Future<List<EnrolledProject>> getEnrolledProjects() async {
    final userId = _roble.currentUserId;
    if (userId.isEmpty) return [];

    final List<EnrolledProject> enrolled = [];
    final Set<String> addedProjectIds = {};

    try {
      // 1. Proyectos en los que es miembro aceptado (project_member)
      final members = await _roble.db.read('project_member', filters: {'collaborator_id': userId});

      for (final m in members) {
        final projectId = (m['project_id'] ?? m['projectId'])?.toString();
        if (projectId == null || projectId.isEmpty) continue;

        final projRows = await _roble.db.read('project', filters: {'_id': projectId});
        if (projRows.isEmpty) continue;
        final project = projRows.first;
        // Preferir id (PK real del DDL) sobre _id (interno de Roble)
        final realId = (project['id'] ?? project['_id'] ?? projectId).toString();

        String authorName = 'Autor';
        String authorAvatar = 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150';
        final authorId = (project['author_id'] ?? project['authorId'])?.toString();
        if (authorId != null && authorId.isNotEmpty) {
          final authorProfiles = await _roble.db.read('collaborator', filters: {'_id': authorId});
          if (authorProfiles.isNotEmpty) {
            authorName = authorProfiles.first['name']?.toString() ?? authorName;
            authorAvatar = (authorProfiles.first['avatar_url'] ?? authorProfiles.first['avatarUrl'])?.toString() ?? authorAvatar;
          }
        }

        if (!addedProjectIds.contains(realId)) {
          addedProjectIds.add(realId);
          enrolled.add(EnrolledProject(
            id: realId,
            title: project['title']?.toString() ?? 'Proyecto sin título',
            description: project['description']?.toString() ?? '',
            authorName: authorName,
            authorAvatarUrl: authorAvatar,
            role: m['discipline']?.toString() ?? m['role']?.toString() ?? 'Miembro',
          ));
        }
      }
    } catch (_) {}

    try {
      // 2. Proyectos a los que aplicó (application) — aparecen como "Aplicado"
      final applications = await _roble.db.read('application', filters: {'applicant_id': userId});

      for (final app in applications) {
        final projectId = (app['project_id'] ?? app['projectId'] ?? '').toString();
        if (projectId.isEmpty) continue;

        // Buscar proyecto por id real del DDL
        List<Map<String, dynamic>> projRows = await _roble.db.read('project', filters: {'_id': projectId});
        if (projRows.isEmpty) {
          projRows = await _roble.db.read('project', filters: {'id': projectId});
        }
        if (projRows.isEmpty) continue;
        final project = projRows.first;
        final realId = (project['id'] ?? project['_id'] ?? projectId).toString();

        if (addedProjectIds.contains(realId)) continue; // ya está como miembro
        addedProjectIds.add(realId);

        String authorName = 'Autor';
        String authorAvatar = 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150';
        final authorId = (project['author_id'] ?? project['authorId'])?.toString();
        if (authorId != null && authorId.isNotEmpty) {
          try {
            final authorProfiles = await _roble.db.read('collaborator', filters: {'_id': authorId});
            if (authorProfiles.isNotEmpty) {
              authorName = authorProfiles.first['name']?.toString() ?? authorName;
              authorAvatar = (authorProfiles.first['avatar_url'] ?? authorProfiles.first['avatarUrl'])?.toString() ?? authorAvatar;
            }
          } catch (_) {}
        }

        final status = app['status']?.toString() ?? 'underReview';
        final roleLabel = status == 'accepted' ? 'Aceptado' :
                          status == 'rejected' ? 'Rechazado' : 'Aplicado';

        enrolled.add(EnrolledProject(
          id: realId,
          title: project['title']?.toString() ?? 'Proyecto sin título',
          description: project['description']?.toString() ?? '',
          authorName: authorName,
          authorAvatarUrl: authorAvatar,
          role: roleLabel,
        ));
      }
    } catch (_) {}

    return enrolled;
  }
}
