import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

import '../../domain/repositories/i_home_repository.dart';
import '../../domain/models/collaborator_profile.dart';

/// Controlador de la pantalla de inicio.
///
/// Administra el estado reactivo de la home y llama al [IHomeRepository]
/// directamente (sin use-cases), tal como indica el enfoque pragmático del
/// template.
class HomeController extends GetxController with UiLoggy {
  final IHomeRepository repository;
  final _profile = Rxn<CollaboratorProfile>();
  final _isLoading = false.obs;

  HomeController(this.repository);

  CollaboratorProfile? get profile => _profile.value;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    getProfile();
    super.onInit();
  }

  /// Carga el perfil del colaborador desde el repositorio.
  Future<void> getProfile() async {
    loggy.debug('HomeController: Fetching collaborator profile');
    _isLoading.value = true;
    try {
      _profile.value = await repository.getCollaboratorProfile();
    } catch (exception) {
      loggy.error('HomeController: Error fetching profile: $exception');
      _profile.value = null;
    } finally {
      _isLoading.value = false;
    }
  }
}
