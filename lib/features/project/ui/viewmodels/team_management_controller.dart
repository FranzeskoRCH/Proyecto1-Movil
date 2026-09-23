import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

import '../../domain/models/application_status.dart';
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
      newStatus: ApplicationStatus.accepted,
    );
  }

  Future<void> reject(String applicantId) async {
    final project = _project.value;
    if (project == null) return;
    await _run(
      applicantId,
      () => repository.rejectApplicant(project.id, applicantId),
      newStatus: ApplicationStatus.rejected,
    );
  }

  Future<void> remove(String applicantId) async {
    final project = _project.value;
    if (project == null) return;
    await _run(
      applicantId,
      () => repository.removeMember(project.id, applicantId),
      isRemove: true,
    );
  }

  Future<void> _run(
    String applicantId,
    Future<void> Function() action, {
    ApplicationStatus? newStatus,
    bool isRemove = false,
  }) async {
    if (_processingId.value != null) return;
    _processingId.value = applicantId;
    try {
      await action();
      final current = _project.value;
      if (current != null) {
        if (isRemove) {
          current.applicants.removeWhere(
            (a) => a.id == applicantId || a.collaboratorId == applicantId,
          );
        } else if (newStatus != null) {
          for (final a in current.applicants) {
            if (a.id == applicantId || a.collaboratorId == applicantId) {
              a.status = newStatus;
            }
          }
        }
        _project.refresh();

        // Sincronizar con el backend
        try {
          final refreshed = await repository.getCreatedProjectById(current.id);
          _project.value = refreshed;
        } catch (_) {}
      }
    } catch (exception) {
      loggy.error(
        'TeamManagementController: Error updating applicant: $exception',
      );
    } finally {
      _processingId.value = null;
    }
  }
}

