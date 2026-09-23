import 'package:get/get.dart';

import 'data/datasources/i_home_source.dart';
import 'data/datasources/roble_home_source.dart';
import 'data/repositories/home_repository.dart';
import 'domain/repositories/i_home_repository.dart';
import 'ui/viewmodels/home_controller.dart';

/// Registra la cadena de dependencias de la feature de inicio en GetX.
void registerHome() {
  Get.lazyPut<IHomeSource>(() => RobleHomeSource(), fenix: true);
  Get.lazyPut<IHomeRepository>(
    () => HomeRepository(Get.find<IHomeSource>()),
    fenix: true,
  );
  Get.lazyPut(
    () => HomeController(Get.find<IHomeRepository>()),
    fenix: true,
  );
}
