import '../../domain/models/collaborator_profile.dart';

/// Contrato del origen de datos de la pantalla de inicio.
abstract class IHomeSource {
  Future<CollaboratorProfile> getCollaboratorProfile();
}
