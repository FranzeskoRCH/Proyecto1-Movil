import 'project_member.dart';
import 'project_role.dart';

/// Entidad que representa un proyecto publicado en la plataforma.
///
/// Es la entidad compartida por la lista de exploración y el detalle. Incluye
/// la conversión JSON por conveniencia, tal como [CollaboratorProfile] en la
/// feature de inicio.
class Project {
  Project({
    required this.id,
    required this.title,
    required this.description,
    required this.vision,
    required this.authorName,
    required this.authorCareer,
    required this.authorAvatarUrl,
    required this.categories,
    required this.matchPercentage,
    required this.vacancies,
    required this.roles,
    required this.members,
    this.imageUrl,
    this.requestedToJoin = false,
  });

  String id;
  String title;

  /// Descripción corta mostrada en la tarjeta de la lista.
  String description;

  /// Descripción larga mostrada en "Visión del Proyecto".
  String vision;

  String authorName;
  String authorCareer;
  String authorAvatarUrl;
  List<String> categories;
  int matchPercentage;
  String? imageUrl;
  int vacancies;
  List<ProjectRole> roles;
  List<ProjectMember> members;

  /// Estado de la solicitud del colaborador actual (simulado en memoria).
  bool requestedToJoin;

  factory Project.fromJson(Map<String, dynamic> json) => Project(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] ?? '',
        vision: json['vision'] ?? '',
        authorName: json['authorName'] as String,
        authorCareer: json['authorCareer'] ?? '',
        authorAvatarUrl: json['authorAvatarUrl'] ?? '',
        categories: List<String>.from(json['categories'] ?? []),
        matchPercentage: json['matchPercentage'] as int? ?? 0,
        imageUrl: json['imageUrl'] as String?,
        vacancies: json['vacancies'] as int? ?? 0,
        roles: (json['roles'] as List<dynamic>? ?? [])
            .map((role) => ProjectRole.fromJson(role as Map<String, dynamic>))
            .toList(),
        members: (json['members'] as List<dynamic>? ?? [])
            .map((member) =>
                ProjectMember.fromJson(member as Map<String, dynamic>))
            .toList(),
        requestedToJoin: json['requestedToJoin'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'vision': vision,
        'authorName': authorName,
        'authorCareer': authorCareer,
        'authorAvatarUrl': authorAvatarUrl,
        'categories': categories,
        'matchPercentage': matchPercentage,
        'imageUrl': imageUrl,
        'vacancies': vacancies,
        'roles': roles.map((role) => role.toJson()).toList(),
        'members': members.map((member) => member.toJson()).toList(),
        'requestedToJoin': requestedToJoin,
      };

  @override
  String toString() =>
      'Project{id: $id, title: $title, matchPercentage: $matchPercentage}';
}
