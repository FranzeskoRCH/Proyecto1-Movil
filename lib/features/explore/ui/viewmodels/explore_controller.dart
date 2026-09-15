import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

import '../../domain/models/project.dart';
import '../../domain/repositories/i_explore_repository.dart';

/// Controlador de la lista de exploración.
///
/// Administra categorías, filtro activo y el listado de proyectos, llamando al
/// [IExploreRepository] directamente (sin use-cases), igual que [HomeController].
class ExploreController extends GetxController with UiLoggy {
  final IExploreRepository repository;

  final _categories = <String>[].obs;
  final _selectedCategory = RxnString();
  final _projects = <Project>[].obs;
  final _isLoading = false.obs;
  final _error = RxnString();

  ExploreController(this.repository);

  List<String> get categories => _categories;
  String? get selectedCategory => _selectedCategory.value;
  List<Project> get projects => _projects;
  bool get isLoading => _isLoading.value;
  String? get error => _error.value;

  @override
  void onInit() {
    loadProjects();
    super.onInit();
  }

  /// Carga las categorías (la primera vez) y los proyectos del filtro activo.
  Future<void> loadProjects() async {
    loggy.debug('ExploreController: Fetching projects');
    _isLoading.value = true;
    _error.value = null;
    try {
      if (_categories.isEmpty) {
        final categories = await repository.getCategories();
        _categories.assignAll(categories);
        _selectedCategory.value =
            categories.isNotEmpty ? categories.first : null;
      }
      _projects.assignAll(
        await repository.getProjects(category: _selectedCategory.value),
      );
    } catch (exception) {
      loggy.error('ExploreController: Error fetching projects: $exception');
      _error.value = 'No se pudieron cargar los proyectos.';
      _projects.clear();
    } finally {
      _isLoading.value = false;
    }
  }

  /// Aplica un filtro de categoría y refresca el listado.
  Future<void> selectCategory(String category) async {
    if (_selectedCategory.value == category) return;
    _selectedCategory.value = category;
    await loadProjects();
  }
}
