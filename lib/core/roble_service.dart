import 'package:loggy/loggy.dart';
import 'package:roble/roble.dart';

class RobleService with NetworkLoggy {
  static final RobleService _instance = RobleService._internal();
  factory RobleService() => _instance;
  RobleService._internal();

  late final RobleApiDataBase db;
  bool _initialized = false;
  Map<String, dynamic>? _cachedUser;

  bool get isInitialized => _initialized;
  bool get isLoggedIn => _initialized && db.isLoggedIn;
  Map<String, dynamic>? get cachedUser => _cachedUser;

  String get currentUserId =>
      _cachedUser?['userId'] ??
      _cachedUser?['user_id'] ??
      _cachedUser?['_id'] ??
      _cachedUser?['id'] ??
      '';

  void init({required String baseUrl, required String contractId}) {
    loggy.info(
        '[ROBLE_SERVICE] Inicializando cliente Roble API. BaseUrl: $baseUrl | ContractId: $contractId');
    db = RobleApiDataBase(
      config: RobleApiConfig.fromContract(
        baseUrl: baseUrl,
        contractId: contractId,
      ),
    );
    _initialized = true;
    loggy.info('[ROBLE_SERVICE] Inicializacion completada con exito.');
  }

  /// Restaura la sesión persistida internamente por flutter_secure_storage
  Future<bool> restoreSession() async {
    loggy.info('[ROBLE_SERVICE] Intentando restaurar sesion persistente...');
    try {
      final hasSession = await db.restoreSession(verify: true);
      if (hasSession) {
        _cachedUser = await db.currentUser();
        loggy.info(
            '[ROBLE_SERVICE] Sesion restaurada con exito. Usuario: ${_cachedUser?['email']} (ID: $currentUserId)');
      } else {
        loggy.info('[ROBLE_SERVICE] No se encontro sesion previa activa.');
      }
      return hasSession;
    } catch (e) {
      loggy.error('[ROBLE_SERVICE] Error al restaurar sesion: $e');
      return false;
    }
  }

  /// Cierra la sesión activa en Roble
  Future<void> clearSession() async {
    loggy.info(
        '[ROBLE_SERVICE] Cerrando sesion en backend y limpiando almacenamiento local...');
    try {
      await db.logout();
      loggy.info('[ROBLE_SERVICE] Sesion cerrada en backend correctamente.');
    } catch (e) {
      loggy.warning(
          '[ROBLE_SERVICE] Advertencia al cerrar sesion en backend: $e');
    }
    _cachedUser = null;
    loggy.info('[ROBLE_SERVICE] Cache de usuario limpiado.');
  }

  /// Guarda los datos del usuario en memoria para acceso rápido
  void setCachedUser(Map<String, dynamic> user) {
    _cachedUser = user;
    loggy.info(
        '[ROBLE_SERVICE] Cache actualizado: ${user['email']} (ID: $currentUserId)');
  }

  /// Actualiza los datos cacheados del usuario
  void updateCachedUser(Map<String, dynamic> data) {
    _cachedUser = {...?_cachedUser, ...data};
    loggy.info(
        '[ROBLE_SERVICE] Cache parcialmente actualizado con nuevas propiedades: ${data.keys.toList()}');
  }

  /// Busca el perfil de un colaborador por su id de usuario.
  ///
  /// En Roble el UUID del usuario vive en la columna `id` de `collaborator`
  /// (el `_id` es el identificador interno de Roble y es distinto). Por eso se
  /// intenta primero `id` y luego `_id`, para tolerar datos antiguos.
  Future<Map<String, dynamic>?> findCollaborator(String userId) async {
    if (userId.isEmpty) return null;
    for (final field in const ['id', '_id']) {
      try {
        final rows = await db.read('collaborator', filters: {field: userId});
        if (rows.isNotEmpty) return rows.first;
      } catch (_) {}
    }
    return null;
  }
}
