import '../../domain/models/user_session.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../datasources/i_auth_source.dart';

class AuthRepository implements IAuthRepository {
  final IAuthSource source;

  AuthRepository(this.source);

  @override
  bool get isLoggedIn => source.isLoggedIn;

  @override
  UserSession? get currentUser => source.currentUser;

  @override
  Future<UserSession> login({
    required String email,
    required String password,
  }) {
    return source.login(email: email, password: password);
  }

  @override
  Future<UserSession> register({
    required String email,
    required String password,
    required String name,
  }) {
    return source.register(email: email, password: password, name: name);
  }

  @override
  Future<void> logout() {
    return source.logout();
  }

  @override
  Future<bool> restoreSession() {
    return source.restoreSession();
  }
}
