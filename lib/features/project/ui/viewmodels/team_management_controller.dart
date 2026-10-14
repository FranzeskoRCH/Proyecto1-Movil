import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

import '../../../../core/roble_error_handler.dart';
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
    // Limpiar el proyecto anterior: el controlador es un singleton y la vista
    // muestra el spinner solo mientras `project == null`.
    _project.value = null;
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
      successMessage: 'Colaborador aceptado en el equipo.',
    );
  }

  Future<void> reject(String applicantId) async {
    final project = _project.value;
    if (project == null) return;
    await _run(
      applicantId,
      () => repository.rejectApplicant(project.id, applicantId),
      newStatus: ApplicationStatus.rejected,
      successMessage: 'Postulación rechazada.',
    );
  }

  Future<void> remove(String applicantId) async {
    final project = _project.value;
    if (project == null) return;
    await _run(
      applicantId,
      () => repository.removeMember(project.id, applicantId),
      isRemove: true,
      successMessage: 'Integrante retirado del equipo.',
    );
  }

  Future<void> _run(
    String applicantId,
    Future<void> Function() action, {
    ApplicationStatus? newStatus,
    bool isRemove = false,
    String? successMessage,
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

      if (successMessage != null) {
        RobleErrorHandler.showSuccessSnackbar(
          title: 'Listo',
          message: successMessage,
        );
      }
    } catch (exception) {
      loggy.error(
        'TeamManagementController: Error updating applicant: $exception',
      );
      RobleErrorHandler.showErrorSnackbar(
        title: 'No se pudo completar la acción',
        error: exception,
      );
    } finally {
      _processingId.value = null;
    }
  }
}
