import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:integration_test/integration_test.dart';
import 'package:movil_proyecto/features/create/domain/repositories/i_create_repository.dart';
import 'package:movil_proyecto/features/create/ui/viewmodels/create_project_controller.dart';
import 'package:movil_proyecto/features/create/ui/views/create_project_page.dart';

class _IntegrationCreateRepository implements ICreateRepository {
  bool created = false;

  @override
  Future<String> createProject({
    required String title,
    required String description,
    required String vision,
    required List<String> categories,
    required List<String> roles,
    required int vacancies,
    String? imageUrl,
  }) async {
    created = true;
    return 'integration-project';
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('user can complete the create-project flow', (tester) async {
    final repository = _IntegrationCreateRepository();
    final controller = CreateProjectController(repository)..onInit();
    Get.put<CreateProjectController>(controller);
    addTearDown(() {
      controller.onClose();
      Get.reset();
    });

    await tester.pumpWidget(
      const GetMaterialApp(home: CreateProjectPage()),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('create_title')),
      'Flujo integrado',
    );
    await tester.enterText(
      find.byKey(const Key('create_description')),
      'Proyecto creado en una prueba aislada',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();

    final submitButton = find.byKey(const Key('create_submit'));
    await tester.scrollUntilVisible(
      submitButton,
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(submitButton);
    await tester.pumpAndSettle();
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    expect(repository.created, isTrue);
    expect(controller.titleController.text, isEmpty);
  });
}
