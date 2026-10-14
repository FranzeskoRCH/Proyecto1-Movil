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

  @override
  Future<void> withdrawApplication(String applicationId) async =>
      await source.withdrawApplication(applicationId);

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
  }) async =>
      await source.updateProject(
        projectId: projectId,
        title: title,
        description: description,
        vision: vision,
        vacancies: vacancies,
        status: status,
        categories: categories,
        roles: roles,
        imageUrl: imageUrl,
      );

  @override
  Future<void> deleteProject(String projectId) async =>
      await source.deleteProject(projectId);
}
