import '../../domain/models/project.dart';

/// Contrato del origen de datos de la pantalla de exploración.
abstract class IExploreSource {
  Future<List<String>> getCategories();

  Future<List<Project>> getProjects({
    String? category,
    String? search,
    int limit = 20,
    int offset = 0,
  });

  Future<Project> getProjectById(String id);

  Future<void> requestToJoin(String projectId, {String? role});

  Future<void> cancelRequest(String projectId);
}
