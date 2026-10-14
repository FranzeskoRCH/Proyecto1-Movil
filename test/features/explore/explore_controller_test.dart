import 'package:flutter_test/flutter_test.dart';
import 'package:movil_proyecto/features/explore/domain/models/project.dart';
import 'package:movil_proyecto/features/explore/domain/repositories/i_explore_repository.dart';
import 'package:movil_proyecto/features/explore/ui/viewmodels/explore_controller.dart';

Project _project(String id, int match) => Project(
      id: id,
      title: 'Proyecto $id',
      description: '',
      vision: '',
      authorName: 'Autor',
      authorCareer: '',
      authorAvatarUrl: '',
      categories: const [],
      matchPercentage: match,
      vacancies: 1,
      roles: const [],
      members: const [],
    );

class _MockExploreRepository implements IExploreRepository {
  _MockExploreRepository(this.projects);

  final List<Project> projects;
  final List<Map<String, Object?>> calls = [];

  @override
  Future<List<String>> getCategories() async => ['Para Ti', 'Tech'];

  @override
  Future<List<Project>> getProjects({
    String? category,
    String? search,
    int limit = 20,
    int offset = 0,
  }) async {
    calls.add({
      'category': category,
      'search': search,
      'limit': limit,
      'offset': offset,
    });
    if (category == 'Para Ti') {
      // El controlador pide el conjunto completo desde el offset 0.
      return projects.take(limit).toList();
    }
    return projects.skip(offset).take(limit).toList();
  }

  @override
  Future<Project> getProjectById(String id) async =>
      projects.firstWhere((p) => p.id == id);

  @override
  Future<void> requestToJoin(String projectId, {String? role}) async {}

  @override
  Future<void> cancelRequest(String projectId) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('"Para Ti" ordena por afinidad descendente', () async {
    final repo = _MockExploreRepository([
      _project('a', 10),
      _project('b', 90),
      _project('c', 50),
    ]);
    final controller = ExploreController(repo);

    await controller.loadProjects();

    expect(controller.selectedCategory, 'Para Ti');
    expect(controller.projects.map((p) => p.id).toList(), ['b', 'c', 'a']);
    controller.onClose();
  });

  test('"Para Ti" pagina localmente el conjunto ordenado', () async {
    final repo = _MockExploreRepository(
      List.generate(25, (i) => _project('p$i', 100 - i)),
    );
    final controller = ExploreController(repo);

    await controller.loadProjects();
    expect(controller.projects.length, 20);
    expect(controller.hasMore, isTrue);
    expect(controller.projects.first.id, 'p0');

    await controller.loadMore();
    expect(controller.projects.length, 25);
    expect(controller.hasMore, isFalse);
    controller.onClose();
  });

  test('una categoría normal pagina contra el backend (offset)', () async {
    final repo = _MockExploreRepository(
      List.generate(25, (i) => _project('t$i', 0)),
    );
    final controller = ExploreController(repo);

    await controller.loadProjects();
    await controller.selectCategory('Tech');

    expect(controller.projects.length, 20);
    expect(controller.hasMore, isTrue);

    await controller.loadMore();

    expect(controller.projects.length, 25);
    expect(controller.hasMore, isFalse);
    // La segunda carga pidió offset 20 al backend.
    final techCalls = repo.calls.where((c) => c['category'] == 'Tech').toList();
    expect(techCalls.last['offset'], 20);
    controller.onClose();
  });
}
