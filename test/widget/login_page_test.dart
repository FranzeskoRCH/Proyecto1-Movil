import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:movil_proyecto/features/auth/domain/models/user_session.dart';
import 'package:movil_proyecto/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:movil_proyecto/features/auth/ui/viewmodels/auth_controller.dart';
import 'package:movil_proyecto/features/auth/ui/views/login_page.dart';

class _FakeAuthRepository implements IAuthRepository {
  @override
  UserSession? currentUser;

  @override
  bool get isLoggedIn => currentUser != null;

  @override
  Future<UserSession> login(
          {required String email, required String password}) async =>
      UserSession(userId: 'test-user', email: email, name: 'Test');

  @override
  Future<UserSession> register({
    required String email,
    required String password,
    required String name,
  }) async =>
      UserSession(userId: 'test-user', email: email, name: name);

  @override
  Future<void> logout() async {}

  @override
  Future<bool> restoreSession() async => false;
}

void main() {
  setUp(() {
    Get.put<AuthController>(AuthController(_FakeAuthRepository()));
  });

  tearDown(Get.reset);

  testWidgets('shows validation errors before contacting the controller',
      (tester) async {
    await tester.pumpWidget(const GetMaterialApp(home: LoginPage()));

    await tester.tap(find.byKey(const Key('login_submit')));
    await tester.pump();

    expect(find.textContaining('Ingresa tu correo'), findsOneWidget);
    expect(find.textContaining('Ingresa tu contrase'), findsOneWidget);
  });

  testWidgets('rejects an invalid email entered by key', (tester) async {
    await tester.pumpWidget(const GetMaterialApp(home: LoginPage()));

    await tester.enterText(
        find.byKey(const Key('login_email')), 'no-es-correo');
    await tester.enterText(find.byKey(const Key('login_password')), 'secreto');
    await tester.tap(find.byKey(const Key('login_submit')));
    await tester.pump();

    expect(find.textContaining('Ingresa un correo válido'), findsOneWidget);
  });
}
