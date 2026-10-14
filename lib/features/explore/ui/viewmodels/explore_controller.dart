import 'dart:async';

import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

import '../../domain/models/project.dart';
import '../../domain/repositories/i_explore_repository.dart';

/// Controlador de la lista de exploración.
///
/// Administra categorías, filtro activo, búsqueda y **paginación**. La búsqueda
/// y el paginado se resuelven en el backend mediante consultas guardadas de
/// Roble (ver `RobleExploreSource`); aquí solo se mantiene el estado.
///
/// La pestaña **"Para Ti"** se personaliza en el cliente: se trae un conjunto
/// amplio de proyectos, se ordena por afinidad con [MatchCalculator] y se pagina
/// localmente.
class ExploreController extends GetxController with UiLoggy {
  final IExploreRepository repository;

  ExploreController(this.repository);

  static const String _forYouCategory = 'Para Ti';
  static const int _pageSize = 20;
  static const int _forYouPoolSize = 50;

  final _categories = <String>[].obs;
  final _selectedCategory = RxnString();
  final _projects = <Project>[].obs;
  final _searchQuery = ''.obs;
  final _isLoading = false.obs;
  final _isLoadingMore = false.obs;
  final _hasMore = true.obs;
  final _error = RxnString();

  int _offset = 0;
  Timer? _debounce;

  /// Conjunto completo (ya ordenado por afinidad) para "Para Ti"; se pagina en
  /// memoria. Vacío para las demás categorías.
  List<Project> _forYouPool = [];

  List<String> get categories => _categories;
  String? get selectedCategory => _selectedCategory.value;
  bool get isLoading => _isLoading.value;
  bool get isLoadingMore => _isLoadingMore.value;
  bool get hasMore => _hasMore.value;
  String? get error => _error.value;
  String get searchQuery => _searchQuery.value;

  /// Lista acumulada de proyectos.
  List<Project> get projects => _projects;

  /// "Para Ti" solo cuando no hay texto de búsqueda (con búsqueda se resuelve
  /// en el backend, como cualquier otra categoría).
  bool get _isForYou =>
      _selectedCategory.value == _forYouCategory &&
      _searchQuery.value.trim().isEmpty;

  /// Actualiza el texto de búsqueda y recarga contra el backend (con retardo
  /// para no disparar una consulta por cada tecla).
  void setSearchQuery(String query) {
    _searchQuery.value = query;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), loadProjects);
  }

  @override
  void onInit() {
    loadProjects();
    super.onInit();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }

  /// Reinicia la lista y carga la primera página.
  Future<void> loadProjects() async {
    final stopwatch = Stopwatch()..start();
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

      _offset = 0;
      _hasMore.value = true;

      if (_isForYou) {
        await _loadForYou();
      } else {
        _forYouPool = [];
        final page = await _fetchPage();
        _projects.assignAll(page);
        _offset = page.length;
        _hasMore.value = page.length >= _pageSize;
        _sortByMatch();
      }
    } catch (exception) {
      loggy.error('ExploreController: Error fetching projects: $exception');
      _error.value = 'No se pudieron cargar los proyectos.';
      _projects.clear();
      _hasMore.value = false;
    } finally {
      _isLoading.value = false;
      loggy.debug(
          'ExploreController: carga terminada en ${stopwatch.elapsedMilliseconds} ms '
          '(${_projects.length} proyectos)');
    }
  }

  /// Trae el conjunto de "Para Ti", lo ordena por afinidad y muestra la primera
  /// página desde memoria.
  Future<void> _loadForYou() async {
    final pool = await repository.getProjects(
      category: _forYouCategory,
      limit: _forYouPoolSize,
      offset: 0,
    );
    _forYouPool = pool.toList()
      ..sort((a, b) => b.matchPercentage.compareTo(a.matchPercentage));
    _projects.assignAll(_forYouPool.take(_pageSize));
    _hasMore.value = _forYouPool.length > _projects.length;
  }

  /// Carga la siguiente página (del backend o del conjunto "Para Ti").
  Future<void> loadMore() async {
    if (_isLoading.value || _isLoadingMore.value || !_hasMore.value) return;
    _isLoadingMore.value = true;
    try {
      if (_isForYou) {
        final next =
            _forYouPool.skip(_projects.length).take(_pageSize).toList();
        _projects.addAll(next);
        _hasMore.value = _projects.length < _forYouPool.length;
      } else {
        final page = await _fetchPage();
        final existing = _projects.map((p) => p.id).toSet();
        _projects.addAll(page.where((p) => !existing.contains(p.id)));
        _offset += page.length;
        _hasMore.value = page.length >= _pageSize;
        _sortByMatch();
      }
    } catch (exception) {
      loggy.error('ExploreController: Error cargando más: $exception');
      _hasMore.value = false;
    } finally {
      _isLoadingMore.value = false;
    }
  }

  Future<List<Project>> _fetchPage() => repository.getProjects(
        category: _selectedCategory.value,
        search: _searchQuery.value,
        limit: _pageSize,
        offset: _offset,
      );

  void _sortByMatch() {
    final sorted = _projects.toList()
      ..sort((a, b) => b.matchPercentage.compareTo(a.matchPercentage));
    _projects.assignAll(sorted);
  }

  /// Aplica un filtro de categoría y refresca el listado.
  Future<void> selectCategory(String category) async {
    if (_selectedCategory.value == category) return;
    _selectedCategory.value = category;
    await loadProjects();
  }
}
