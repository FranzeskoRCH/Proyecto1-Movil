import 'package:movil_proyecto/features/home/domain/models/collaborator_profile.dart';

import '../../domain/repositories/i_profile_repository.dart';
import '../datasources/i_profile_source.dart';

class ProfileRepository implements IProfileRepository {
  final IProfileSource source;

  ProfileRepository(this.source);

  @override
  Future<CollaboratorProfile> getProfile() {
    return source.getProfile();
  }

  @override
  Future<CollaboratorProfile> getCollaborator(String userId) {
    return source.getCollaborator(userId);
  }

  @override
  Future<void> updateProfile({
    required String name,
    required String career,
    required String avatarUrl,
  }) {
    return source.updateProfile(
      name: name,
      career: career,
      avatarUrl: avatarUrl,
    );
  }

  @override
  Future<void> addSkill(String skill) {
    return source.addSkill(skill);
  }

  @override
  Future<void> removeSkill(String skill) {
    return source.removeSkill(skill);
  }

  @override
  Future<void> addInterest(String interest) {
    return source.addInterest(interest);
  }

  @override
  Future<void> removeInterest(String interest) {
    return source.removeInterest(interest);
  }

  @override
  Future<Map<String, int>> getStats() {
    return source.getStats();
  }

  @override
  Future<Map<String, int>> getStatsFor(String userId) {
    return source.getStatsFor(userId);
  }
}
