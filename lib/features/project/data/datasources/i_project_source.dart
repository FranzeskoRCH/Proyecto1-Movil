import '../../domain/models/applied_project.dart';
import '../../domain/models/created_project.dart';

/// Contrato del origen de datos de la pantalla "Mis Proyectos".
abstract class IProjectSource {
  Future<List<AppliedProject>> getAppliedProjects();

  Future<List<CreatedProject>> getCreatedProjects();

  Future<CreatedProject> getCreatedProjectById(String id);

  Future<void> acceptApplicant(String projectId, String applicantId);

  Future<void> rejectApplicant(String projectId, String applicantId);

  Future<void> removeMember(String projectId, String applicantId);
}
