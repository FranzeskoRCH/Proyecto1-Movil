import 'package:movil_proyecto/features/home/domain/models/collaborator_profile.dart';

abstract class IProfileRepository {
  Future<CollaboratorProfile> getProfile();

  /// Perfil público de otro colaborador (autor de un proyecto, postulante…).
  Future<CollaboratorProfile> getCollaborator(String userId);
  Future<void> updateProfile({
    required String name,
    required String career,
    required String avatarUrl,
  });
  Future<void> addSkill(String skill);
  Future<void> removeSkill(String skill);
  Future<void> addInterest(String interest);
  Future<void> removeInterest(String interest);
  Future<Map<String, int>> getStats();

  /// Estadísticas de otro colaborador (creados, miembro, postulado).
  Future<Map<String, int>> getStatsFor(String userId);
}
