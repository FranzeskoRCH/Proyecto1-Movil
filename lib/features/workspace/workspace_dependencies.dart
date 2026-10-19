import 'package:get/get.dart';

import 'data/datasources/i_workspace_source.dart';
import 'data/datasources/roble_workspace_source.dart';
import 'data/repositories/workspace_repository.dart';
import 'domain/repositories/i_workspace_repository.dart';
import 'ui/viewmodels/workspace_controller.dart';

/// Registra la cadena de dependencias del espacio de trabajo en GetX.
void registerWorkspace() {
  Get.lazyPut<IWorkspaceSource>(() => RobleWorkspaceSource(), fenix: true);
  Get.lazyPut<IWorkspaceRepository>(
    () => WorkspaceRepository(Get.find<IWorkspaceSource>()),
    fenix: true,
  );
  Get.lazyPut(
    () => WorkspaceController(Get.find<IWorkspaceRepository>()),
    fenix: true,
  );
}
