import '../../domain/models/applied_project.dart';
import '../../domain/models/created_project.dart';
import '../../domain/repositories/i_project_repository.dart';
import '../datasources/i_project_source.dart';

/// Adaptador entre el contrato de dominio y el origen de datos.
class ProjectRepository implements IProjectRepository {
  late IProjectSource source;

  ProjectRepository(this.source);

  @override
  Future<List<AppliedProject>> getAppliedProjects() async =>
      await source.getAppliedProjects();

  @override
  Future<List<CreatedProject>> getCreatedProjects() async =>
      await source.getCreatedProjects();

  @override
  Future<CreatedProject> getCreatedProjectById(String id) async =>
      await source.getCreatedProjectById(id);

  @override
  Future<void> acceptApplicant(String projectId, String applicantId) async =>
      await source.acceptApplicant(projectId, applicantId);

  @override
  Future<void> rejectApplicant(String projectId, String applicantId) async =>
      await source.rejectApplicant(projectId, applicantId);

  @override
  Future<void> removeMember(String projectId, String applicantId) async =>
      await source.removeMember(projectId, applicantId);
}
