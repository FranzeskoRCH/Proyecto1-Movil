import '../../domain/models/collaborator_profile.dart';
import '../../domain/models/enrolled_project.dart';

/// Contrato del origen de datos de la pantalla de inicio.
abstract class IHomeSource {
  Future<CollaboratorProfile> getCollaboratorProfile();

  Future<List<EnrolledProject>> getEnrolledProjects();
}
