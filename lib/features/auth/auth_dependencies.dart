import 'package:get/get.dart';
import 'data/datasources/i_auth_source.dart';
import 'data/datasources/roble_auth_source.dart';
import 'data/repositories/auth_repository.dart';
import 'domain/repositories/i_auth_repository.dart';
import 'ui/viewmodels/auth_controller.dart';

void registerAuth() {
  Get.lazyPut<IAuthSource>(() => RobleAuthSource(), fenix: true);
  Get.lazyPut<IAuthRepository>(
    () => AuthRepository(Get.find<IAuthSource>()),
    fenix: true,
  );
  Get.lazyPut<AuthController>(
    () => AuthController(Get.find<IAuthRepository>()),
    fenix: true,
  );
}
