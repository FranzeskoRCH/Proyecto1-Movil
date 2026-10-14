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

  /// Retira una postulación enviada (borra la application del usuario).
  Future<void> withdrawApplication(String applicationId);

  /// Actualiza los datos de un proyecto propio y reemplaza sus categorías y roles.
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
  });

  /// Elimina un proyecto propio junto con sus categorías, roles, miembros y postulaciones.
  Future<void> deleteProject(String projectId);
}
