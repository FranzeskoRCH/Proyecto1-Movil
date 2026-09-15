import 'package:get/get.dart';

import 'data/datasources/i_explore_source.dart';
import 'data/datasources/local/local_explore_source.dart';
import 'data/repositories/explore_repository.dart';
import 'domain/repositories/i_explore_repository.dart';
import 'ui/viewmodels/explore_controller.dart';
import 'ui/viewmodels/project_detail_controller.dart';

/// Registra la cadena de dependencias de la feature de exploración en GetX.
///
/// Para conectar el backend, reemplaza [LocalExploreSource] por un
/// [IExploreSource] remoto aquí; los consumidores no necesitan cambios.
void registerExplore() {
  Get.put<IExploreSource>(LocalExploreSource());
  Get.put<IExploreRepository>(ExploreRepository(Get.find()));
  Get.lazyPut(() => ExploreController(Get.find()), fenix: true);
  Get.lazyPut(() => ProjectDetailController(Get.find()), fenix: true);
}
