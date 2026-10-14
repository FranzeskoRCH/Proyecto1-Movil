import 'package:get/get.dart';

import '../../../home/domain/models/collaborator_profile.dart';
import '../../domain/repositories/i_profile_repository.dart';

/// Controlador del perfil público de otro colaborador (autor, postulante…).
class CollaboratorProfileController extends GetxController {
  final IProfileRepository repository;

  CollaboratorProfileController(this.repository);

  final Rxn<CollaboratorProfile> _profile = Rxn<CollaboratorProfile>();
  final RxMap<String, int> _stats = <String, int>{}.obs;
  final RxBool _isLoading = false.obs;
  final RxnString _error = RxnString();

  CollaboratorProfile? get profile => _profile.value;
  Map<String, int> get stats => _stats;
  bool get isLoading => _isLoading.value;
  String? get error => _error.value;

  Future<void> load(String userId) async {
    if (userId.isEmpty) {
      _error.value = 'Perfil no disponible';
      return;
    }
    _isLoading.value = true;
    _error.value = null;
    // Limpiar el perfil anterior: el controlador es un singleton y la vista
    // cae a los datos de respaldo (fallbackName) mientras carga.
    _profile.value = null;
    _stats.clear();
    try {
      _profile.value = await repository.getCollaborator(userId);
      _stats.assignAll(await repository.getStatsFor(userId));
    } catch (_) {
      _error.value = 'No se pudo cargar el perfil.';
    } finally {
      _isLoading.value = false;
    }
  }
}
