import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

import '../../domain/models/created_project.dart';
import '../../domain/repositories/i_project_repository.dart';

/// Controlador de la gestión de equipos de un proyecto creado.
class TeamManagementController extends GetxController with UiLoggy {
  final IProjectRepository repository;

  final _project = Rxn<CreatedProject>();
  final _isLoading = false.obs;
  final _processingId = RxnString();

  TeamManagementController(this.repository);

  CreatedProject? get project => _project.value;
  bool get isLoading => _isLoading.value;

  /// Id del postulante cuya acción está en curso (para deshabilitar su fila).
  String? get processingId => _processingId.value;

  Future<void> loadProject(String id) async {
    loggy.debug('TeamManagementController: Fetching project $id');
    _isLoading.value = true;
    try {
      _project.value = await repository.getCreatedProjectById(id);
    } catch (exception) {
      loggy.error(
        'TeamManagementController: Error fetching project: $exception',
      );
      _project.value = null;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> accept(String applicantId) async {
    final project = _project.value;
    if (project == null) return;
    await _run(
      applicantId,
      () => repository.acceptApplicant(project.id, applicantId),
    );
  }

  Future<void> reject(String applicantId) async {
    final project = _project.value;
    if (project == null) return;
    await _run(
      applicantId,
      () => repository.rejectApplicant(project.id, applicantId),
    );
  }

  Future<void> remove(String applicantId) async {
    final project = _project.value;
    if (project == null) return;
    await _run(
      applicantId,
      () => repository.removeMember(project.id, applicantId),
    );
  }

  Future<void> _run(
    String applicantId,
    Future<void> Function() action,
  ) async {
    if (_processingId.value != null) return;
    _processingId.value = applicantId;
    try {
      await action();
      _project.refresh();
    } catch (exception) {
      loggy.error(
        'TeamManagementController: Error updating applicant: $exception',
      );
    } finally {
      _processingId.value = null;
    }
  }
}
