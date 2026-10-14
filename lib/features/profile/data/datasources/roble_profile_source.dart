import 'package:movil_proyecto/core/roble_service.dart';
import 'package:movil_proyecto/features/home/domain/models/collaborator_profile.dart';

import 'i_profile_source.dart';

class RobleProfileSource implements IProfileSource {
  final RobleService _roble = RobleService();

  static const String _defaultAvatar =
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150';

  @override
  Future<CollaboratorProfile> getProfile() async {
    final cached = _roble.cachedUser;
    return _readProfile(
      _roble.currentUserId,
      defaultName: cached?['name']?.toString() ?? 'Colaborador',
      defaultAvatar:
          (cached?['avatar_url'] ?? cached?['avatarUrl'])?.toString(),
      defaultCareer: cached?['career']?.toString(),
    );
  }

  @override
  Future<CollaboratorProfile> getCollaborator(String userId) {
    return _readProfile(userId);
  }

  Future<CollaboratorProfile> _readProfile(
    String userId, {
    String defaultName = 'Colaborador',
    String? defaultAvatar,
    String? defaultCareer,
  }) async {
    String name = defaultName;
    String avatarUrl = defaultAvatar ?? _defaultAvatar;
    String career = defaultCareer ?? 'Estudiante';
    List<String> skills = [];
    List<String> interests = [];

    try {
      if (userId.isNotEmpty) {
        // En Roble el UUID del usuario vive en collaborator.id
        final p = await _roble.findCollaborator(userId);
        if (p != null) {
          name = p['name']?.toString() ?? name;
          avatarUrl =
              (p['avatar_url'] ?? p['avatarUrl'])?.toString() ?? avatarUrl;
          career = p['career']?.toString() ?? career;
        }

        final skillsData = await _roble.db.read(
          'collaborator_skill',
          filters: {'collaborator_id': userId},
        );
        skills = skillsData
            .map(
              (s) => (s['skill_name'] ?? s['skillName'] ?? s['name'] ?? '')
                  .toString(),
            )
            .where((s) => s.isNotEmpty)
            .toList();

        final interestsData = await _roble.db.read(
          'collaborator_interest',
          filters: {'collaborator_id': userId},
        );
        interests = interestsData
            .map(
              (i) =>
                  (i['interest_name'] ?? i['interestName'] ?? i['name'] ?? '')
                      .toString(),
            )
            .where((i) => i.isNotEmpty)
            .toList();
      }
    } catch (_) {}

    return CollaboratorProfile(
      name: name,
      avatarUrl: avatarUrl,
      career: career,
      skills: skills,
      interests: interests,
    );
  }

  @override
  Future<void> updateProfile({
    required String name,
    required String career,
    required String avatarUrl,
  }) async {
    final userId = _roble.currentUserId;
    if (userId.isEmpty) return;

    try {
      final existing = await _roble.findCollaborator(userId);
      if (existing != null) {
        final profileId = (existing['_id'] ?? existing['id']).toString();
        await _roble.db.update('collaborator', profileId, {
          'name': name,
          'career': career,
          'avatar_url': avatarUrl,
        });
      } else {
        await _roble.db.create('collaborator', {
          'id': userId,
          'name': name,
          'career': career,
          'avatar_url': avatarUrl,
        });
      }
      _roble.updateCachedUser({
        'name': name,
        'avatar_url': avatarUrl,
        'career': career,
      });
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> addSkill(String skill) async {
    final userId = _roble.currentUserId;
    if (userId.isEmpty) return;
    try {
      await _roble.db.create('collaborator_skill', {
        'collaborator_id': userId,
        'skill_name': skill.trim(),
      });
    } catch (_) {}
  }

  @override
  Future<void> removeSkill(String skill) async {
    final userId = _roble.currentUserId;
    if (userId.isEmpty) return;
    try {
      final records = await _roble.db.read(
        'collaborator_skill',
        filters: {'collaborator_id': userId, 'skill_name': skill.trim()},
      );
      for (final r in records) {
        final id = (r['_id'] ?? r['id'])?.toString();
        if (id != null) {
          await _roble.db.delete('collaborator_skill', id);
        }
      }
    } catch (_) {}
  }

  @override
  Future<void> addInterest(String interest) async {
    final userId = _roble.currentUserId;
    if (userId.isEmpty) return;
    try {
      await _roble.db.create('collaborator_interest', {
        'collaborator_id': userId,
        'interest_name': interest.trim(),
      });
    } catch (_) {}
  }

  @override
  Future<void> removeInterest(String interest) async {
    final userId = _roble.currentUserId;
    if (userId.isEmpty) return;
    try {
      final records = await _roble.db.read(
        'collaborator_interest',
        filters: {'collaborator_id': userId, 'interest_name': interest.trim()},
      );
      for (final r in records) {
        final id = (r['_id'] ?? r['id'])?.toString();
        if (id != null) {
          await _roble.db.delete('collaborator_interest', id);
        }
      }
    } catch (_) {}
  }

  @override
  Future<Map<String, int>> getStats() => getStatsFor(_roble.currentUserId);

  @override
  Future<Map<String, int>> getStatsFor(String userId) async {
    int created = 0;
    int member = 0;
    int applied = 0;

    if (userId.isNotEmpty) {
      try {
        final createdRows = await _roble.db.read(
          'project',
          filters: {'author_id': userId},
        );
        created = createdRows.length;
      } catch (_) {}

      try {
        final memberRows = await _roble.db.read(
          'project_member',
          filters: {'collaborator_id': userId},
        );
        member = memberRows.length;
      } catch (_) {}

      try {
        final appRows = await _roble.db.read(
          'application',
          filters: {'applicant_id': userId},
        );
        applied = appRows.length;
      } catch (_) {}
    }

    return {'created': created, 'member': member, 'applied': applied};
  }
}
