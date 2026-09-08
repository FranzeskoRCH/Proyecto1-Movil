import 'package:get/get.dart';

import 'data/datasources/i_home_source.dart';
import 'data/datasources/local/local_home_source.dart';
import 'data/repositories/home_repository.dart';
import 'domain/repositories/i_home_repository.dart';
import 'ui/viewmodels/home_controller.dart';

/// Registra la cadena de dependencias de la feature de inicio en GetX.
///
/// Para conectar el backend, reemplaza [LocalHomeSource] por un
/// [IHomeSource] remoto aquí; los consumidores no necesitan cambios.
void registerHome() {
  Get.put<IHomeSource>(LocalHomeSource());
  Get.put<IHomeRepository>(HomeRepository(Get.find()));
  Get.lazyPut(() => HomeController(Get.find()));
}
