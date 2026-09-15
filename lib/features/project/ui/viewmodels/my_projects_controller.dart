import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

import '../../domain/models/applied_project.dart';
import '../../domain/models/created_project.dart';
import '../../domain/repositories/i_project_repository.dart';

/// Pestañas de la pantalla "Mis Proyectos".
enum MyProjectsTab { created, applied }

/// Controlador de "Mis Proyectos": proyectos creados y aplicados.
class MyProjectsController extends GetxController with UiLoggy {
  final IProjectRepository repository;

  final _tab = MyProjectsTab.applied.obs;
  final _createdProjects = <CreatedProject>[].obs;
  final _appliedProjects = <AppliedProject>[].obs;
  final _isLoading = false.obs;
  final _error = RxnString();

  MyProjectsController(this.repository);

  MyProjectsTab get tab => _tab.value;
  List<CreatedProject> get createdProjects => _createdProjects;
  List<AppliedProject> get appliedProjects => _appliedProjects;
  bool get isLoading => _isLoading.value;
  String? get error => _error.value;

  @override
  void onInit() {
    loadProjects();
    super.onInit();
  }

  /// Carga ambas listas (creados y aplicados).
  Future<void> loadProjects() async {
    loggy.debug('MyProjectsController: Fetching projects');
    _isLoading.value = true;
    _error.value = null;
    try {
      _createdProjects.assignAll(await repository.getCreatedProjects());
      _appliedProjects.assignAll(await repository.getAppliedProjects());
    } catch (exception) {
      loggy.error('MyProjectsController: Error fetching projects: $exception');
      _error.value = 'No se pudieron cargar tus proyectos.';
    } finally {
      _isLoading.value = false;
    }
  }

  void selectTab(MyProjectsTab tab) => _tab.value = tab;
}
