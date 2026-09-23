import 'package:get/get.dart';
import '../../../../core/roble_error_handler.dart';
import '../../../auth/ui/viewmodels/auth_controller.dart';
import '../../../auth/ui/views/login_page.dart';
import '../../../home/domain/models/collaborator_profile.dart';
import '../../../home/ui/viewmodels/home_controller.dart';
import '../../domain/repositories/i_profile_repository.dart';

class ProfileController extends GetxController {
  final IProfileRepository repository;

  ProfileController(this.repository);

  final Rxn<CollaboratorProfile> _profile = Rxn<CollaboratorProfile>();
  final RxMap<String, int> stats = <String, int>{'created': 0, 'member': 0, 'applied': 0}.obs;
  final RxBool isLoading = false.obs;

  CollaboratorProfile? get profile => _profile.value;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    isLoading.value = true;
    try {
      final p = await repository.getProfile();
      _profile.value = p;
      final st = await repository.getStats();
      stats.assignAll(st);
    } catch (e) {
      RobleErrorHandler.showErrorSnackbar(
        title: 'Error al cargar perfil',
        error: e,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateProfile({
    required String name,
    required String career,
    required String avatarUrl,
  }) async {
    isLoading.value = true;
    try {
      await repository.updateProfile(
        name: name,
        career: career,
        avatarUrl: avatarUrl,
      );
      if (_profile.value != null) {
        _profile.value!.name = name;
        _profile.value!.career = career;
        _profile.value!.avatarUrl = avatarUrl;
        _profile.refresh();
      }
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().loadHome();
      }
      RobleErrorHandler.showSuccessSnackbar(
        title: 'Perfil actualizado',
        message: 'Tus cambios se guardaron con éxito',
      );
      return true;
    } catch (e) {
      RobleErrorHandler.showErrorSnackbar(
        title: 'Error al actualizar perfil',
        error: e,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addSkill(String skill) async {
    final s = skill.trim();
    if (s.isEmpty) return;
    try {
      await repository.addSkill(s);
      if (_profile.value != null && !_profile.value!.skills.contains(s)) {
        _profile.value!.skills.add(s);
        _profile.refresh();
      }
    } catch (_) {}
  }

  Future<void> removeSkill(String skill) async {
    try {
      await repository.removeSkill(skill);
      if (_profile.value != null) {
        _profile.value!.skills.remove(skill);
        _profile.refresh();
      }
    } catch (_) {}
  }

  Future<void> addInterest(String interest) async {
    final i = interest.trim();
    if (i.isEmpty) return;
    try {
      await repository.addInterest(i);
      if (_profile.value != null && !_profile.value!.interests.contains(i)) {
        _profile.value!.interests.add(i);
        _profile.refresh();
      }
    } catch (_) {}
  }

  Future<void> removeInterest(String interest) async {
    try {
      await repository.removeInterest(interest);
      if (_profile.value != null) {
        _profile.value!.interests.remove(interest);
        _profile.refresh();
      }
    } catch (_) {}
  }

  Future<void> logout() async {
    if (Get.isRegistered<AuthController>()) {
      await Get.find<AuthController>().logout();
    }
    Get.offAll(() => const LoginPage());
  }
}
