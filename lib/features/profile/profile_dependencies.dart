import 'package:get/get.dart';
import 'data/datasources/i_profile_source.dart';
import 'data/datasources/roble_profile_source.dart';
import 'data/repositories/profile_repository.dart';
import 'domain/repositories/i_profile_repository.dart';
import 'ui/viewmodels/profile_controller.dart';

void registerProfile() {
  Get.lazyPut<IProfileSource>(() => RobleProfileSource(), fenix: true);
  Get.lazyPut<IProfileRepository>(
    () => ProfileRepository(Get.find<IProfileSource>()),
    fenix: true,
  );
  Get.lazyPut(
    () => ProfileController(Get.find<IProfileRepository>()),
    fenix: true,
  );
}
