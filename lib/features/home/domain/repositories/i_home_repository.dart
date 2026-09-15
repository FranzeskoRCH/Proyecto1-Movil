import '../models/collaborator_profile.dart';
import '../models/enrolled_project.dart';

/// Contrato de operaciones de datos visibles para la capa UI.
abstract class IHomeRepository {
  Future<CollaboratorProfile> getCollaboratorProfile();

  Future<List<EnrolledProject>> getEnrolledProjects();
}
