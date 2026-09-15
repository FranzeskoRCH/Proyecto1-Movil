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
  Future<List<Project>> getProjects({String? category}) async =>
      await source.getProjects(category: category);

  @override
  Future<Project> getProjectById(String id) async =>
      await source.getProjectById(id);

  @override
  Future<void> requestToJoin(String projectId) async =>
      await source.requestToJoin(projectId);

  @override
  Future<void> cancelRequest(String projectId) async =>
      await source.cancelRequest(projectId);
}
