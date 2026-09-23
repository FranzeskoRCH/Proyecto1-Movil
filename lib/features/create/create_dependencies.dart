import 'package:get/get.dart';
import 'data/datasources/i_create_source.dart';
import 'data/datasources/roble_create_source.dart';
import 'data/repositories/create_repository.dart';
import 'domain/repositories/i_create_repository.dart';
import 'ui/viewmodels/create_project_controller.dart';

void registerCreate() {
  Get.lazyPut<ICreateSource>(() => RobleCreateSource(), fenix: true);
  Get.lazyPut<ICreateRepository>(
    () => CreateRepository(Get.find<ICreateSource>()),
    fenix: true,
  );
  Get.lazyPut(
    () => CreateProjectController(Get.find<ICreateRepository>()),
    fenix: true,
  );
}
