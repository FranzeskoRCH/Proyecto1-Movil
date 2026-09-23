import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loggy/loggy.dart';
import '../../../../core/roble_error_handler.dart';
import '../../../explore/ui/viewmodels/explore_controller.dart';
import '../../../project/ui/viewmodels/my_projects_controller.dart';
import '../../domain/repositories/i_create_repository.dart';

class CreateProjectController extends GetxController with UiLoggy {
  final ICreateRepository repository;

  CreateProjectController(this.repository);

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final visionController = TextEditingController();
  final roleInputController = TextEditingController();
  final imageUrlController = TextEditingController();

  final RxList<String> selectedCategories = <String>[].obs;
  final RxList<String> requiredRoles = <String>[].obs;
  final RxInt vacancies = 2.obs;
  final RxBool isLoading = false.obs;

  final List<String> availableCategories = [
    'Tech',
    'Medio Ambiente',
    'Arte y Diseño',
    'Salud',
    'Investigación Académica',
    'Impacto Social',
    'Educación',
  ];

  @override
  void onInit() {
    super.onInit();
    selectedCategories.add('Tech');
    requiredRoles.addAll(['Desarrollo Frontend', 'Diseño UI/UX']);
    loggy.info('[CREATE_PROJECT_CONTROLLER] Inicializado.');
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    visionController.dispose();
    roleInputController.dispose();
    imageUrlController.dispose();
    super.onClose();
  }

  void toggleCategory(String cat) {
    if (selectedCategories.contains(cat)) {
      if (selectedCategories.length > 1) {
        selectedCategories.remove(cat);
        loggy.info('[CREATE_PROJECT_CONTROLLER] Categoria removida: $cat');
      }
    } else {
      selectedCategories.add(cat);
      loggy.info('[CREATE_PROJECT_CONTROLLER] Categoria agregada: $cat');
    }
  }

  void addRole(String role) {
    final trimmed = role.trim();
    if (trimmed.isNotEmpty && !requiredRoles.contains(trimmed)) {
      requiredRoles.add(trimmed);
      roleInputController.clear();
      loggy.info('[CREATE_PROJECT_CONTROLLER] Rol agregado: $trimmed');
    }
  }

  void removeRole(String role) {
    requiredRoles.remove(role);
    loggy.info('[CREATE_PROJECT_CONTROLLER] Rol removido: $role');
  }

  void incrementVacancies() {
    if (vacancies.value < 20) {
      vacancies.value++;
      loggy.info('[CREATE_PROJECT_CONTROLLER] Vacantes incrementadas a: ${vacancies.value}');
    }
  }

  void decrementVacancies() {
    if (vacancies.value > 1) {
      vacancies.value--;
      loggy.info('[CREATE_PROJECT_CONTROLLER] Vacantes reducidas a: ${vacancies.value}');
    }
  }

  void resetForm() {
    titleController.clear();
    descriptionController.clear();
    visionController.clear();
    roleInputController.clear();
    imageUrlController.clear();
    selectedCategories.assignAll(['Tech']);
    requiredRoles.assignAll(['Desarrollador', 'Diseñador']);
    vacancies.value = 2;
    loggy.info('[CREATE_PROJECT_CONTROLLER] Formulario reseteado.');
  }

  Future<bool> submitProject() async {
    final title = titleController.text.trim();
    final description = descriptionController.text.trim();
    final vision = visionController.text.trim();

    if (title.isEmpty) {
      RobleErrorHandler.showErrorSnackbar(
        title: 'Campo obligatorio',
        error: 'Por favor ingresa el título del proyecto',
      );
      return false;
    }

    if (description.isEmpty) {
      RobleErrorHandler.showErrorSnackbar(
        title: 'Campo obligatorio',
        error: 'Por favor ingresa una breve descripción',
      );
      return false;
    }

    if (selectedCategories.isEmpty) {
      RobleErrorHandler.showErrorSnackbar(
        title: 'Categoría requerida',
        error: 'Selecciona al menos una categoría',
      );
      return false;
    }

    if (requiredRoles.isEmpty) {
      RobleErrorHandler.showErrorSnackbar(
        title: 'Roles requeridos',
        error: 'Agrega al menos un rol que busques en tu equipo',
      );
      return false;
    }

    loggy.info('[CREATE_PROJECT_CONTROLLER] Enviando nuevo proyecto: "$title" con ${requiredRoles.length} roles');
    isLoading.value = true;
    try {
      final projectId = await repository.createProject(
        title: title,
        description: description,
        vision: vision.isNotEmpty ? vision : description,
        categories: selectedCategories.toList(),
        roles: requiredRoles.toList(),
        vacancies: vacancies.value,
        imageUrl: imageUrlController.text.trim().isNotEmpty
            ? imageUrlController.text.trim()
            : null,
      );

      loggy.info('[CREATE_PROJECT_CONTROLLER] Proyecto creado exitosamente con ID: $projectId');

      RobleErrorHandler.showSuccessSnackbar(
        title: 'Proyecto Publicado',
        message: 'Tu proyecto "$title" está activo y abierto a postulaciones.',
      );

      resetForm();

      // Refrescar controladores si están instanciados
      if (Get.isRegistered<MyProjectsController>()) {
        loggy.info('[CREATE_PROJECT_CONTROLLER] Refrescando MyProjectsController...');
        Get.find<MyProjectsController>().loadProjects();
      }
      if (Get.isRegistered<ExploreController>()) {
        loggy.info('[CREATE_PROJECT_CONTROLLER] Refrescando ExploreController...');
        Get.find<ExploreController>().loadProjects();
      }

      return true;
    } catch (e) {
      loggy.error('[CREATE_PROJECT_CONTROLLER] Error al crear proyecto: $e');
      RobleErrorHandler.showErrorSnackbar(
        title: 'Error al publicar proyecto',
        error: e,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
