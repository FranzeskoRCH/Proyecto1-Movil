import 'package:loggy/loggy.dart';

import '../../../../core/roble_service.dart';
import '../../domain/models/project_event.dart';
import '../../domain/models/project_task.dart';
import '../../domain/models/workspace_member.dart';
import 'i_workspace_source.dart';

/// Espacio de trabajo guardado en las tablas `project_task` y `project_event`
/// de Roble.
class RobleWorkspaceSource with NetworkLoggy implements IWorkspaceSource {
  final RobleService _roble = RobleService();

  static const String _tasksTable = 'project_task';
  static const String _eventsTable = 'project_event';

  @override
  String get currentUserId => _roble.currentUserId;

  @override
  String get currentUserName {
    final cached = _roble.cachedUser;
    final name = (cached?['name'] ?? cached?['userName'] ?? '').toString();
    return name.isEmpty ? 'Tú' : name;
  }

  @override
  Future<List<ProjectTask>> getTasks(String projectId) async {
    final rows =
        await _roble.db.read(_tasksTable, filters: {'project_id': projectId});
    loggy.info('[ROBLE_WORKSPACE] $projectId: ${rows.length} tareas.');
    return rows.map(ProjectTask.fromJson).toList();
  }

  @override
  Future<ProjectTask> createTask(ProjectTask task) async {
    final row = await _roble.db.create(_tasksTable, task.toJson());
    return ProjectTask.fromJson(row);
  }

  @override
  Future<void> updateTask(ProjectTask task) async {
    await _roble.db.update(_tasksTable, task.id, task.toJson());
  }

  @override
  Future<void> deleteTask(String taskId) async {
    await _roble.db.delete(_tasksTable, taskId);
  }

  @override
  Future<List<ProjectEvent>> getEvents(String projectId) async {
    final rows =
        await _roble.db.read(_eventsTable, filters: {'project_id': projectId});
    loggy.info('[ROBLE_WORKSPACE] $projectId: ${rows.length} fechas.');
    return rows.map(ProjectEvent.fromJson).toList();
  }

  @override
  Future<ProjectEvent> createEvent(ProjectEvent event) async {
    final row = await _roble.db.create(_eventsTable, event.toJson());
    return ProjectEvent.fromJson(row);
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    await _roble.db.delete(_eventsTable, eventId);
  }

  @override
  Future<List<WorkspaceMember>> getMembers(String projectId) async {
    final members = <WorkspaceMember>[];
    final seen = <String>{};

    // Creador del proyecto.
    try {
      var projects =
          await _roble.db.read('project', filters: {'id': projectId});
      if (projects.isEmpty) {
        projects = await _roble.db.read('project', filters: {'_id': projectId});
      }
      final authorId =
          projects.isEmpty ? '' : (projects.first['author_id'] ?? '').toString();
      if (authorId.isNotEmpty) {
        members.add(await _memberFor(authorId, role: 'Líder', isOwner: true));
        seen.add(authorId);
      }
    } catch (e) {
      loggy.warning('[ROBLE_WORKSPACE] No se pudo leer el autor: $e');
    }

    // Integrantes aceptados.
    try {
      final rows = await _roble.db
          .read('project_member', filters: {'project_id': projectId});
      for (final row in rows) {
        final id = (row['collaborator_id'] ?? '').toString();
        if (id.isEmpty || !seen.add(id)) continue;
        members.add(
          await _memberFor(
            id,
            role: (row['discipline'] ?? 'Colaborador').toString(),
          ),
        );
      }
    } catch (e) {
      loggy.warning('[ROBLE_WORKSPACE] No se pudieron leer los miembros: $e');
    }

    return members;
  }

  Future<WorkspaceMember> _memberFor(
    String userId, {
    required String role,
    bool isOwner = false,
  }) async {
    final profile = await _roble.findCollaborator(userId);
    return WorkspaceMember(
      id: userId,
      name: (profile?['name'] ?? 'Colaborador').toString(),
      avatarUrl: (profile?['avatar_url'] ?? profile?['avatarUrl'] ?? '')
          .toString(),
      role: role,
      isOwner: isOwner,
    );
  }
}
