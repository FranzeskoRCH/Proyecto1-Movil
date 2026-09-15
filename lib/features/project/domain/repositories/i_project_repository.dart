import '../models/applied_project.dart';
import '../models/created_project.dart';

/// Contrato de las operaciones de "Mis Proyectos" visibles para la capa UI.
abstract class IProjectRepository {
  Future<List<AppliedProject>> getAppliedProjects();

  Future<List<CreatedProject>> getCreatedProjects();

  Future<CreatedProject> getCreatedProjectById(String id);

  Future<void> acceptApplicant(String projectId, String applicantId);

  Future<void> rejectApplicant(String projectId, String applicantId);

  Future<void> removeMember(String projectId, String applicantId);
}
