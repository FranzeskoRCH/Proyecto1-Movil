import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

import '../../../../core/roble_error_handler.dart';
import '../../../explore/ui/viewmodels/explore_controller.dart';
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

  /// Retira una postulación enviada y la quita de la lista de aplicados.
  Future<bool> withdrawApplication(AppliedProject project) async {
    try {
      await repository.withdrawApplication(project.id);
      _appliedProjects.removeWhere((p) => p.id == project.id);
      RobleErrorHandler.showSuccessSnackbar(
        title: 'Postulación retirada',
        message: 'Ya no apareces como postulante en "${project.title}".',
      );
      return true;
    } catch (e) {
      RobleErrorHandler.showErrorSnackbar(
        title: 'No se pudo retirar',
        error: e,
      );
      return false;
    }
  }

  /// Actualiza un proyecto propio y refresca las listas dependientes.
  Future<bool> updateProject({
    required String projectId,
    required String title,
    required String description,
    required String vision,
    required int vacancies,
    required CreatedProjectStatus status,
    required List<String> categories,
    required List<String> roles,
    String? imageUrl,
  }) async {
    try {
      await repository.updateProject(
        projectId: projectId,
        title: title,
        description: description,
        vision: vision,
        vacancies: vacancies,
        status: status,
        categories: categories,
        roles: roles,
        imageUrl: imageUrl,
      );
      await loadProjects();
      _refreshExplore();
      RobleErrorHandler.showSuccessSnackbar(
        title: 'Proyecto actualizado',
        message: 'Los cambios en "$title" se guardaron correctamente.',
      );
      return true;
    } catch (e) {
      RobleErrorHandler.showErrorSnackbar(
        title: 'No se pudo actualizar',
        error: e,
      );
      return false;
    }
  }

  /// Pasa un proyecto de "Reclutando" a "Activo" para abrir su espacio de
  /// trabajo. Devuelve `true` si se guardó.
  Future<bool> startProject(CreatedProject project) async {
    try {
      await repository.updateProject(
        projectId: project.id,
        title: project.title,
        description: project.description,
        vision: project.vision,
        vacancies: project.vacancies,
        status: CreatedProjectStatus.active,
        categories: project.categories,
        roles: project.roles,
        imageUrl: project.imageUrl,
      );
      await loadProjects();
      _refreshExplore();
      RobleErrorHandler.showSuccessSnackbar(
        title: '¡Proyecto iniciado!',
        message: 'Ya puedes organizar tareas y fechas en el espacio de trabajo.',
      );
      return true;
    } catch (e) {
      RobleErrorHandler.showErrorSnackbar(
        title: 'No se pudo iniciar el proyecto',
        error: e,
      );
      return false;
    }
  }

  /// Elimina un proyecto propio y lo quita de la lista de creados.
  Future<bool> deleteProject(CreatedProject project) async {
    try {
      await repository.deleteProject(project.id);
      _createdProjects.removeWhere((p) => p.id == project.id);
      _refreshExplore();
      RobleErrorHandler.showSuccessSnackbar(
        title: 'Proyecto eliminado',
        message: '"${project.title}" se eliminó definitivamente.',
      );
      return true;
    } catch (e) {
      RobleErrorHandler.showErrorSnackbar(
        title: 'No se pudo eliminar',
        error: e,
      );
      return false;
    }
  }

  void _refreshExplore() {
    if (Get.isRegistered<ExploreController>()) {
      Get.find<ExploreController>().loadProjects();
    }
  }
}
