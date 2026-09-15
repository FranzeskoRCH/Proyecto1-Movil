/// Integrante del equipo actual de un proyecto.
class ProjectMember {
  ProjectMember({
    required this.name,
    required this.avatarUrl,
    required this.discipline,
  });

  String name;
  String avatarUrl;
  String discipline;

  factory ProjectMember.fromJson(Map<String, dynamic> json) => ProjectMember(
        name: json['name'] as String,
        avatarUrl: json['avatarUrl'] ?? '',
        discipline: json['discipline'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'avatarUrl': avatarUrl,
        'discipline': discipline,
      };

  @override
  String toString() =>
      'ProjectMember{name: $name, discipline: $discipline}';
}
