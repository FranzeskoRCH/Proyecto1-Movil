import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/section_label.dart';
import '../viewmodels/profile_controller.dart';

/// Formulario para editar el nombre, la carrera y la foto del perfil propio.
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
  bool _avatarError = false;

  @override
  void initState() {
    super.initState();
    final profile = Get.find<ProfileController>().profile;
    _nameController = TextEditingController(text: profile?.name ?? '');
    _careerController = TextEditingController(text: profile?.career ?? '');
    _avatarUrlController =
        TextEditingController(text: profile?.avatarUrl ?? '');
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
    final name = _nameController.text.trim();
    final career = _careerController.text.trim();
    final avatarUrl = _avatarUrlController.text.trim();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F2EC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Header(onBack: Get.back),
                const SizedBox(height: 20),

                // Vista previa en vivo
                _PreviewCard(
                  name: name.isEmpty ? 'Tu nombre' : name,
                  career: career.isEmpty ? 'Tu carrera' : career,
                  avatarUrl: _avatarError ? '' : avatarUrl,
                  onImageError: () {
                    if (!_avatarError) setState(() => _avatarError = true);
                  },
                ),
                const SizedBox(height: 24),

                const SectionLabel('INFORMACIÓN PERSONAL'),
                const SizedBox(height: 12),
                _FormCard(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: _buildInputDecoration(
                        label: 'Nombre completo',
                        hint: 'Ej. Laura Martínez',
                        icon: Icons.person_outline,
                      ),
                      onChanged: (_) => setState(() {}),
                      validator: (val) => val == null || val.trim().isEmpty
                          ? 'Ingresa tu nombre'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _careerController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: _buildInputDecoration(
                        label: 'Carrera o especialidad',
                        hint: 'Ej. Ingeniería de Sistemas',
                        icon: Icons.school_outlined,
                      ),
                      onChanged: (_) => setState(() {}),
                      validator: (val) => val == null || val.trim().isEmpty
                          ? 'Ingresa tu carrera'
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                const SectionLabel('FOTO DE PERFIL'),
                const SizedBox(height: 12),
                _FormCard(
                  children: [
                    TextFormField(
                      controller: _avatarUrlController,
                      keyboardType: TextInputType.url,
                      decoration: _buildInputDecoration(
                        label: 'URL de la imagen',
                        hint: 'https://...',
                        icon: Icons.link,
                      ).copyWith(
                        suffixIcon: avatarUrl.isEmpty
                            ? null
                            : IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  size: 18,
                                  color: Color(0xFF9E9E9E),
                                ),
                                tooltip: 'Quitar foto',
                                onPressed: () => setState(() {
                                  _avatarUrlController.clear();
                                  _avatarError = false;
                                }),
                              ),
                      ),
                      onChanged: (_) => setState(() => _avatarError = false),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          _avatarError
                              ? Icons.error_outline
                              : Icons.info_outline,
                          size: 16,
                          color: _avatarError
                              ? const Color(0xFFD45A5A)
                              : const Color(0xFF9E9E9E),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _avatarError
                                ? 'No pudimos cargar la imagen. Revisa que el enlace sea público y directo.'
                                : 'Pega el enlace directo a una imagen. Verás la vista previa arriba.',
                            style: TextStyle(
                              fontSize: 12.5,
                              height: 1.4,
                              color: _avatarError
                                  ? const Color(0xFFD45A5A)
                                  : const Color(0xFF9E9E9E),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                Obx(
                  () => _SaveButton(
                    isLoading: controller.isLoading.value,
                    onTap: _handleSave,
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

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onBack,
          child: Container(
            height: 40,
            width: 40,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back,
              size: 20,
              color: Color(0xFF2B2B2B),
            ),
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mi cuenta',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF9E9E9E),
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Editar Perfil',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF2B2B2B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Tarjeta con la vista previa del perfil tal como lo verán otros.
class _PreviewCard extends StatelessWidget {
  const _PreviewCard({
    required this.name,
    required this.career,
    required this.avatarUrl,
    required this.onImageError,
  });

  final String name;
  final String career;
  final String avatarUrl;
  final VoidCallback onImageError;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Anillo con el degradado de la marca alrededor del avatar.
          Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFFFFA741), Color(0xFFFF5252)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                radius: 44,
                backgroundColor:
                    const Color(0xFFFF7043).withValues(alpha: 0.2),
                backgroundImage:
                    avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                onBackgroundImageError:
                    avatarUrl.isNotEmpty ? (_, __) => onImageError() : null,
                child: avatarUrl.isEmpty
                    ? const Icon(
                        Icons.person,
                        size: 46,
                        color: Color(0xFFFF7043),
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E1E1E),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            career,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF757575),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFF7043).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.visibility_outlined,
                  size: 14,
                  color: Color(0xFFFF7043),
                ),
                SizedBox(width: 6),
                Text(
                  'Vista previa',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFFF7043),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.isLoading, required this.onTap});

  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFA741), Color(0xFFFF5252)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33FF5252),
              blurRadius: 14,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: isLoading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_rounded, size: 20, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Guardar Cambios',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
