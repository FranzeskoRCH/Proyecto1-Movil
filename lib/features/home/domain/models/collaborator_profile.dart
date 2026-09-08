/// Entidad del perfil de un colaborador.
///
/// Representa las "reglas" del dominio. Incluye la conversión JSON por
/// conveniencia, tal como lo hace el template (ver `Product`).
class CollaboratorProfile {
  CollaboratorProfile({
    required this.name,
    required this.avatarUrl,
    required this.career,
    required this.skills,
    required this.interests,
  });

  String name;
  String avatarUrl;
  String career;
  List<String> skills;
  List<String> interests;

  factory CollaboratorProfile.fromJson(Map<String, dynamic> json) =>
      CollaboratorProfile(
        name: json['name'] as String,
        avatarUrl: json['avatarUrl'] ?? '',
        career: json['career'] ?? '---',
        skills: List<String>.from(json['skills'] ?? []),
        interests: List<String>.from(json['interests'] ?? []),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'avatarUrl': avatarUrl,
        'career': career,
        'skills': skills,
        'interests': interests,
      };

  @override
  String toString() {
    return 'CollaboratorProfile{name: $name, avatarUrl: $avatarUrl, '
        'career: $career, skills: $skills, interests: $interests}';
  }
}
