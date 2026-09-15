import '../models/project.dart';

/// Contrato de las operaciones de exploración visibles para la capa UI.
abstract class IExploreRepository {
  Future<List<String>> getCategories();

  Future<List<Project>> getProjects({String? category});

  Future<Project> getProjectById(String id);

  Future<void> requestToJoin(String projectId);

  Future<void> cancelRequest(String projectId);
}
