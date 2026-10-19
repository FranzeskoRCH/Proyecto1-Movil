import '../../domain/models/project_event.dart';
import '../../domain/models/project_task.dart';
import '../../domain/models/workspace_member.dart';
import '../../domain/repositories/i_workspace_repository.dart';
import '../datasources/i_workspace_source.dart';

/// Adaptador entre el contrato de dominio y el origen de datos.
class WorkspaceRepository implements IWorkspaceRepository {
  WorkspaceRepository(this.source);

  final IWorkspaceSource source;

  @override
  String get currentUserId => source.currentUserId;

  @override
  String get currentUserName => source.currentUserName;

  @override
  Future<List<ProjectTask>> getTasks(String projectId) =>
      source.getTasks(projectId);

  @override
  Future<ProjectTask> createTask(ProjectTask task) => source.createTask(task);

  @override
  Future<void> updateTask(ProjectTask task) => source.updateTask(task);

  @override
  Future<void> deleteTask(String taskId) => source.deleteTask(taskId);

  @override
  Future<List<ProjectEvent>> getEvents(String projectId) =>
      source.getEvents(projectId);

  @override
  Future<ProjectEvent> createEvent(ProjectEvent event) =>
      source.createEvent(event);

  @override
  Future<void> deleteEvent(String eventId) => source.deleteEvent(eventId);

  @override
  Future<List<WorkspaceMember>> getMembers(String projectId) =>
      source.getMembers(projectId);
}
