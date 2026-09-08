import '../models/collaborator_profile.dart';

/// Contrato de operaciones de datos visibles para la capa UI.
abstract class IHomeRepository {
  Future<CollaboratorProfile> getCollaboratorProfile();
}
