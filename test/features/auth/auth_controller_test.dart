import 'package:flutter_test/flutter_test.dart';
import 'package:movil_proyecto/features/auth/domain/models/user_session.dart';
import 'package:movil_proyecto/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:movil_proyecto/features/auth/ui/viewmodels/auth_controller.dart';

class MockAuthRepository implements IAuthRepository {
  UserSession? _user;
  bool shouldFail = false;

  @override
  UserSession? get currentUser => _user;

  @override
  bool get isLoggedIn => _user != null;

  @override
  Future<UserSession> login({required String email, required String password}) async {
    if (shouldFail) throw Exception('Credenciales incorrectas');
    _user = UserSession(userId: 'u1', email: email, name: 'Usuario Test');
    return _user!;
  }

  @override
  Future<UserSession> register({
    required String email,
    required String password,
    required String name,
  }) async {
    if (shouldFail) throw Exception('Error en registro');
    _user = UserSession(userId: 'u1', email: email, name: name);
    return _user!;
  }

  @override
  Future<void> logout() async {
    _user = null;
  }

  @override
  Future<bool> restoreSession() async {
    return _user != null;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthRepository mockRepo;
  late AuthController controller;

  setUp(() {
    mockRepo = MockAuthRepository();
    controller = AuthController(mockRepo);
  });

  test('login exitoso actualiza estado del usuario', () async {
    expect(controller.isLoggedIn, isFalse);

    final success = await controller.login('test@uninorte.edu.co', '123456');
    expect(success, isTrue);
    expect(controller.isLoggedIn, isTrue);
    expect(controller.user?.email, 'test@uninorte.edu.co');
  });

  test('login fallido reporta error y no inicia sesión', () async {
    mockRepo.shouldFail = true;

    final success = await controller.login('fail@uninorte.edu.co', 'wrong');
    expect(success, isFalse);
    expect(controller.isLoggedIn, isFalse);
    expect(controller.error, isNotNull);
  });

  test('logout limpia el estado del usuario', () async {
    await controller.login('test@uninorte.edu.co', '123456');
    expect(controller.isLoggedIn, isTrue);

    await controller.logout();
    expect(controller.isLoggedIn, isFalse);
    expect(controller.user, isNull);
  });
}
