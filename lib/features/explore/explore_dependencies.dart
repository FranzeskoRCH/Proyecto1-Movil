import 'package:get/get.dart';

import 'data/datasources/i_explore_source.dart';
import 'data/datasources/roble_explore_source.dart';
import 'data/repositories/explore_repository.dart';
import 'domain/repositories/i_explore_repository.dart';
import 'ui/viewmodels/explore_controller.dart';
import 'ui/viewmodels/project_detail_controller.dart';

/// Registra la cadena de dependencias de la feature de exploración en GetX.
void registerExplore() {
  Get.lazyPut<IExploreSource>(() => RobleExploreSource(), fenix: true);
  Get.lazyPut<IExploreRepository>(
    () => ExploreRepository(Get.find<IExploreSource>()),
    fenix: true,
  );
  Get.lazyPut(() => ExploreController(Get.find<IExploreRepository>()), fenix: true);
  Get.lazyPut(() => ProjectDetailController(Get.find<IExploreRepository>()), fenix: true);
}
