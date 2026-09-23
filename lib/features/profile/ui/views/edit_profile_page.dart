import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../viewmodels/profile_controller.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _careerController;
  late final TextEditingController _avatarUrlController;

  @override
  void initState() {
    super.initState();
    final profile = Get.find<ProfileController>().profile;
    _nameController = TextEditingController(text: profile?.name ?? '');
    _careerController = TextEditingController(text: profile?.career ?? '');
    _avatarUrlController = TextEditingController(text: profile?.avatarUrl ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _careerController.dispose();
    _avatarUrlController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    final controller = Get.find<ProfileController>();
    final success = await controller.updateProfile(
      name: _nameController.text.trim(),
      career: _careerController.text.trim(),
      avatarUrl: _avatarUrlController.text.trim(),
    );
    if (success && mounted) {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F2EC),
      appBar: AppBar(
        title: const Text(
          'Editar Perfil',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E1E1E)),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Vista previa de Avatar
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 46,
                        backgroundColor: const Color(0xFFFF7043).withValues(alpha: 0.2),
                        backgroundImage: _avatarUrlController.text.isNotEmpty
                            ? NetworkImage(_avatarUrlController.text)
                            : null,
                        child: _avatarUrlController.text.isEmpty
                            ? const Icon(Icons.person, size: 48, color: Color(0xFFFF7043))
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF7043),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit, size: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Campo Nombre
                TextFormField(
                  controller: _nameController,
                  decoration: _buildInputDecoration(
                    label: 'Nombre completo',
                    icon: Icons.person_outline,
                  ),
                  validator: (val) =>
                      val == null || val.trim().isEmpty ? 'Ingresa tu nombre' : null,
                ),
                const SizedBox(height: 16),

                // Campo Carrera
                TextFormField(
                  controller: _careerController,
                  decoration: _buildInputDecoration(
                    label: 'Carrera o Especialidad',
                    icon: Icons.school_outlined,
                  ),
                  validator: (val) =>
                      val == null || val.trim().isEmpty ? 'Ingresa tu carrera' : null,
                ),
                const SizedBox(height: 16),

                // Campo Avatar URL
                TextFormField(
                  controller: _avatarUrlController,
                  decoration: _buildInputDecoration(
                    label: 'URL de fotografía de perfil',
                    icon: Icons.link,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 32),

                // Botón Guardar
                Obx(
                  () => ElevatedButton(
                    onPressed: controller.isLoading.value ? null : _handleSave,
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
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Guardar Cambios',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFFFF7043), size: 20),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE0D8CF)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFFF7043), width: 1.5),
      ),
    );
  }
}
