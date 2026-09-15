import '../../domain/models/project.dart';

/// Contrato del origen de datos de la pantalla de exploración.
abstract class IExploreSource {
  Future<List<String>> getCategories();

  Future<List<Project>> getProjects({String? category});

  Future<Project> getProjectById(String id);

  Future<void> requestToJoin(String projectId);

  Future<void> cancelRequest(String projectId);
}
