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
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final repository = _IntegrationCreateRepository();
    final controller = CreateProjectController(repository)..onInit();
    Get.put<CreateProjectController>(controller);

    await tester.pumpWidget(
      const GetMaterialApp(home: CreateProjectPage()),
    );

    final formFields = find.byType(TextFormField);
    await tester.enterText(formFields.at(0), 'Flujo integrado');
    await tester.enterText(
      formFields.at(1),
      'Proyecto creado en una prueba aislada',
    );
    final submitButton = find.byType(ElevatedButton);
    await tester.scrollUntilVisible(submitButton, 500,
        scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    expect(repository.created, isTrue);
    expect(controller.titleController.text, isEmpty);

    controller.onClose();
    Get.reset();
  });
}
