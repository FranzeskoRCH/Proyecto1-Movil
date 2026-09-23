import 'package:movil_proyecto/features/home/domain/models/collaborator_profile.dart';

abstract class IProfileSource {
  Future<CollaboratorProfile> getProfile();
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
}
