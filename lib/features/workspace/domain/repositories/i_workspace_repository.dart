import '../models/project_event.dart';
import '../models/project_task.dart';
import '../models/workspace_member.dart';

/// Contrato del dominio para el espacio de trabajo de un proyecto.
abstract class IWorkspaceRepository {
  String get currentUserId;
  String get currentUserName;

  Future<List<ProjectTask>> getTasks(String projectId);
  Future<ProjectTask> createTask(ProjectTask task);
  Future<void> updateTask(ProjectTask task);
  Future<void> deleteTask(String taskId);

  Future<List<ProjectEvent>> getEvents(String projectId);
  Future<ProjectEvent> createEvent(ProjectEvent event);
  Future<void> deleteEvent(String eventId);

  Future<List<WorkspaceMember>> getMembers(String projectId);
}
