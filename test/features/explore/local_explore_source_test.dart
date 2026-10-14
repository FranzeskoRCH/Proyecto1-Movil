import 'package:flutter_test/flutter_test.dart';
import 'package:movil_proyecto/features/explore/data/datasources/local/local_explore_source.dart';

void main() {
  late LocalExploreSource source;

  setUp(() => source = LocalExploreSource());

  test('getCategories incluye la categoría por defecto', () async {
    final categories = await source.getCategories();

    expect(categories.first, 'Para Ti');
  });

  test('getProjects sin filtro devuelve todos los proyectos', () async {
    final projects = await source.getProjects();

    expect(projects.length, greaterThanOrEqualTo(2));
  });

  test('getProjects filtra por categoría', () async {
    final projects = await source.getProjects(category: 'Salud');

    expect(projects, isNotEmpty);
    expect(
      projects.every((project) => project.categories.contains('Salud')),
      isTrue,
    );
  });

  test('getProjectById devuelve el proyecto solicitado', () async {
    final projects = await source.getProjects();
    final expected = projects.first;

    final project = await source.getProjectById(expected.id);

    expect(project.id, expected.id);
    expect(project.title, expected.title);
  });

  test('getProjects pagina con limit y offset', () async {
    final all = await source.getProjects();
    final first = await source.getProjects(limit: 1, offset: 0);
    final second = await source.getProjects(limit: 1, offset: 1);

    expect(first.length, 1);
    expect(first.first.id, all.first.id);
    if (all.length > 1) {
      expect(second.first.id, all[1].id);
    }
  });

  test('getProjects filtra por término de búsqueda', () async {
    final projects = await source.getProjects(search: 'EcoCampus');

    expect(projects, isNotEmpty);
    expect(
      projects.every((p) => p.title.toLowerCase().contains('ecocampus')),
      isTrue,
    );
  });

  test('requestToJoin y cancelRequest actualizan el estado', () async {
    final id = (await source.getProjects()).first.id;

    await source.requestToJoin(id);
    expect((await source.getProjectById(id)).requestedToJoin, isTrue);

    await source.cancelRequest(id);
    expect((await source.getProjectById(id)).requestedToJoin, isFalse);
  });
}
