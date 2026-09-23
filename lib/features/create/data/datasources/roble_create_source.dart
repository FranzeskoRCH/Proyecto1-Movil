import 'dart:math' as math;
import 'package:loggy/loggy.dart';
import '../../../../core/roble_service.dart';
import 'i_create_source.dart';

class RobleCreateSource with NetworkLoggy implements ICreateSource {
  final RobleService _roble = RobleService();

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
    final userId = _roble.currentUserId;
    final fallbackImage = imageUrl?.isNotEmpty == true
        ? imageUrl!
        : 'https://images.unsplash.com/photo-1522071820081-009f0129c71c?w=600';

    // Generar UUID v4 para la clave primaria de la tabla project
    final random = math.Random();
    String generateUuidV4() {
      final bytes = List<int>.generate(16, (_) => random.nextInt(256));
      bytes[6] = (bytes[6] & 0x0f) | 0x40; // Version 4
      bytes[8] = (bytes[8] & 0x3f) | 0x80; // Variant RFC4122
      return [
        bytes.sublist(0, 4).map((b) => b.toRadixString(16).padLeft(2, '0')).join(),
        bytes.sublist(4, 6).map((b) => b.toRadixString(16).padLeft(2, '0')).join(),
        bytes.sublist(6, 8).map((b) => b.toRadixString(16).padLeft(2, '0')).join(),
        bytes.sublist(8, 10).map((b) => b.toRadixString(16).padLeft(2, '0')).join(),
        bytes.sublist(10, 16).map((b) => b.toRadixString(16).padLeft(2, '0')).join(),
      ].join('-');
    }

    final projectId = generateUuidV4();

    loggy.info('[ROBLE_CREATE] Insertando proyecto en tabla project: "$title" (ID: $projectId, Autor: $userId)');
    try {
      // 0. Garantizar que el autor exista en la tabla collaborator (requisito de fk_project_author)
      try {
        final existingCollabs = await _roble.db.read('collaborator', filters: {'_id': userId});
        if (existingCollabs.isEmpty) {
          loggy.info('[ROBLE_CREATE] Creando registro de autor en collaborator para $userId...');
          final cached = _roble.cachedUser;
          final authorName = (cached?['name'] ?? 'Colaborador').toString();
          final authorCareer = (cached?['career'] ?? 'Estudiante').toString();
          final authorAvatar = (cached?['avatar_url'] ?? cached?['avatarUrl'] ?? fallbackImage).toString();
          await _roble.db.create('collaborator', {
            'id': userId,
            'name': authorName,
            'career': authorCareer,
            'avatar_url': authorAvatar,
          });
          loggy.info('[ROBLE_CREATE] Autor registrado exitosamente en collaborator.');
        }
      } catch (e) {
        loggy.warning('[ROBLE_CREATE] Advertencia al verificar/crear autor en collaborator: $e');
      }

      // 1. Crear el proyecto en Roble usando snake_case segun el esquema real de la BD
      await _roble.db.create('project', {
        'id': projectId,
        'author_id': userId,
        'title': title,
        'description': description,
        'vision': vision,
        'image_url': fallbackImage,
        'vacancies': vacancies,
        'status': 'recruiting',
      });

      loggy.info('[ROBLE_CREATE] Registro de proyecto creado exitosamente con ID: $projectId');

      // 2. Asociar categorias (campo category_name segun esquema)
      for (final cat in categories) {
        if (cat.trim().isNotEmpty) {
          try {
            await _roble.db.create('project_category', {
              'project_id': projectId,
              'category_name': cat.trim(),
            });
            loggy.info('[ROBLE_CREATE] Categoria asociada: ${cat.trim()} a proyecto $projectId');
          } catch (e) {
            loggy.warning('[ROBLE_CREATE] Error al asociar categoria ${cat.trim()}: $e');
          }
        }
      }

      // 3. Asociar roles (campo role_name segun esquema)
      for (final role in roles) {
        if (role.trim().isNotEmpty) {
          try {
            await _roble.db.create('project_role', {
              'project_id': projectId,
              'role_name': role.trim(),
            });
            loggy.info('[ROBLE_CREATE] Rol asociado: ${role.trim()} a proyecto $projectId');
          } catch (e) {
            loggy.warning('[ROBLE_CREATE] Error al asociar rol ${role.trim()}: $e');
          }
        }
      }
    } catch (e) {
      loggy.error('[ROBLE_CREATE] Error al crear proyecto en Roble: $e');
      rethrow;
    }

    return projectId;
  }
}

