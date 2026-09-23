import 'package:flutter_test/flutter_test.dart';
import 'package:movil_proyecto/features/create/domain/repositories/i_create_repository.dart';
import 'package:movil_proyecto/features/create/ui/viewmodels/create_project_controller.dart';

class MockCreateRepository implements ICreateRepository {
  bool wasCalled = false;

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
    wasCalled = true;
    return 'new_project_123';
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockCreateRepository mockRepo;
  late CreateProjectController controller;

  setUp(() {
    mockRepo = MockCreateRepository();
    controller = CreateProjectController(mockRepo);
    controller.onInit();
  });

  tearDown(() {
    controller.onClose();
  });

  test('validación rechaza título vacío', () async {
    controller.titleController.text = '';
    controller.descriptionController.text = 'Descripción válida';

    final success = await controller.submitProject();
    expect(success, isFalse);
    expect(mockRepo.wasCalled, isFalse);
  });

  test('agregar y quitar roles funciona reactivamente', () {
    expect(controller.requiredRoles.contains('DevOps'), isFalse);

    controller.addRole('DevOps');
    expect(controller.requiredRoles.contains('DevOps'), isTrue);

    controller.removeRole('DevOps');
    expect(controller.requiredRoles.contains('DevOps'), isFalse);
  });

  test('incrementar y decrementar vacantes modifica el contador dentro del rango', () {
    expect(controller.vacancies.value, 2);

    controller.incrementVacancies();
    expect(controller.vacancies.value, 3);

    controller.decrementVacancies();
    expect(controller.vacancies.value, 2);
  });

  test('envío exitoso crea el proyecto y resetea el formulario', () async {
    controller.titleController.text = 'Proyecto Prueba';
    controller.descriptionController.text = 'Descripción de prueba';
    controller.visionController.text = 'Visión de prueba';

    final success = await controller.submitProject();
    expect(success, isTrue);
    expect(mockRepo.wasCalled, isTrue);
    expect(controller.titleController.text, isEmpty);
  });
}
