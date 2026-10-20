import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:movil_proyecto/features/create/domain/repositories/i_create_repository.dart';
import 'package:movil_proyecto/features/create/ui/viewmodels/create_project_controller.dart';
import 'package:movil_proyecto/features/create/ui/views/create_project_page.dart';

class _FakeCreateRepository implements ICreateRepository {
  int calls = 0;

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
    calls++;
    return 'test-project';
  }
}

void main() {
  late _FakeCreateRepository repository;
  late CreateProjectController controller;

  setUp(() {
    repository = _FakeCreateRepository();
    controller = CreateProjectController(repository)..onInit();
    Get.put<CreateProjectController>(controller);
  });

  tearDown(() {
    controller.onClose();
    Get.reset();
  });

  Widget buildSubject() => const MaterialApp(home: CreateProjectPage());

  testWidgets('renders the create form and its default values', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(buildSubject());

    expect(find.text('Nuevo Proyecto'), findsOneWidget);
    expect(find.text('Roles que buscas'), findsOneWidget);
    expect(find.text('Desarrollo Frontend'), findsNWidgets(2));
    expect(find.text('2'), findsOneWidget);
    expect(find.text('Publicar Proyecto'), findsOneWidget);
    expect(find.byKey(const Key('create_title')), findsOneWidget);
    expect(find.byKey(const Key('create_submit')), findsOneWidget);
  });

  testWidgets('adds a role and submits the entered project', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(buildSubject());

    final roleField = find.byKey(const Key('create_role_input'));
    await tester.enterText(roleField, ' QA ');
    final addRoleButton = find.byKey(const Key('create_role_add'));
    await tester.ensureVisible(addRoleButton);
    await tester.tap(addRoleButton);
    await tester.pump();

    expect(find.text('QA'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('create_title')),
      'Proyecto de prueba',
    );
    await tester.enterText(
      find.byKey(const Key('create_description')),
      'Descripción de prueba',
    );
    final submitButton = find.byKey(const Key('create_submit'));
    await tester.scrollUntilVisible(submitButton, 500,
        scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    expect(repository.calls, 1);
    expect(controller.titleController.text, isEmpty);
  });

  testWidgets('does not submit when required title and description are empty',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(buildSubject());

    final submitButton = find.byKey(const Key('create_submit'));
    await tester.scrollUntilVisible(submitButton, 500,
        scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    await tester.tap(submitButton);
    await tester.pump();

    expect(repository.calls, 0);
  });
}
