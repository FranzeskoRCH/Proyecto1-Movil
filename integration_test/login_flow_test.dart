import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:integration_test/integration_test.dart';

import 'package:movil_proyecto/features/auth/ui/viewmodels/auth_controller.dart';
import 'package:movil_proyecto/features/auth/ui/views/login_page.dart';
import 'package:movil_proyecto/features/home/ui/views/main_shell.dart';

import 'test_dependencies.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late TestDependencies dependencies;

  setUp(() {
    dependencies = TestDependencies();
    dependencies.register();
  });

  tearDown(Get.reset);

  testWidgets('login navigates to the authenticated home shell',
      (tester) async {
    await tester.pumpWidget(const GetMaterialApp(home: LoginPage()));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('login_email')),
      'ana@uninorte.edu.co',
    );
    await tester.enterText(
      find.byKey(const Key('login_password')),
      'secreto123',
    );
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump();

    await tester.tap(find.byKey(const Key('login_submit')));
    await tester.pumpAndSettle();

    expect(Get.find<AuthController>().isLoggedIn, isTrue);
    expect(find.byType(MainShell), findsOneWidget);
    expect(find.byKey(const Key('login_submit')), findsNothing);
    expect(find.textContaining(testUserName), findsWidgets);
    expect(find.text('Inicio'), findsOneWidget);
  });
}
