import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

import '../../../../core/roble_error_handler.dart';
import '../../domain/models/collaborator_profile.dart';
import '../../domain/models/enrolled_project.dart';
import '../../domain/repositories/i_home_repository.dart';

/// Controlador de la pantalla de inicio.
///
/// Administra el estado reactivo de la home y llama al [IHomeRepository]
/// directamente (sin use-cases), tal como indica el enfoque pragmático del
/// template.
class HomeController extends GetxController with UiLoggy {
  final IHomeRepository repository;
  final _profile = Rxn<CollaboratorProfile>();
  final _enrolledProjects = <EnrolledProject>[].obs;
  final _isLoading = false.obs;

  HomeController(this.repository);

  CollaboratorProfile? get profile => _profile.value;
  List<EnrolledProject> get enrolledProjects => _enrolledProjects;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    loadHome();
    super.onInit();
  }

  /// Carga el perfil y los proyectos en los que participa el colaborador.
  Future<void> loadHome() async {
    loggy.debug('HomeController: Fetching home data');
    _isLoading.value = true;
    try {
      _profile.value = await repository.getCollaboratorProfile();
      _enrolledProjects.assignAll(await repository.getEnrolledProjects());
    } catch (exception) {
      loggy.error('HomeController: Error fetching home data: $exception');
      _profile.value = null;
      // HIGIENE: evitar mostrar los proyectos del intento anterior.
      _enrolledProjects.clear();
    } finally {
      _isLoading.value = false;
    }
  }

  /// Abandona un proyecto en el que el colaborador es miembro.
  Future<bool> leaveProject(EnrolledProject project) async {
    try {
      await repository.leaveProject(project.id);
      _enrolledProjects.removeWhere((p) => p.id == project.id);
      RobleErrorHandler.showSuccessSnackbar(
        title: 'Saliste del equipo',
        message: 'Ya no participas en "${project.title}".',
      );
      return true;
    } catch (e) {
      RobleErrorHandler.showErrorSnackbar(
        title: 'No se pudo salir del equipo',
        error: e,
      );
      return false;
    }
  }
}
