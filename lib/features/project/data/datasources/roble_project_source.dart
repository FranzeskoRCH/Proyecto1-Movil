import 'dart:convert';
import 'dart:io';
import 'package:movil_proyecto/core/roble_constants.dart';
import 'package:movil_proyecto/core/roble_service.dart';
import 'package:movil_proyecto/features/project/domain/models/applicant.dart';
import 'package:movil_proyecto/features/project/domain/models/application_status.dart';
import 'package:movil_proyecto/features/project/domain/models/applied_project.dart';
import 'package:movil_proyecto/features/project/domain/models/created_project.dart';
import 'i_project_source.dart';
import 'local/local_project_source.dart';

class RobleProjectSource implements IProjectSource {
  final RobleService _roble = RobleService();
  final LocalProjectSource _fallbackSource = LocalProjectSource();

  /// Helper: realiza un UPDATE en Roble usando el PAT si el token de usuario no tiene permisos RLS
  Future<void> _updateWithPat(String tableName, String robleId, Map<String, dynamic> updates) async {
    try {
      final client = HttpClient();
      final uri = Uri.parse('${RobleConstants.baseUrl}/database/${RobleConstants.contractId}/update');
      final req = await client.putUrl(uri);
      req.headers.set('Authorization', 'Bearer ${RobleConstants.projectToken}');
      req.headers.set('Content-Type', 'application/json');
      req.add(utf8.encode(jsonEncode({
        'tableName': tableName,
        'idColumn': '_id',
        'idValue': robleId,
        'updates': updates,
      })));
      await req.close();
      client.close();
    } catch (_) {}
  }

  /// Helper: obtiene un registro por su id (busca por _id interno de Roble y por id real del DDL).
  Future<Map<String, dynamic>?> _getById(String table, String id) async {
    try {
      final rows = await _roble.db.read(table, filters: {'_id': id});
      if (rows.isNotEmpty) return rows.first;
      // Buscar también por el campo 'id' real del DDL
      final rows2 = await _roble.db.read(table, filters: {'id': id});
      return rows2.isNotEmpty ? rows2.first : null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<AppliedProject>> getAppliedProjects() async {
    final userId = _roble.currentUserId;
    if (userId.isEmpty) {
      return await _fallbackSource.getAppliedProjects();
    }

    final List<AppliedProject> appliedProjects = [];

    try {
      final applications = await _roble.db.read('application', filters: {'applicant_id': userId});

      for (final app in applications) {
        final projectId = (app['project_id'] ?? app['projectId'] ?? '').toString();
        if (projectId.isEmpty) continue;

        final project = await _getById('project', projectId);
        if (project == null) continue;
        // Preferir 'id' (PK real del DDL) sobre '_id' (interno de Roble)
        final realProjectId = (project['id'] ?? project['_id'] ?? projectId).toString();

        // Categorías
        List<String> categories = [];
        try {
          final catRows = await _roble.db.read('project_category', filters: {'project_id': realProjectId});
          categories = catRows
              .map((c) => (c['category_name'] ?? c['categoryName'] ?? c['name'] ?? '').toString())
              .where((c) => c.isNotEmpty)
              .toList();
        } catch (_) {}

        // Autor
        String authorName = 'Autor';
        String authorCareer = 'Estudiante';
        String authorAvatar = 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150';
        // author_id en project apunta al _id de collaborator (= UUID del usuario auth en Roble)
        final authorId = project['author_id']?.toString() ?? project['authorId']?.toString();
        if (authorId != null && authorId.isNotEmpty) {
          try {
            final authorProfile = await _getById('collaborator', authorId);
            if (authorProfile != null) {
              authorName = authorProfile['name']?.toString() ?? authorName;
              authorCareer = authorProfile['career']?.toString() ?? authorCareer;
              authorAvatar = (authorProfile['avatar_url'] ?? authorProfile['avatarUrl'])?.toString() ?? authorAvatar;
            }
          } catch (_) {}
        }

        appliedProjects.add(
          AppliedProject(
            id: (app['_id'] ?? app['id'] ?? projectId).toString(),
            title: (project['title'] ?? 'Sin título').toString(),
            description: (project['description'] ?? '').toString(),
            vision: (project['vision'] ?? project['description'] ?? '').toString(),
            authorName: authorName,
            authorCareer: authorCareer,
            authorAvatarUrl: authorAvatar,
            categories: categories.isNotEmpty ? categories : ['General'],
            status: ApplicationStatus.fromName(app['status']?.toString()),
            appliedDate: (app['applied_date'] ?? app['appliedDate'] ?? 'Reciente').toString(),
          ),
        );
      }
      return appliedProjects;
    } catch (_) {
      return await _fallbackSource.getAppliedProjects();
    }
  }

  @override
  Future<List<CreatedProject>> getCreatedProjects() async {
    final userId = _roble.currentUserId;
    if (userId.isEmpty) {
      return await _fallbackSource.getCreatedProjects();
    }

    final List<CreatedProject> createdProjects = [];

    try {
      final projectRows = await _roble.db.read('project', filters: {'author_id': userId});

      for (final p in projectRows) {
        // Preferir 'id' (PK real del DDL) sobre '_id' (interno de Roble)
        final projectId = (p['id'] ?? p['_id'] ?? '').toString();
        if (projectId.isEmpty) continue;

        final List<Applicant> applicants = [];

        // 1. Leer miembros aceptados de la tabla 'project_member'
        final Set<String> acceptedCollabIds = {};
        final Map<String, Map<String, dynamic>> memberRowsByCollabId = {};
        try {
          final members = await _roble.db.read('project_member', filters: {'project_id': projectId});
          for (final m in members) {
            final cId = (m['collaborator_id'] ?? m['collaboratorId'] ?? '').toString();
            if (cId.isNotEmpty) {
              acceptedCollabIds.add(cId);
              memberRowsByCollabId[cId] = m;
            }
          }
        } catch (_) {}

        // 2. Leer postulantes de la tabla 'application'
        try {
          final appRows = await _roble.db.read('application', filters: {'project_id': projectId});
          for (final a in appRows) {
            final applicantCollabId = (a['applicant_id'] ?? a['applicantId'] ?? '').toString();
            String name = 'Postulante';
            String avatarUrl = 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150';
            String career = 'Estudiante';

            if (applicantCollabId.isNotEmpty) {
              try {
                final profile = await _getById('collaborator', applicantCollabId);
                if (profile != null) {
                  name = profile['name']?.toString() ?? name;
                  avatarUrl = (profile['avatar_url'] ?? profile['avatarUrl'])?.toString() ?? avatarUrl;
                  career = profile['career']?.toString() ?? career;
                }
              } catch (_) {}
            }

            final isAcceptedInMembers = acceptedCollabIds.contains(applicantCollabId);
            final status = isAcceptedInMembers
                ? ApplicationStatus.accepted
                : ApplicationStatus.fromName(a['status']?.toString());

            final memberRow = memberRowsByCollabId[applicantCollabId];
            final tileId = isAcceptedInMembers
                ? (memberRow?['_id'] ?? memberRow?['id'] ?? applicantCollabId).toString()
                : (a['_id'] ?? a['id'] ?? '').toString();

            applicants.add(
              Applicant(
                id: tileId,
                collaboratorId: applicantCollabId,
                name: name,
                avatarUrl: avatarUrl,
                career: career,
                requestedRole: (a['requested_role'] ?? a['requestedRole'] ?? 'Colaborador').toString(),
                status: status,
              ),
            );
          }
        } catch (_) {}

        // 3. Agregar miembros de project_member que no estén en la lista de application
        for (final cId in acceptedCollabIds) {
          final alreadyAdded = applicants.any((a) => a.collaboratorId == cId);
          if (!alreadyAdded) {
            final m = memberRowsByCollabId[cId];
            String name = 'Miembro del Equipo';
            String avatarUrl = 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150';
            String career = 'Estudiante';
            try {
              final profile = await _getById('collaborator', cId);
              if (profile != null) {
                name = profile['name']?.toString() ?? name;
                avatarUrl = (profile['avatar_url'] ?? profile['avatarUrl'])?.toString() ?? avatarUrl;
                career = profile['career']?.toString() ?? career;
              }
            } catch (_) {}

            applicants.add(
              Applicant(
                id: (m?['_id'] ?? m?['id'] ?? cId).toString(),
                collaboratorId: cId,
                name: name,
                avatarUrl: avatarUrl,
                career: career,
                requestedRole: (m?['discipline'] ?? 'Colaborador').toString(),
                status: ApplicationStatus.accepted,
              ),
            );
          }
        }

        createdProjects.add(
          CreatedProject(
            id: projectId,
            title: (p['title'] ?? 'Sin título').toString(),
            description: (p['description'] ?? '').toString(),
            status: CreatedProjectStatus.fromName(p['status']?.toString()),
            vacancies: int.tryParse(p['vacancies']?.toString() ?? '') ?? 3,
            applicants: applicants,
          ),
        );
      }
      return createdProjects;
    } catch (e) {
      throw Exception('Error al obtener proyectos creados: $e');
    }
  }

  @override
  Future<CreatedProject> getCreatedProjectById(String id) async {
    final list = await getCreatedProjects();
    return list.firstWhere(
      (p) => p.id == id,
      orElse: () => throw Exception('Proyecto creado no encontrado: $id'),
    );
  }

  @override
  Future<void> acceptApplicant(String projectId, String applicantId) async {
    String collaboratorId = '';
    String? applicationRobleId;

    // Buscar en application por _id
    try {
      final apps = await _roble.db.read('application', filters: {'_id': applicantId});
      if (apps.isNotEmpty) {
        applicationRobleId = apps.first['_id']?.toString();
        collaboratorId = (apps.first['applicant_id'] ?? apps.first['applicantId'] ?? '').toString();
      }
    } catch (_) {}

    // Si no encontró por _id, buscar por id del DDL
    if (collaboratorId.isEmpty) {
      try {
        final apps = await _roble.db.read('application', filters: {'id': applicantId});
        if (apps.isNotEmpty) {
          applicationRobleId = apps.first['_id']?.toString();
          collaboratorId = (apps.first['applicant_id'] ?? apps.first['applicantId'] ?? '').toString();
        }
      } catch (_) {}
    }

    if (collaboratorId.isEmpty) {
      collaboratorId = applicantId;
    }

    // 1. Actualizar estado de la aplicacion en DB (con fallback PAT)
    final targetAppId = applicationRobleId ?? applicantId;
    try {
      await _roble.db.update('application', targetAppId, {'status': 'accepted'});
    } catch (_) {
      await _updateWithPat('application', targetAppId, {'status': 'accepted'});
    }

    // 2. Insertar en project_member si no existe
    try {
      final existing = await _roble.db.read('project_member', filters: {
        'project_id': projectId,
        'collaborator_id': collaboratorId,
      });
      if (existing.isEmpty) {
        await _roble.db.create('project_member', {
          'project_id': projectId,
          'collaborator_id': collaboratorId,
          'discipline': 'Colaborador',
        });
      }
    } catch (e) {
      // Ignorar si project_member ya existe
    }
  }

  @override
  Future<void> rejectApplicant(String projectId, String applicantId) async {
    String? applicationRobleId;
    try {
      final apps = await _roble.db.read('application', filters: {'_id': applicantId});
      if (apps.isNotEmpty) {
        applicationRobleId = apps.first['_id']?.toString();
      }
    } catch (_) {}

    if (applicationRobleId == null) {
      try {
        final apps = await _roble.db.read('application', filters: {'id': applicantId});
        if (apps.isNotEmpty) {
          applicationRobleId = apps.first['_id']?.toString();
        }
      } catch (_) {}
    }

    final targetId = applicationRobleId ?? applicantId;
    try {
      await _roble.db.update('application', targetId, {'status': 'rejected'});
    } catch (_) {
      await _updateWithPat('application', targetId, {'status': 'rejected'});
    }
  }

  @override
  Future<void> removeMember(String projectId, String applicantId) async {
    try {
      // 1. Intentar borrar directo por _id
      await _roble.db.delete('project_member', applicantId);
    } catch (_) {
      // 2. Si falla, buscar por project_id y collaborator_id
      try {
        final members = await _roble.db.read('project_member', filters: {
          'project_id': projectId,
          'collaborator_id': applicantId,
        });
        for (final m in members) {
          final mId = (m['_id'] ?? m['id'])?.toString();
          if (mId != null) {
            await _roble.db.delete('project_member', mId);
          }
        }
      } catch (_) {}
    }
  }
}

