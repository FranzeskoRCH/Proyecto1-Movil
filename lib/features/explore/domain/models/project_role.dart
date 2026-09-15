/// Rol o habilidad requerida dentro de un proyecto.
///
/// [hasSkill] indica si el colaborador actual cumple con el requisito, lo que
/// la vista de detalle representa con un check verde o un círculo vacío.
class ProjectRole {
  ProjectRole({
    required this.name,
    this.hasSkill = false,
  });

  String name;
  bool hasSkill;

  factory ProjectRole.fromJson(Map<String, dynamic> json) => ProjectRole(
        name: json['name'] as String,
        hasSkill: json['hasSkill'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'hasSkill': hasSkill,
      };

  @override
  String toString() => 'ProjectRole{name: $name, hasSkill: $hasSkill}';
}
