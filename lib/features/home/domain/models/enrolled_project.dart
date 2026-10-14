/// Proyecto en el que el colaborador ya fue aceptado y participa.
class EnrolledProject {
  EnrolledProject({
    required this.id,
    required this.title,
    required this.description,
    required this.authorName,
    required this.authorAvatarUrl,
    required this.role,
    this.isMember = true,
  });

  String id;
  String title;
  String description;
  String authorName;
  String authorAvatarUrl;

  /// Rol con el que el colaborador fue aceptado dentro del proyecto.
  String role;

  /// `true` si es miembro aceptado del equipo; `false` si solo aplicó.
  bool isMember;

  factory EnrolledProject.fromJson(Map<String, dynamic> json) =>
      EnrolledProject(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] ?? '',
        authorName: json['authorName'] as String,
        authorAvatarUrl: json['authorAvatarUrl'] ?? '',
        role: json['role'] ?? '',
        isMember: json['isMember'] as bool? ?? true,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'authorName': authorName,
    'authorAvatarUrl': authorAvatarUrl,
    'role': role,
    'isMember': isMember,
  };

  @override
  String toString() => 'EnrolledProject{id: $id, title: $title, role: $role}';
}
