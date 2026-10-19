import '../../../../core/date_labels.dart';

/// Tipo de fecha importante del calendario del proyecto.
enum ProjectEventKind {
  milestone('Hito'),
  meeting('Reunión'),
  delivery('Entrega'),
  other('Otro');

  const ProjectEventKind(this.label);

  final String label;

  static ProjectEventKind fromName(String? value) => values.firstWhere(
        (kind) => kind.name == value,
        orElse: () => ProjectEventKind.other,
      );
}

/// Fecha importante del proyecto (hito, reunión, entrega…).
class ProjectEvent {
  ProjectEvent({
    this.id = '',
    required this.projectId,
    required this.title,
    required this.date,
    this.description = '',
    this.kind = ProjectEventKind.other,
    this.createdById = '',
  });

  String id;
  String projectId;
  String title;
  String description;
  DateTime date;
  ProjectEventKind kind;
  String createdById;

  factory ProjectEvent.fromJson(Map<String, dynamic> json) => ProjectEvent(
        id: (json['_id'] ?? json['id'] ?? '').toString(),
        projectId: (json['project_id'] ?? json['projectId'] ?? '').toString(),
        title: (json['title'] ?? 'Sin título').toString(),
        description: (json['description'] ?? '').toString(),
        date: DateLabels.parse(json['event_date']) ??
            DateLabels.dateOnly(DateTime.now()),
        kind: ProjectEventKind.fromName(json['kind']?.toString()),
        createdById: (json['created_by'] ?? '').toString(),
      );

  /// Columnas de `project_event` (sin `_id`, que lo asigna Roble).
  Map<String, dynamic> toJson() => {
        'project_id': projectId,
        'title': title,
        'description': description,
        'event_date': DateLabels.toIsoDate(date),
        'kind': kind.name,
        'created_by': createdById.isEmpty ? null : createdById,
      };

  @override
  String toString() => 'ProjectEvent{id: $id, title: $title, date: $date}';
}
