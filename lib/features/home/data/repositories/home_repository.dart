import '../../domain/models/collaborator_profile.dart';
import '../../domain/models/enrolled_project.dart';
import '../../domain/repositories/i_home_repository.dart';
import '../datasources/i_home_source.dart';

/// Adaptador entre el contrato de dominio y el origen de datos.
class HomeRepository implements IHomeRepository {
  late IHomeSource source;

  HomeRepository(this.source);

  @override
  Future<CollaboratorProfile> getCollaboratorProfile() async =>
      await source.getCollaboratorProfile();

  @override
  Future<List<EnrolledProject>> getEnrolledProjects() async =>
      await source.getEnrolledProjects();
}
