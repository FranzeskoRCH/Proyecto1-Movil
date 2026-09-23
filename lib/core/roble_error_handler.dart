import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loggy/loggy.dart';
import 'package:roble/roble.dart';

class RobleErrorHandler {
  /// Convierte cualquier excepción del SDK de Roble en un mensaje amigable para el usuario
  static String getErrorMessage(dynamic error) {
    logError('[ERROR_HANDLER] Procesando excepcion: ${error.runtimeType} | Mensaje: $error');

    if (error is RobleApiNetworkException) {
      return 'Sin conexion a internet o el servidor no responde.';
    }

    if (error is RobleApiTimeoutException) {
      return 'Tiempo de espera agotado. Por favor intenta de nuevo.';
    }

    if (error is RobleApiAuthException) {
      return 'Credenciales invalidas o la sesion ha expirado.';
    }

    if (error is RobleApiForbiddenException) {
      return 'No tienes permisos para realizar esta accion.';
    }

    if (error is RobleApiNotFoundException) {
      return 'El elemento solicitado no fue encontrado.';
    }

    if (error is RobleApiHttpException) {
      logError('[ERROR_HANDLER] HTTP Error ${error.statusCode}: ${error.message}');
      if (error.statusCode == 429) {
        return 'Demasiados intentos seguidos. El servidor tiene un limite temporal de seguridad. Espera unos minutos.';
      }
      if (error.statusCode == 409) {
        return 'Ya existe una cuenta o registro con esa informacion.';
      }

      String cleanMsg = error.message;
      if (cleanMsg.contains(': ')) {
        cleanMsg = cleanMsg.substring(cleanMsg.indexOf(': ') + 2);
      }
      if (cleanMsg.startsWith('[') && cleanMsg.endsWith(']')) {
        cleanMsg = cleanMsg.substring(1, cleanMsg.length - 1);
      }
      return cleanMsg.isNotEmpty ? cleanMsg : 'Error en la solicitud (Codigo ${error.statusCode}).';
    }

    if (error is RobleApiException) {
      return error.message;
    }

    return error.toString();
  }

  /// Muestra un Snackbar de error elegante usando GetX
  static void showErrorSnackbar({
    String title = 'Error',
    required dynamic error,
  }) {
    final message = getErrorMessage(error);
    logError('[ERROR_SNACKBAR] $title: $message');

    if (Get.overlayContext == null) return;

    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.redAccent.withValues(alpha: 0.95),
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
      borderRadius: 10,
      duration: const Duration(seconds: 4),
      icon: const Icon(Icons.error_outline, color: Colors.white),
    );
  }

  /// Muestra un Snackbar de éxito elegante usando GetX
  static void showSuccessSnackbar({
    String title = 'Exito',
    required String message,
  }) {
    logInfo('[SUCCESS_SNACKBAR] $title: $message');

    if (Get.overlayContext == null) return;

    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF2E7D32).withValues(alpha: 0.95),
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
      borderRadius: 10,
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.check_circle_outline, color: Colors.white),
    );
  }
}
