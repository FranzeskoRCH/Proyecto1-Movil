import '../../../../core/date_labels.dart';

/// Tarea del espacio de trabajo de un proyecto en curso.
class ProjectTask {
  ProjectTask({
    this.id = '',
    required this.projectId,
    required this.title,
    this.description = '',
    this.assigneeId = '',
    this.assigneeName = '',
    this.dueDate,
    this.isDone = false,
    this.completedAt,
    this.completedByName = '',
    this.createdById = '',
  });

  /// `_id` de la fila en Roble (vacío mientras no se ha guardado).
  String id;
  String projectId;
  String title;
  String description;

  /// Integrante responsable; vacío si la tarea no tiene asignado.
  String assigneeId;
  String assigneeName;

  /// Fecha límite (sin hora). `null` si no tiene deadline.
  DateTime? dueDate;

  bool isDone;
  DateTime? completedAt;
  String completedByName;
  String createdById;

  bool get hasAssignee => assigneeId.isNotEmpty || assigneeName.isNotEmpty;

  /// Pendiente y con la fecha límite ya pasada.
  bool isOverdue({DateTime? now}) {
    final due = dueDate;
    if (isDone || due == null) return false;
    return due.isBefore(DateLabels.dateOnly(now ?? DateTime.now()));
  }

  factory ProjectTask.fromJson(Map<String, dynamic> json) => ProjectTask(
        id: (json['_id'] ?? json['id'] ?? '').toString(),
        projectId: (json['project_id'] ?? json['projectId'] ?? '').toString(),
        title: (json['title'] ?? 'Sin título').toString(),
        description: (json['description'] ?? '').toString(),
        assigneeId: (json['assignee_id'] ?? '').toString(),
        assigneeName: (json['assignee_name'] ?? '').toString(),
        dueDate: DateLabels.parse(json['due_date']),
        isDone: (json['status'] ?? '').toString() == 'done',
        completedAt: DateLabels.parse(json['completed_at']),
        completedByName: (json['completed_by_name'] ?? '').toString(),
        createdById: (json['created_by'] ?? '').toString(),
      );

  /// Columnas de `project_task` (sin `_id`, que lo asigna Roble).
  Map<String, dynamic> toJson() => {
        'project_id': projectId,
        'title': title,
        'description': description,
        'assignee_id': assigneeId.isEmpty ? null : assigneeId,
        'assignee_name': assigneeName,
        'due_date': dueDate == null ? null : DateLabels.toIsoDate(dueDate!),
        'status': isDone ? 'done' : 'todo',
        'completed_at': completedAt?.toUtc().toIso8601String(),
        'completed_by_name': completedByName,
        'created_by': createdById.isEmpty ? null : createdById,
      };

  ProjectTask copy() => ProjectTask(
        id: id,
        projectId: projectId,
        title: title,
        description: description,
        assigneeId: assigneeId,
        assigneeName: assigneeName,
        dueDate: dueDate,
        isDone: isDone,
        completedAt: completedAt,
        completedByName: completedByName,
        createdById: createdById,
      );

  @override
  String toString() => 'ProjectTask{id: $id, title: $title, done: $isDone}';
}
