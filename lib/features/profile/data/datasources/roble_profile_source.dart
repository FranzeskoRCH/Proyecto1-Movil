import 'package:movil_proyecto/core/roble_service.dart';
import 'package:movil_proyecto/features/home/domain/models/collaborator_profile.dart';
import 'i_profile_source.dart';

class RobleProfileSource implements IProfileSource {
  final RobleService _roble = RobleService();

  @override
  Future<CollaboratorProfile> getProfile() async {
    final userId = _roble.currentUserId;
    final cached = _roble.cachedUser;

    String name = cached?['name'] ?? 'Colaborador';
    String avatarUrl = 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150';
    String career = 'Estudiante';
    List<String> skills = [];
    List<String> interests = [];

    try {
      if (userId.isNotEmpty) {
        // En Roble, _id de collaborator es el UUID del usuario
        final profiles = await _roble.db.read('collaborator', filters: {'_id': userId});
        if (profiles.isNotEmpty) {
          final p = profiles.first;
          name = p['name']?.toString() ?? name;
          avatarUrl = (p['avatar_url'] ?? p['avatarUrl'])?.toString() ?? avatarUrl;
          career = p['career']?.toString() ?? career;
        }

        final skillsData = await _roble.db.read('collaborator_skill', filters: {'collaborator_id': userId});
        final dbSkills = skillsData
            .map((s) => (s['skill_name'] ?? s['skillName'] ?? s['name'] ?? '').toString())
            .where((s) => s.isNotEmpty)
            .toList();
        if (dbSkills.isNotEmpty) skills = dbSkills;

        final interestsData = await _roble.db.read('collaborator_interest', filters: {'collaborator_id': userId});
        final dbInterests = interestsData
            .map((i) => (i['interest_name'] ?? i['interestName'] ?? i['name'] ?? '').toString())
            .where((i) => i.isNotEmpty)
            .toList();
        if (dbInterests.isNotEmpty) interests = dbInterests;
      }
    } catch (_) {}

    if (skills.isEmpty) {
      skills = ['Flutter', 'Figma', 'Python', 'Trabajo en equipo'];
    }
    if (interests.isEmpty) {
      interests = ['Tecnología', 'Innovación Social', 'Medio Ambiente'];
    }

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
      final profiles = await _roble.db.read('collaborator', filters: {'_id': userId});
      if (profiles.isNotEmpty) {
        final profileId = (profiles.first['_id'] ?? profiles.first['id']).toString();
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
      _roble.updateCachedUser({'name': name, 'avatar_url': avatarUrl, 'career': career});
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
      final records = await _roble.db.read('collaborator_skill', filters: {
        'collaborator_id': userId,
        'skill_name': skill.trim(),
      });
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
      final records = await _roble.db.read('collaborator_interest', filters: {
        'collaborator_id': userId,
        'interest_name': interest.trim(),
      });
      for (final r in records) {
        final id = (r['_id'] ?? r['id'])?.toString();
        if (id != null) {
          await _roble.db.delete('collaborator_interest', id);
        }
      }
    } catch (_) {}
  }

  @override
  Future<Map<String, int>> getStats() async {
    final userId = _roble.currentUserId;
    int created = 0;
    int member = 0;
    int applied = 0;

    if (userId.isNotEmpty) {
      try {
        final createdRows = await _roble.db.read('project', filters: {'author_id': userId});
        created = createdRows.length;
      } catch (_) {}

      try {
        final memberRows = await _roble.db.read('project_member', filters: {'collaborator_id': userId});
        member = memberRows.length;
      } catch (_) {}

      try {
        final appRows = await _roble.db.read('application', filters: {'applicant_id': userId});
        applied = appRows.length;
      } catch (_) {}
    }

    return {
      'created': created,
      'member': member,
      'applied': applied,
    };
  }
}
