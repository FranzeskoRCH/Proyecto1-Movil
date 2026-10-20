import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../viewmodels/create_project_controller.dart';

class CreateProjectPage extends StatelessWidget {
  const CreateProjectPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CreateProjectController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F2EC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado
              const Text(
                'Nuevo Proyecto',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E1E1E),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Publica tu iniciativa y encuentra los colaboradores idóneos',
                style: TextStyle(fontSize: 14, color: Color(0xFF757575)),
              ),
              const SizedBox(height: 24),

              // Sección 1: Información básica
              _buildSectionTitle('Información General'),
              const SizedBox(height: 12),
              _buildCard([
                TextFormField(
                  key: const Key('create_title'),
                  controller: controller.titleController,
                  decoration: _buildInputDecoration(
                    label: 'Título del proyecto *',
                    hint: 'Ej. EcoCampus Sorter',
                    icon: Icons.lightbulb_outline,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const Key('create_description'),
                  controller: controller.descriptionController,
                  maxLines: 2,
                  decoration: _buildInputDecoration(
                    label: 'Descripción corta *',
                    hint: '¿En qué consiste el proyecto en pocas palabras?',
                    icon: Icons.notes_outlined,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const Key('create_vision'),
                  controller: controller.visionController,
                  maxLines: 3,
                  decoration: _buildInputDecoration(
                    label: 'Visión del proyecto',
                    hint:
                        '¿Cuál es el impacto a largo plazo que buscas alcanzar?',
                    icon: Icons.remove_red_eye_outlined,
                  ),
                ),
              ]),
              const SizedBox(height: 24),

              // Sección 2: Categorías
              _buildSectionTitle('Categorías'),
              const SizedBox(height: 12),
              _buildCard([
                const Text(
                  'Selecciona una o más áreas afines:',
                  style: TextStyle(fontSize: 13, color: Color(0xFF757575)),
                ),
                const SizedBox(height: 10),
                Obx(
                  () => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: controller.availableCategories.map((cat) {
                      final isSelected =
                          controller.selectedCategories.contains(cat);
                      return FilterChip(
                        label: Text(cat),
                        selected: isSelected,
                        onSelected: (_) => controller.toggleCategory(cat),
                        selectedColor:
                            const Color(0xFFFF7043).withValues(alpha: 0.15),
                        checkmarkColor: const Color(0xFFFF7043),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? const Color(0xFFFF7043)
                              : const Color(0xFF424242),
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13,
                        ),
                        backgroundColor: Colors.grey.shade100,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isSelected
                                ? const Color(0xFFFF7043)
                                : Colors.grey.shade300,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ]),
              const SizedBox(height: 24),

              // Sección 3: Roles requeridos
              _buildSectionTitle('Roles que buscas'),
              const SizedBox(height: 12),
              _buildCard([
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        key: const Key('create_role_input'),
                        controller: controller.roleInputController,
                        decoration: _buildInputDecoration(
                          label: 'Nombre del rol',
                          hint: 'Ej. UI/UX Designer',
                          icon: Icons.person_add_alt_1_outlined,
                        ),
                        onSubmitted: (val) => controller.addRole(val),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      key: const Key('create_role_add'),
                      onPressed: () => controller
                          .addRole(controller.roleInputController.text),
                      icon: const Icon(Icons.add),
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFFFF7043),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Obx(
                  () => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: controller.requiredRoles.map((role) {
                      return Chip(
                        label: Text(role),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () => controller.removeRole(role),
                        backgroundColor:
                            const Color(0xFFFF7043).withValues(alpha: 0.1),
                        labelStyle: const TextStyle(
                          color: Color(0xFFFF7043),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Color(0xFFFFAB91)),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ]),
              const SizedBox(height: 24),

              // Sección 4: Vacantes
              _buildSectionTitle('Capacidad del equipo'),
              const SizedBox(height: 12),
              _buildCard([
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Vacantes disponibles',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            'Número de colaboradores buscados',
                            style: TextStyle(
                              color: Color(0xFF757575),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton.outlined(
                          onPressed: controller.decrementVacancies,
                          icon: const Icon(Icons.remove),
                          style: IconButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFE0D8CF)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Obx(
                            () => Text(
                              '${controller.vacancies.value}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFF7043),
                              ),
                            ),
                          ),
                        ),
                        IconButton.outlined(
                          onPressed: controller.incrementVacancies,
                          icon: const Icon(Icons.add),
                          style: IconButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFE0D8CF)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ]),
              const SizedBox(height: 32),

              // Botón de Envío
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    key: const Key('create_submit'),
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.submitProject,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF7043),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                    ),
                    child: controller.isLoading.value
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.5, color: Colors.white),
                          )
                        : const Text(
                            'Publicar Proyecto',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1E1E1E),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFFFF7043), size: 20),
      labelStyle: const TextStyle(color: Color(0xFF757575), fontSize: 14),
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
      filled: true,
      fillColor: const Color(0xFFFAFAFA),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFFF7043), width: 1.5),
      ),
    );
  }
}
