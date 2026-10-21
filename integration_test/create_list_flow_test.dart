import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:integration_test/integration_test.dart';

import 'package:movil_proyecto/features/create/ui/viewmodels/create_project_controller.dart';
import 'package:movil_proyecto/features/create/ui/views/create_project_page.dart';
import 'package:movil_proyecto/features/home/ui/views/main_shell.dart';
import 'package:movil_proyecto/features/project/ui/viewmodels/my_projects_controller.dart';

import 'test_dependencies.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late TestDependencies dependencies;

  setUp(() {
    dependencies = TestDependencies();
    dependencies.register();
  });

  tearDown(() {
    if (Get.isRegistered<CreateProjectController>()) {
      Get.find<CreateProjectController>().onClose();
    }
    Get.reset();
  });

  testWidgets('a created project shows up in Mis Proyectos', (tester) async {
    await tester.pumpWidget(const GetMaterialApp(home: MainShell()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Crear'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('create_title')),
      'Flujo Lista',
    );
    await tester.enterText(
      find.byKey(const Key('create_description')),
      'Proyecto creado en una prueba aislada',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();

    final submitButton = find.byKey(const Key('create_submit'));
    final createScrollable = find
        .descendant(
          of: find.byType(CreateProjectPage),
          matching: find.byType(Scrollable),
        )
        .first;
    await tester.scrollUntilVisible(
      submitButton,
      400,
      scrollable: createScrollable,
    );
    await tester.ensureVisible(submitButton);
    await tester.pumpAndSettle();
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    expect(dependencies.createRepository.created, isTrue);
    expect(dependencies.projectRepository.createdProjects, hasLength(1));
    expect(Get.find<MyProjectsController>().createdProjects, hasLength(1));

    // El snackbar de éxito permanece unos segundos y puede tapar la barra
    // inferior; se espera a que se cierre antes de navegar.
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Proyectos'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Creados'));
    await tester.pumpAndSettle();

    expect(find.text('Flujo Lista'), findsWidgets);
  });
}
