import 'package:get/get.dart';

import 'data/datasources/i_project_source.dart';
import 'data/datasources/local/local_project_source.dart';
import 'data/repositories/project_repository.dart';
import 'domain/repositories/i_project_repository.dart';
import 'ui/viewmodels/my_projects_controller.dart';
import 'ui/viewmodels/team_management_controller.dart';

/// Registra la cadena de dependencias de la feature "Mis Proyectos" en GetX.
///
/// Para conectar el backend, reemplaza [LocalProjectSource] por un
/// [IProjectSource] remoto aquí; los consumidores no necesitan cambios.
void registerProject() {
  Get.put<IProjectSource>(LocalProjectSource());
  Get.put<IProjectRepository>(ProjectRepository(Get.find()));
  Get.lazyPut(() => MyProjectsController(Get.find()), fenix: true);
  Get.lazyPut(() => TeamManagementController(Get.find()), fenix: true);
}
