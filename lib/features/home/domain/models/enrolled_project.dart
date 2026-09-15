/// Proyecto en el que el colaborador ya fue aceptado y participa.
class EnrolledProject {
  EnrolledProject({
    required this.id,
    required this.title,
    required this.description,
    required this.authorName,
    required this.authorAvatarUrl,
    required this.role,
  });

  String id;
  String title;
  String description;
  String authorName;
  String authorAvatarUrl;

  /// Rol con el que el colaborador fue aceptado dentro del proyecto.
  String role;

  factory EnrolledProject.fromJson(Map<String, dynamic> json) => EnrolledProject(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] ?? '',
        authorName: json['authorName'] as String,
        authorAvatarUrl: json['authorAvatarUrl'] ?? '',
        role: json['role'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'authorName': authorName,
        'authorAvatarUrl': authorAvatarUrl,
        'role': role,
      };

  @override
  String toString() => 'EnrolledProject{id: $id, title: $title, role: $role}';
}
