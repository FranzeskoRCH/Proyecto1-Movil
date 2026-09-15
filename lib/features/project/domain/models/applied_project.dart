import 'application_status.dart';

/// Proyecto al que el colaborador actual aplicó, con el estado de su solicitud.
class AppliedProject {
  AppliedProject({
    required this.id,
    required this.title,
    required this.description,
    required this.vision,
    required this.authorName,
    required this.authorCareer,
    required this.authorAvatarUrl,
    required this.categories,
    required this.status,
    required this.appliedDate,
  });

  String id;
  String title;
  String description;
  String vision;
  String authorName;
  String authorCareer;
  String authorAvatarUrl;
  List<String> categories;
  ApplicationStatus status;

  /// Fecha de postulación ya formateada (p. ej. "12 Oct").
  String appliedDate;

  factory AppliedProject.fromJson(Map<String, dynamic> json) => AppliedProject(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] ?? '',
        vision: json['vision'] ?? '',
        authorName: json['authorName'] as String,
        authorCareer: json['authorCareer'] ?? '',
        authorAvatarUrl: json['authorAvatarUrl'] ?? '',
        categories: List<String>.from(json['categories'] ?? []),
        status: ApplicationStatus.fromName(json['status'] as String?),
        appliedDate: json['appliedDate'] ?? '',
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
        'status': status.name,
        'appliedDate': appliedDate,
      };

  @override
  String toString() =>
      'AppliedProject{id: $id, title: $title, status: ${status.name}}';
}
