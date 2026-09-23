import 'package:get/get.dart';
import 'package:loggy/loggy.dart';
import '../../../../core/roble_error_handler.dart';
import '../../domain/models/user_session.dart';
import '../../domain/repositories/i_auth_repository.dart';

class AuthController extends GetxController with UiLoggy {
  final IAuthRepository repository;

  AuthController(this.repository);

  final Rxn<UserSession> _user = Rxn<UserSession>();
  final RxBool _isLoading = false.obs;
  final RxnString _error = RxnString();

  UserSession? get user => _user.value;
  bool get isLoggedIn => _user.value != null;
  bool get isLoading => _isLoading.value;
  String? get error => _error.value;

  @override
  void onInit() {
    super.onInit();
    _user.value = repository.currentUser;
    loggy.info('[AUTH_CONTROLLER] Inicializado. Usuario actual: ${_user.value?.email ?? "Ninguno"}');
  }

  void clearError() {
    _error.value = null;
  }

  Future<bool> tryRestoreSession() async {
    _isLoading.value = true;
    loggy.info('[AUTH_CONTROLLER] Comprobando sesion previa...');
    try {
      final success = await repository.restoreSession();
      if (success) {
        _user.value = repository.currentUser;
        loggy.info('[AUTH_CONTROLLER] Sesion recuperada exitosamente para ${_user.value?.email}');
      } else {
        loggy.info('[AUTH_CONTROLLER] No se encontro sesion previa.');
      }
      return success;
    } catch (e) {
      loggy.error('[AUTH_CONTROLLER] Error al restaurar sesion: $e');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> login(String email, String password) async {
    final cleanEmail = email.trim();
    loggy.info('[AUTH_CONTROLLER] Iniciando login para: $cleanEmail');
    _isLoading.value = true;
    _error.value = null;
    try {
      final session = await repository.login(
        email: cleanEmail,
        password: password,
      );
      _user.value = session;
      loggy.info('[AUTH_CONTROLLER] Login exitoso. Usuario: ${session.email} (ID: ${session.userId})');

      RobleErrorHandler.showSuccessSnackbar(
        title: 'Bienvenido',
        message: 'Sesion iniciada correctamente',
      );
      return true;
    } catch (e) {
      final msg = RobleErrorHandler.getErrorMessage(e);
      _error.value = msg;
      loggy.error('[AUTH_CONTROLLER] Error en login para $cleanEmail: $msg');

      RobleErrorHandler.showErrorSnackbar(
        title: 'Error al iniciar sesion',
        error: e,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String name,
  }) async {
    final cleanEmail = email.trim();
    final cleanName = name.trim();
    loggy.info('[AUTH_CONTROLLER] Iniciando registro de cuenta: $cleanEmail (Nombre: $cleanName)');
    _isLoading.value = true;
    _error.value = null;
    try {
      final session = await repository.register(
        email: cleanEmail,
        password: password,
        name: cleanName,
      );
      _user.value = session;
      loggy.info('[AUTH_CONTROLLER] Registro y auto-login exitosos. ID: ${session.userId}');

      RobleErrorHandler.showSuccessSnackbar(
        title: 'Cuenta creada',
        message: 'Bienvenido a Nexus, $cleanName',
      );
      return true;
    } catch (e) {
      final msg = RobleErrorHandler.getErrorMessage(e);
      _error.value = msg;
      loggy.error('[AUTH_CONTROLLER] Error en registro para $cleanEmail: $msg');

      RobleErrorHandler.showErrorSnackbar(
        title: 'Error al registrarse',
        error: e,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> logout() async {
    loggy.info('[AUTH_CONTROLLER] Iniciando cierre de sesion...');
    _isLoading.value = true;
    try {
      await repository.logout();
      _user.value = null;
      loggy.info('[AUTH_CONTROLLER] Sesion cerrada correctamente.');
    } catch (e) {
      loggy.error('[AUTH_CONTROLLER] Error en logout: $e');
      RobleErrorHandler.showErrorSnackbar(
        title: 'Error al cerrar sesion',
        error: e,
      );
    } finally {
      _isLoading.value = false;
    }
  }
}
