import 'application_status.dart';

/// Persona que solicitó unirse a uno de tus proyectos.
class Applicant {
  Applicant({
    required this.id,
    this.collaboratorId = '',
    required this.name,
    required this.avatarUrl,
    required this.career,
    required this.requestedRole,
    this.status = ApplicationStatus.underReview,
  });

  /// ID del registro en la tabla application (para update/delete).
  String id;
  /// ID del collaborator (UUID del usuario, para project_member).
  String collaboratorId;
  String name;
  String avatarUrl;
  String career;

  /// Rol al que aspira dentro del proyecto.
  String requestedRole;

  ApplicationStatus status;

  bool get isPending => status == ApplicationStatus.underReview;
  bool get isAccepted => status == ApplicationStatus.accepted;

  factory Applicant.fromJson(Map<String, dynamic> json) => Applicant(
        id: json['id'] as String,
        name: json['name'] as String,
        avatarUrl: json['avatarUrl'] ?? '',
        career: json['career'] ?? '',
        requestedRole: json['requestedRole'] ?? '',
        status: ApplicationStatus.fromName(json['status'] as String?),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'avatarUrl': avatarUrl,
        'career': career,
        'requestedRole': requestedRole,
        'status': status.name,
      };

  @override
  String toString() => 'Applicant{id: $id, name: $name, status: ${status.name}}';
}
