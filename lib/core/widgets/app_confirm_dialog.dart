import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Diálogo de confirmación con el estilo de la app (tarjeta redondeada, icono
/// opcional y dos botones). Devuelve `true` si se confirma.
Future<bool> showAppConfirmDialog({
  required String title,
  required String message,
  String cancelText = 'No',
  String confirmText = 'Sí',
  Color confirmColor = const Color(0xFFFF7043),
  IconData? icon,
  Color? iconColor,
}) async {
  final result = await Get.dialog<bool>(
    _AppConfirmDialog(
      title: title,
      message: message,
      cancelText: cancelText,
      confirmText: confirmText,
      confirmColor: confirmColor,
      icon: icon,
      iconColor: iconColor ?? confirmColor,
    ),
  );
  return result ?? false;
}

/// Diálogo con entrada de texto y el estilo de la app. Devuelve el texto
/// introducido, o `null` si se cancela o queda vacío.
Future<String?> showAppInputDialog({
  required String title,
  String hint = '',
  String confirmText = 'Agregar',
  Color confirmColor = const Color(0xFFFF7043),
  IconData? icon,
}) {
  return Get.dialog<String>(
    _AppInputDialog(
      title: title,
      hint: hint,
      confirmText: confirmText,
      confirmColor: confirmColor,
      icon: icon,
    ),
  );
}

class _AppConfirmDialog extends StatelessWidget {
  const _AppConfirmDialog({
    required this.title,
    required this.message,
    required this.cancelText,
    required this.confirmText,
    required this.confirmColor,
    required this.iconColor,
    this.icon,
  });

  final String title;
  final String message;
  final String cancelText;
  final String confirmText;
  final Color confirmColor;
  final Color iconColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 26, 24, 22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 24,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E1E1E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
                color: Color(0xFF6B6B6B),
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: TextButton(
                      onPressed: () => Get.back(result: false),
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFF4F1EE),
                        foregroundColor: const Color(0xFF6B6B6B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        cancelText,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => Get.back(result: true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: confirmColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        confirmText,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AppInputDialog extends StatefulWidget {
  const _AppInputDialog({
    required this.title,
    required this.hint,
    required this.confirmText,
    required this.confirmColor,
    this.icon,
  });

  final String title;
  final String hint;
  final String confirmText;
  final Color confirmColor;
  final IconData? icon;

  @override
  State<_AppInputDialog> createState() => _AppInputDialogState();
}

class _AppInputDialogState extends State<_AppInputDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = _controller.text.trim();
    Get.back(result: value.isEmpty ? null : value);
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.title;
    final hint = widget.hint;
    final confirmText = widget.confirmText;
    final confirmColor = widget.confirmColor;
    final icon = widget.icon;
    final controller = _controller;
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 26, 24, 22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 24,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  color: confirmColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: confirmColor, size: 28),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E1E1E),
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: controller,
              autofocus: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              style: const TextStyle(fontSize: 15, color: Color(0xFF1E1E1E)),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF9E9E9E),
                ),
                filled: true,
                fillColor: const Color(0xFFFAFAFA),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE0D8CF)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: confirmColor, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFF4F1EE),
                        foregroundColor: const Color(0xFF6B6B6B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: confirmColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        confirmText,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
