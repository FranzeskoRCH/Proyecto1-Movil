import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/roble_error_handler.dart';
import '../../domain/models/created_project.dart';
import '../viewmodels/my_projects_controller.dart';

/// Pantalla para editar un proyecto propio publicado.
class EditProjectPage extends StatefulWidget {
  const EditProjectPage({super.key, required this.project});

  final CreatedProject project;

  @override
  State<EditProjectPage> createState() => _EditProjectPageState();
}

class _EditProjectPageState extends State<EditProjectPage> {
  static const List<String> _availableCategories = [
    'Tech',
    'Medio Ambiente',
    'Arte y Diseño',
    'Salud',
    'Investigación Académica',
    'Impacto Social',
    'Educación',
  ];

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _visionController;
  late final TextEditingController _imageUrlController;
  late final TextEditingController _roleInputController;

  late final Set<String> _selectedCategories;
  late final List<String> _roles;
  late int _vacancies;
  late CreatedProjectStatus _status;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final p = widget.project;
    _titleController = TextEditingController(text: p.title);
    _descriptionController = TextEditingController(text: p.description);
    _visionController = TextEditingController(text: p.vision);
    _imageUrlController = TextEditingController(text: p.imageUrl);
    _roleInputController = TextEditingController();
    _selectedCategories = p.categories.toSet();
    _roles = List<String>.of(p.roles);
    _vacancies = p.vacancies;
    _status = p.status;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _visionController.dispose();
    _imageUrlController.dispose();
    _roleInputController.dispose();
    super.dispose();
  }

  void _toggleCategory(String category) {
    setState(() {
      if (_selectedCategories.contains(category)) {
        if (_selectedCategories.length > 1) {
          _selectedCategories.remove(category);
        }
      } else {
        _selectedCategories.add(category);
      }
    });
  }

  void _addRole(String role) {
    final trimmed = role.trim();
    if (trimmed.isEmpty || _roles.contains(trimmed)) return;
    setState(() {
      _roles.add(trimmed);
      _roleInputController.clear();
    });
  }

  void _removeRole(String role) => setState(() => _roles.remove(role));

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty) {
      RobleErrorHandler.showErrorSnackbar(
        title: 'Campo obligatorio',
        error: 'Por favor ingresa el título del proyecto',
      );
      return;
    }
    if (description.isEmpty) {
      RobleErrorHandler.showErrorSnackbar(
        title: 'Campo obligatorio',
        error: 'Por favor ingresa una breve descripción',
      );
      return;
    }
    if (_selectedCategories.isEmpty) {
      RobleErrorHandler.showErrorSnackbar(
        title: 'Categoría requerida',
        error: 'Selecciona al menos una categoría',
      );
      return;
    }
    if (_roles.isEmpty) {
      RobleErrorHandler.showErrorSnackbar(
        title: 'Roles requeridos',
        error: 'Agrega al menos un rol que busques en tu equipo',
      );
      return;
    }

    setState(() => _isLoading = true);
    final controller = Get.find<MyProjectsController>();
    final vision = _visionController.text.trim();
    final ok = await controller.updateProject(
      projectId: widget.project.id,
      title: title,
      description: description,
      vision: vision.isNotEmpty ? vision : description,
      vacancies: _vacancies,
      status: _status,
      categories: _selectedCategories.toList(),
      roles: _roles,
      imageUrl: _imageUrlController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);
    // Usar Navigator.pop (no Get.back) para no cerrar el snackbar de éxito
    // que el controlador acaba de mostrar.
    if (ok) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F2EC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F2EC),
        elevation: 0,
        foregroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          'Editar Proyecto',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Información General'),
              const SizedBox(height: 12),
              _buildCard([
                TextFormField(
                  controller: _titleController,
                  decoration: _buildInputDecoration(
                    label: 'Título del proyecto *',
                    hint: 'Ej. EcoCampus Sorter',
                    icon: Icons.lightbulb_outline,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 2,
                  decoration: _buildInputDecoration(
                    label: 'Descripción corta *',
                    hint: '¿En qué consiste el proyecto en pocas palabras?',
                    icon: Icons.notes_outlined,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _visionController,
                  maxLines: 3,
                  decoration: _buildInputDecoration(
                    label: 'Visión del proyecto',
                    hint: '¿Cuál es el impacto a largo plazo que buscas?',
                    icon: Icons.remove_red_eye_outlined,
                  ),
                ),
              ]),
              const SizedBox(height: 24),
              _buildSectionTitle('Categorías'),
              const SizedBox(height: 12),
              _buildCard([
                const Text(
                  'Selecciona una o más áreas afines:',
                  style: TextStyle(fontSize: 13, color: Color(0xFF757575)),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availableCategories.map((cat) {
                    final isSelected = _selectedCategories.contains(cat);
                    return FilterChip(
                      label: Text(cat),
                      selected: isSelected,
                      onSelected: (_) => _toggleCategory(cat),
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
              ]),
              const SizedBox(height: 24),
              _buildSectionTitle('Roles que buscas'),
              const SizedBox(height: 12),
              _buildCard([
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _roleInputController,
                        decoration: _buildInputDecoration(
                          label: 'Nombre del rol',
                          hint: 'Ej. UI/UX Designer',
                          icon: Icons.person_add_alt_1_outlined,
                        ),
                        onSubmitted: _addRole,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: () => _addRole(_roleInputController.text),
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
                if (_roles.isEmpty)
                  const Text(
                    'Aún no has agregado roles.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _roles.map((role) {
                      return Chip(
                        label: Text(role),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () => _removeRole(role),
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
              ]),
              const SizedBox(height: 24),
              _buildSectionTitle('Capacidad y estado'),
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
                            'Colaboradores buscados',
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
                          onPressed: _vacancies > 1
                              ? () => setState(() => _vacancies--)
                              : null,
                          icon: const Icon(Icons.remove),
                          style: IconButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFE0D8CF)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            '$_vacancies',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF7043),
                            ),
                          ),
                        ),
                        IconButton.outlined(
                          onPressed: _vacancies < 20
                              ? () => setState(() => _vacancies++)
                              : null,
                          icon: const Icon(Icons.add),
                          style: IconButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFE0D8CF)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<CreatedProjectStatus>(
                  initialValue: _status,
                  decoration: _buildInputDecoration(
                    label: 'Estado del proyecto',
                    hint: 'Selecciona un estado',
                    icon: Icons.flag_outlined,
                  ),
                  items: CreatedProjectStatus.values
                      .map(
                        (status) => DropdownMenuItem(
                          value: status,
                          child: Text(status.label),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _status = value);
                  },
                ),
              ]),
              const SizedBox(height: 24),
              _buildSectionTitle('Imagen (URL)'),
              const SizedBox(height: 12),
              _buildCard([
                TextFormField(
                  controller: _imageUrlController,
                  decoration: _buildInputDecoration(
                    label: 'URL de la imagen de portada',
                    hint: 'https://...',
                    icon: Icons.image_outlined,
                  ),
                ),
              ]),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF7043),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Guardar cambios',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
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
