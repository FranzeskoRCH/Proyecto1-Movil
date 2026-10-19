import 'package:loggy/loggy.dart';
import 'package:movil_proyecto/core/roble_service.dart';
import 'package:movil_proyecto/features/project/domain/models/applicant.dart';
import 'package:movil_proyecto/features/project/domain/models/application_status.dart';
import 'package:movil_proyecto/features/project/domain/models/applied_project.dart';
import 'package:movil_proyecto/features/project/domain/models/created_project.dart';

import 'i_project_source.dart';
import 'local/local_project_source.dart';

class RobleProjectSource with NetworkLoggy implements IProjectSource {
  final RobleService _roble = RobleService();
  final LocalProjectSource _fallbackSource = LocalProjectSource();

  /// Consultas guardadas en la consola de Roble. Los permisos por rol de la
  /// API no dejan al autor leer ni actualizar las filas de `application` que
  /// crearon otros usuarios; las consultas guardadas sí, y validan en el SQL
  /// que quien llama sea el autor del proyecto.
  static const String _applicationsQueryName = 'postulaciones_de_proyecto';
  static const String _respondQueryName = 'responder_postulacion';

  /// `collaborator_id` de cada postulación cargada (`_id` de application →
  /// usuario), para aceptar sin tener que volver a leer `application`.
  final Map<String, String> _collaboratorByApplication = {};

  /// Postulaciones de un proyecto. Intenta la consulta guardada y, si no
  /// existe, lee la tabla directamente (solo funciona si el rol lo permite).
  Future<List<Map<String, dynamic>>> _readApplications(
    String projectId,
  ) async {
    try {
      final result = await _roble.db.executeQueryByName(
        _applicationsQueryName,
        params: [projectId, _roble.currentUserId],
      );
      return result.rows
          .whereType<Map>()
          .map((row) => Map<String, dynamic>.from(row))
          .toList();
    } catch (e) {
      loggy.warning(
        '[ROBLE_PROJECT] Consulta guardada "$_applicationsQueryName" no '
        'disponible ($e); leyendo la tabla application.',
      );
    }
    return _roble.db.read('application', filters: {'project_id': projectId});
  }

  /// Cambia el estado de una postulación (`accepted` / `rejected`).
  ///
  /// Primero por la consulta guardada; si no existe, con `update` directo.
  /// Si ambos fallan, el error se propaga para no mostrar un éxito falso.
  Future<void> _setApplicationStatus(String applicationId, String status) async {
    try {
      final result = await _roble.db.executeQueryByName(
        _respondQueryName,
        params: [applicationId, status, _roble.currentUserId],
      );
      if (result.rows.isNotEmpty) return;
      loggy.warning(
        '[ROBLE_PROJECT] "$_respondQueryName" no actualizó ninguna fila '
        '($applicationId); probando update directo.',
      );
    } catch (e) {
      loggy.warning(
        '[ROBLE_PROJECT] Consulta guardada "$_respondQueryName" no '
        'disponible ($e); probando update directo.',
      );
    }
    await _roble.db.update('application', applicationId, {'status': status});
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

  int _vacanciesOf(Map<String, dynamic>? project) =>
      int.tryParse(project?['vacancies']?.toString() ?? '') ?? 0;

  Future<List<Map<String, dynamic>>> _readMembers(String projectId) async {
    try {
      return await _roble.db.read(
        'project_member',
        filters: {'project_id': projectId},
      );
    } catch (_) {
      return const [];
    }
  }

  String _collaboratorIdOf(Map<String, dynamic> member) =>
      (member['collaborator_id'] ?? member['collaboratorId'] ?? '').toString();

  /// Mantiene el estado del proyecto entre `recruiting` y `active` según las
  /// vacantes ocupadas. No toca estados manuales (`completed`).
  Future<void> _syncProjectStatus(
    Map<String, dynamic>? project,
    String projectId, {
    required int memberCount,
  }) async {
    if (project == null) return;
    final currentStatus = project['status']?.toString() ?? '';
    if (currentStatus == 'completed') return;

    final vacancies = _vacanciesOf(project);
    if (vacancies <= 0) return;

    final newStatus = memberCount >= vacancies ? 'active' : 'recruiting';
    if (currentStatus == newStatus) return;

    final robleId = (project['_id'] ?? projectId).toString();
    try {
      await _roble.db.update('project', robleId, {'status': newStatus});
    } catch (_) {}
  }

  @override
  Future<List<AppliedProject>> getAppliedProjects() async {
    final userId = _roble.currentUserId;
    if (userId.isEmpty) {
      return await _fallbackSource.getAppliedProjects();
    }

    final List<AppliedProject> appliedProjects = [];

    try {
      final applications = await _roble.db.read(
        'application',
        filters: {'applicant_id': userId},
      );

      for (final app in applications) {
        final projectId =
            (app['project_id'] ?? app['projectId'] ?? '').toString();
        if (projectId.isEmpty) continue;

        final project = await _getById('project', projectId);
        if (project == null) continue;
        // Preferir 'id' (PK real del DDL) sobre '_id' (interno de Roble)
        final realProjectId =
            (project['id'] ?? project['_id'] ?? projectId).toString();

        // Categorías
        List<String> categories = [];
        try {
          final catRows = await _roble.db.read(
            'project_category',
            filters: {'project_id': realProjectId},
          );
          categories = catRows
              .map(
                (c) =>
                    (c['category_name'] ?? c['categoryName'] ?? c['name'] ?? '')
                        .toString(),
              )
              .where((c) => c.isNotEmpty)
              .toList();
        } catch (_) {}

        // Autor
        String authorName = 'Autor';
        String authorCareer = 'Estudiante';
        String authorAvatar =
            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150';
        // author_id en project apunta al _id de collaborator (= UUID del usuario auth en Roble)
        final authorId =
            project['author_id']?.toString() ?? project['authorId']?.toString();
        if (authorId != null && authorId.isNotEmpty) {
          try {
            final authorProfile = await _getById('collaborator', authorId);
            if (authorProfile != null) {
              authorName = authorProfile['name']?.toString() ?? authorName;
              authorCareer =
                  authorProfile['career']?.toString() ?? authorCareer;
              authorAvatar =
                  (authorProfile['avatar_url'] ?? authorProfile['avatarUrl'])
                          ?.toString() ??
                      authorAvatar;
            }
          } catch (_) {}
        }

        appliedProjects.add(
          AppliedProject(
            id: (app['_id'] ?? app['id'] ?? projectId).toString(),
            title: (project['title'] ?? 'Sin título').toString(),
            description: (project['description'] ?? '').toString(),
            vision:
                (project['vision'] ?? project['description'] ?? '').toString(),
            authorName: authorName,
            authorCareer: authorCareer,
            authorAvatarUrl: authorAvatar,
            categories: categories.isNotEmpty ? categories : ['General'],
            status: ApplicationStatus.fromName(app['status']?.toString()),
            appliedDate:
                (app['applied_date'] ?? app['appliedDate'] ?? 'Reciente')
                    .toString(),
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
      final projectRows = await _roble.db.read(
        'project',
        filters: {'author_id': userId},
      );

      for (final p in projectRows) {
        // Preferir 'id' (PK real del DDL) sobre '_id' (interno de Roble)
        final projectId = (p['id'] ?? p['_id'] ?? '').toString();
        if (projectId.isEmpty) continue;

        final List<Applicant> applicants = [];

        // 1. Leer miembros aceptados de la tabla 'project_member'
        final Set<String> acceptedCollabIds = {};
        final Map<String, Map<String, dynamic>> memberRowsByCollabId = {};
        try {
          final members = await _roble.db.read(
            'project_member',
            filters: {'project_id': projectId},
          );
          for (final m in members) {
            final cId =
                (m['collaborator_id'] ?? m['collaboratorId'] ?? '').toString();
            if (cId.isNotEmpty) {
              acceptedCollabIds.add(cId);
              memberRowsByCollabId[cId] = m;
            }
          }
        } catch (_) {}

        // 2. Leer postulantes (consulta guardada o tabla 'application')
        try {
          final appRows = await _readApplications(projectId);
          loggy.info(
            '[ROBLE_PROJECT] Proyecto $projectId: ${appRows.length} '
            'postulaciones leídas, ${acceptedCollabIds.length} miembros.',
          );
          for (final a in appRows) {
            final applicantCollabId =
                (a['applicant_id'] ?? a['applicantId'] ?? '').toString();
            final applicationId = (a['_id'] ?? a['id'] ?? '').toString();
            if (applicationId.isNotEmpty && applicantCollabId.isNotEmpty) {
              _collaboratorByApplication[applicationId] = applicantCollabId;
            }
            // La consulta guardada ya trae el perfil del postulante.
            final joinedName = a['applicant_name']?.toString();
            String name = joinedName ?? 'Postulante';
            String avatarUrl = a['applicant_avatar_url']?.toString() ??
                'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150';
            String career = a['applicant_career']?.toString() ?? 'Estudiante';

            if (joinedName == null && applicantCollabId.isNotEmpty) {
              try {
                final profile = await _getById(
                  'collaborator',
                  applicantCollabId,
                );
                if (profile != null) {
                  name = profile['name']?.toString() ?? name;
                  avatarUrl = (profile['avatar_url'] ?? profile['avatarUrl'])
                          ?.toString() ??
                      avatarUrl;
                  career = profile['career']?.toString() ?? career;
                }
              } catch (_) {}
            }

            final isAcceptedInMembers = acceptedCollabIds.contains(
              applicantCollabId,
            );
            final status = isAcceptedInMembers
                ? ApplicationStatus.accepted
                : ApplicationStatus.fromName(a['status']?.toString());

            final memberRow = memberRowsByCollabId[applicantCollabId];
            final tileId = isAcceptedInMembers
                ? (memberRow?['_id'] ?? memberRow?['id'] ?? applicantCollabId)
                    .toString()
                : (a['_id'] ?? a['id'] ?? '').toString();

            applicants.add(
              Applicant(
                id: tileId,
                collaboratorId: applicantCollabId,
                name: name,
                avatarUrl: avatarUrl,
                career: career,
                requestedRole:
                    (a['requested_role'] ?? a['requestedRole'] ?? 'Colaborador')
                        .toString(),
                status: status,
              ),
            );
          }
        } catch (e) {
          // Si la política RLS de `application` no deja al autor leer las
          // postulaciones de sus proyectos, el error termina aquí.
          loggy.error(
            '[ROBLE_PROJECT] No se pudieron leer las postulaciones del '
            'proyecto $projectId: $e',
          );
        }

        // 3. Agregar miembros de project_member que no estén en la lista de application
        for (final cId in acceptedCollabIds) {
          final alreadyAdded = applicants.any((a) => a.collaboratorId == cId);
          if (!alreadyAdded) {
            final m = memberRowsByCollabId[cId];
            String name = 'Miembro del Equipo';
            String avatarUrl =
                'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150';
            String career = 'Estudiante';
            try {
              final profile = await _getById('collaborator', cId);
              if (profile != null) {
                name = profile['name']?.toString() ?? name;
                avatarUrl = (profile['avatar_url'] ?? profile['avatarUrl'])
                        ?.toString() ??
                    avatarUrl;
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
            vision: (p['vision'] ?? '').toString(),
            imageUrl: (p['image_url'] ?? p['imageUrl'] ?? '').toString(),
            categories: await _readChildValues(
              'project_category',
              projectId,
              'category_name',
            ),
            roles: await _readChildValues(
              'project_role',
              projectId,
              'role_name',
            ),
            status: CreatedProjectStatus.fromName(p['status']?.toString()),
            vacancies: int.tryParse(p['vacancies']?.toString() ?? '') ?? 2,
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
    // El usuario de la postulación ya se conoce si se cargó con el proyecto.
    String collaboratorId = _collaboratorByApplication[applicantId] ?? '';
    String? applicationRobleId = collaboratorId.isEmpty ? null : applicantId;

    // Si no, buscar en application por _id
    if (collaboratorId.isEmpty) {
      try {
        final apps = await _roble.db.read(
          'application',
          filters: {'_id': applicantId},
        );
        if (apps.isNotEmpty) {
          applicationRobleId = apps.first['_id']?.toString();
          collaboratorId =
              (apps.first['applicant_id'] ?? apps.first['applicantId'] ?? '')
                  .toString();
        }
      } catch (_) {}
    }

    // Si no encontró por _id, buscar por id del DDL
    if (collaboratorId.isEmpty) {
      try {
        final apps = await _roble.db.read(
          'application',
          filters: {'id': applicantId},
        );
        if (apps.isNotEmpty) {
          applicationRobleId = apps.first['_id']?.toString();
          collaboratorId =
              (apps.first['applicant_id'] ?? apps.first['applicantId'] ?? '')
                  .toString();
        }
      } catch (_) {}
    }

    // Sin el usuario no se puede crear el project_member: usar el id de la
    // postulación como collaborator_id dejaría una fila corrupta.
    if (collaboratorId.isEmpty) {
      throw Exception('No se encontró la postulación $applicantId.');
    }

    // 0. Verificar capacidad: no aceptar por encima de las vacantes.
    final projectRow = await _getById('project', projectId);
    final vacancies = _vacanciesOf(projectRow);
    final members = await _readMembers(projectId);
    final alreadyMember =
        members.any((m) => _collaboratorIdOf(m) == collaboratorId);
    if (!alreadyMember && vacancies > 0 && members.length >= vacancies) {
      throw Exception('El proyecto ya alcanzó sus $vacancies vacantes.');
    }

    // 1. Actualizar estado de la postulación
    await _setApplicationStatus(applicationRobleId ?? applicantId, 'accepted');

    // 2. Insertar en project_member si no existe
    if (!alreadyMember) {
      try {
        await _roble.db.create('project_member', {
          'project_id': projectId,
          'collaborator_id': collaboratorId,
          'discipline': 'Colaborador',
        });
      } catch (e) {
        // Ignorar si project_member ya existe
      }
    }

    // 3. Avanzar el estado del proyecto (recruiting → active) si se llenó.
    await _syncProjectStatus(
      projectRow,
      projectId,
      memberCount: alreadyMember ? members.length : members.length + 1,
    );
  }

  @override
  Future<void> rejectApplicant(String projectId, String applicantId) async {
    // Las filas cargadas con el proyecto ya traen el `_id` de la postulación.
    String? applicationRobleId =
        _collaboratorByApplication.containsKey(applicantId) ? applicantId : null;
    if (applicationRobleId == null) {
      try {
        final apps = await _roble.db.read(
          'application',
          filters: {'_id': applicantId},
        );
        if (apps.isNotEmpty) {
          applicationRobleId = apps.first['_id']?.toString();
        }
      } catch (_) {}
    }

    if (applicationRobleId == null) {
      try {
        final apps = await _roble.db.read(
          'application',
          filters: {'id': applicantId},
        );
        if (apps.isNotEmpty) {
          applicationRobleId = apps.first['_id']?.toString();
        }
      } catch (_) {}
    }

    await _setApplicationStatus(applicationRobleId ?? applicantId, 'rejected');
  }

  @override
  Future<void> removeMember(String projectId, String applicantId) async {
    try {
      // 1. Intentar borrar directo por _id
      await _roble.db.delete('project_member', applicantId);
    } catch (_) {
      // 2. Si falla, buscar la fila real por project_id y collaborator_id.
      //    Si esta también falla, el error se propaga (no se oculta).
      final members = await _roble.db.read(
        'project_member',
        filters: {'project_id': projectId, 'collaborator_id': applicantId},
      );
      for (final m in members) {
        final mId = (m['_id'] ?? m['id'])?.toString();
        if (mId != null) {
          await _roble.db.delete('project_member', mId);
        }
      }
    }

    // Liberar la vacante: el proyecto vuelve a `recruiting` si baja el cupo.
    final projectRow = await _getById('project', projectId);
    final remaining = await _readMembers(projectId);
    await _syncProjectStatus(
      projectRow,
      projectId,
      memberCount: remaining.length,
    );
  }

  @override
  Future<void> withdrawApplication(String applicationId) async {
    try {
      await _roble.db.delete('application', applicationId);
    } catch (_) {
      // Fallback: buscar por _id y borrar el registro encontrado. Si vuelve a
      // fallar, el error se propaga para no reportar un éxito falso.
      final rows = await _roble.db.read(
        'application',
        filters: {'_id': applicationId},
      );
      for (final r in rows) {
        final id = (r['_id'] ?? r['id'])?.toString();
        if (id != null) {
          await _roble.db.delete('application', id);
        }
      }
    }
  }

  /// Lee los valores de una tabla hija (categorías o roles) de un proyecto.
  Future<List<String>> _readChildValues(
    String table,
    String projectId,
    String valueField,
  ) async {
    try {
      final rows = await _roble.db.read(
        table,
        filters: {'project_id': projectId},
      );
      return rows
          .map((r) => (r[valueField] ?? r['name'] ?? '').toString())
          .where((v) => v.isNotEmpty)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  /// Reemplaza por completo las filas hijas de un proyecto (categorías o roles).
  Future<void> _replaceChildRows(
    String table,
    String projectId,
    String valueField,
    List<String> values,
  ) async {
    try {
      final rows = await _roble.db.read(
        table,
        filters: {'project_id': projectId},
      );
      for (final r in rows) {
        final id = (r['_id'] ?? r['id'])?.toString();
        if (id != null) {
          await _roble.db.delete(table, id);
        }
      }
    } catch (_) {}

    for (final value in values) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) continue;
      try {
        await _roble.db.create(table, {
          'project_id': projectId,
          valueField: trimmed,
        });
      } catch (_) {}
    }
  }

  @override
  Future<void> updateProject({
    required String projectId,
    required String title,
    required String description,
    required String vision,
    required int vacancies,
    required CreatedProjectStatus status,
    required List<String> categories,
    required List<String> roles,
    String? imageUrl,
  }) async {
    final row = await _getById('project', projectId);
    final robleId = (row?['_id'] ?? projectId).toString();

    await _roble.db.update('project', robleId, {
      'title': title,
      'description': description,
      'vision': vision,
      'vacancies': vacancies,
      'status': status.name,
      if (imageUrl != null && imageUrl.isNotEmpty) 'image_url': imageUrl,
    });

    await _replaceChildRows(
      'project_category',
      projectId,
      'category_name',
      categories,
    );
    await _replaceChildRows('project_role', projectId, 'role_name', roles);
  }

  @override
  Future<void> deleteProject(String projectId) async {
    // Borrar primero los datos asociados (best-effort) y luego el proyecto.
    for (final table in const [
      'project_category',
      'project_role',
      'project_member',
      'application',
      'project_task',
      'project_event',
    ]) {
      try {
        final rows = await _roble.db.read(
          table,
          filters: {'project_id': projectId},
        );
        for (final r in rows) {
          final id = (r['_id'] ?? r['id'])?.toString();
          if (id != null) {
            await _roble.db.delete(table, id);
          }
        }
      } catch (_) {}
    }

    final row = await _getById('project', projectId);
    final robleId = (row?['_id'] ?? projectId).toString();
    await _roble.db.delete('project', robleId);
  }
}
