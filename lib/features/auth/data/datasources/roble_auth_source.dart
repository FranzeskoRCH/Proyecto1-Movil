import 'package:loggy/loggy.dart';
import '../../../../core/roble_service.dart';
import '../../domain/models/user_session.dart';
import 'i_auth_source.dart';

class RobleAuthSource with NetworkLoggy implements IAuthSource {
  final RobleService _roble = RobleService();

  @override
  bool get isLoggedIn => _roble.isLoggedIn;

  @override
  UserSession? get currentUser {
    final cached = _roble.cachedUser;
    if (cached == null) return null;
    return UserSession.fromRobleMap(cached);
  }

  @override
  Future<UserSession> login({
    required String email,
    required String password,
  }) async {
    loggy.info('[ROBLE_AUTH] Enviando solicitud de login a Roble API (email: $email)');
    final userMap = await _roble.db.login(email: email, password: password);
    loggy.info('[ROBLE_AUTH] Respuesta recibida de login: ${userMap.keys.toList()}');

    Map<String, dynamic> userData = userMap;
    if (userData.isEmpty || !userData.containsKey('email')) {
      try {
        loggy.info('[ROBLE_AUTH] Consultando perfil de currentUser...');
        userData = await _roble.db.currentUser();
        loggy.info('[ROBLE_AUTH] currentUser obtenido: ${userData['email']}');
      } catch (e) {
        loggy.warning('[ROBLE_AUTH] No se pudo obtener currentUser adicional: $e');
      }
    }

    _roble.setCachedUser(userData);
    return UserSession.fromRobleMap(userData);
  }

  @override
  Future<UserSession> register({
    required String email,
    required String password,
    required String name,
  }) async {
    loggy.info('[ROBLE_AUTH] Enviando registro a Roble API (email: $email, name: $name, autoLogin: true)');
    final userMap = await _roble.db.register(
      email: email,
      password: password,
      name: name,
      // extra guarda datos adicionales en user_system.extra (JSONB)
      // Sirve como backup del perfil aunque collaborator falle
      extra: {
        'career': 'Estudiante',
        'avatar_url': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
      },
      autoLogin: true,
    );
    loggy.info('[ROBLE_AUTH] Respuesta recibida de register: ${userMap.keys.toList()}');

    Map<String, dynamic> userData = userMap;
    if (userData.isEmpty || !userData.containsKey('email')) {
      try {
        userData = await _roble.db.currentUser();
        loggy.info('[ROBLE_AUTH] currentUser obtenido tras registro: ${userData['email']}');
      } catch (e) {
        loggy.warning('[ROBLE_AUTH] No se pudo obtener currentUser tras registro: $e');
      }
    }

    _roble.setCachedUser(userData);
    final session = UserSession.fromRobleMap(userData);

    // Crear perfil inicial en la tabla 'collaborator'
    // NOTA: En Roble, el _id del registro se asigna automaticamente al UUID del usuario autenticado.
    // No se debe pasar userId como campo — Roble lo vincula internamente.
    try {
      loggy.info('[ROBLE_AUTH] Creando registro en tabla collaborator para userId: ${session.userId}');
      await _roble.db.create('collaborator', {
        'id': session.userId,
        'name': name,
        'career': 'Estudiante',
        'avatar_url': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
      });
      loggy.info('[ROBLE_AUTH] Registro en collaborator creado exitosamente.');
    } catch (e) {
      loggy.warning('[ROBLE_AUTH] No se pudo crear collaborator inicial (posiblemente ya existe o la tabla no esta inicializada): $e');
    }

    return session;
  }

  @override
  Future<void> logout() async {
    loggy.info('[ROBLE_AUTH] Solicitando logout al servicio de Roble...');
    await _roble.clearSession();
    loggy.info('[ROBLE_AUTH] Logout completado.');
  }

  @override
  Future<bool> restoreSession() async {
    loggy.info('[ROBLE_AUTH] Verificando restauracion de sesion con el SDK...');
    final restored = await _roble.restoreSession();
    loggy.info('[ROBLE_AUTH] Resultado de restauracion: $restored');
    return restored;
  }
}
