import 'package:get/get.dart';

import 'data/datasources/i_project_source.dart';
import 'data/datasources/roble_project_source.dart';
import 'data/repositories/project_repository.dart';
import 'domain/repositories/i_project_repository.dart';
import 'ui/viewmodels/my_projects_controller.dart';
import 'ui/viewmodels/team_management_controller.dart';

/// Registra la cadena de dependencias de la feature "Mis Proyectos" en GetX.
void registerProject() {
  Get.lazyPut<IProjectSource>(() => RobleProjectSource(), fenix: true);
  Get.lazyPut<IProjectRepository>(
    () => ProjectRepository(Get.find<IProjectSource>()),
    fenix: true,
  );
  Get.lazyPut(() => MyProjectsController(Get.find<IProjectRepository>()), fenix: true);
  Get.lazyPut(() => TeamManagementController(Get.find<IProjectRepository>()), fenix: true);
}
