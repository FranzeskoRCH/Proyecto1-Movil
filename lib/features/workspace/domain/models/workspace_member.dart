/// Integrante del espacio de trabajo: el creador del proyecto o un miembro
/// aceptado. Se usa para asignar tareas.
class WorkspaceMember {
  WorkspaceMember({
    required this.id,
    required this.name,
    this.avatarUrl = '',
    this.role = '',
    this.isOwner = false,
  });

  String id;
  String name;
  String avatarUrl;
  String role;
  bool isOwner;

  @override
  String toString() => 'WorkspaceMember{id: $id, name: $name}';
}
