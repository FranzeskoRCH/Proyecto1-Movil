import '../../domain/models/user_session.dart';

abstract class IAuthSource {
  Future<UserSession> login({required String email, required String password});
  Future<UserSession> register({
    required String email,
    required String password,
    required String name,
  });
  Future<void> logout();
  Future<bool> restoreSession();
  UserSession? get currentUser;
  bool get isLoggedIn;
}
