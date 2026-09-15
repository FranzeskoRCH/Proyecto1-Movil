import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

import '../../domain/models/project.dart';
import '../../domain/repositories/i_explore_repository.dart';

/// Controlador del detalle de un proyecto y del envío/cancelación de la
/// solicitud para unirse al equipo.
class ProjectDetailController extends GetxController with UiLoggy {
  final IExploreRepository repository;

  final _project = Rxn<Project>();
  final _isLoading = false.obs;
  final _isSubmitting = false.obs;

  ProjectDetailController(this.repository);

  Project? get project => _project.value;
  bool get isLoading => _isLoading.value;
  bool get isSubmitting => _isSubmitting.value;

  /// Carga el detalle del proyecto indicado.
  Future<void> loadProject(String id) async {
    loggy.debug('ProjectDetailController: Fetching project $id');
    _isLoading.value = true;
    try {
      _project.value = await repository.getProjectById(id);
    } catch (exception) {
      loggy.error('ProjectDetailController: Error fetching project: $exception');
      _project.value = null;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Envía la solicitud para unirse al equipo. Devuelve `true` si fue exitosa.
  Future<bool> requestToJoin() async {
    final Project? current = _project.value;
    if (current == null || _isSubmitting.value) return false;

    _isSubmitting.value = true;
    try {
      await repository.requestToJoin(current.id);
      current.requestedToJoin = true;
      _project.refresh();
      return true;
    } catch (exception) {
      loggy.error('ProjectDetailController: Error sending request: $exception');
      return false;
    } finally {
      _isSubmitting.value = false;
    }
  }

  /// Cancela la solicitud enviada. Devuelve `true` si fue exitosa.
  Future<bool> cancelRequest() async {
    final Project? current = _project.value;
    if (current == null || _isSubmitting.value) return false;

    _isSubmitting.value = true;
    try {
      await repository.cancelRequest(current.id);
      current.requestedToJoin = false;
      _project.refresh();
      return true;
    } catch (exception) {
      loggy.error(
        'ProjectDetailController: Error cancelling request: $exception',
      );
      return false;
    } finally {
      _isSubmitting.value = false;
    }
  }
}
