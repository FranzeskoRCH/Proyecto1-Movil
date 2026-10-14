import '../../domain/models/project.dart';
import '../../domain/repositories/i_explore_repository.dart';
import '../datasources/i_explore_source.dart';

/// Adaptador entre el contrato de dominio y el origen de datos.
class ExploreRepository implements IExploreRepository {
  late IExploreSource source;

  ExploreRepository(this.source);

  @override
  Future<List<String>> getCategories() async => await source.getCategories();

  @override
  Future<List<Project>> getProjects({
    String? category,
    String? search,
    int limit = 20,
    int offset = 0,
  }) async =>
      await source.getProjects(
        category: category,
        search: search,
        limit: limit,
        offset: offset,
      );

  @override
  Future<Project> getProjectById(String id) async =>
      await source.getProjectById(id);

  @override
  Future<void> requestToJoin(String projectId, {String? role}) async =>
      await source.requestToJoin(projectId, role: role);

  @override
  Future<void> cancelRequest(String projectId) async =>
      await source.cancelRequest(projectId);
}
