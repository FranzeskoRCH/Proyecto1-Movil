import 'applicant.dart';

/// Estado de un proyecto publicado por el colaborador.
enum CreatedProjectStatus {
  recruiting('Reclutando'),
  active('Activo'),
  completed('Completado');

  const CreatedProjectStatus(this.label);

  final String label;

  static CreatedProjectStatus fromName(String? value) => values.firstWhere(
        (status) => status.name == value,
        orElse: () => CreatedProjectStatus.recruiting,
      );
}

/// Proyecto publicado por el colaborador actual, con sus postulantes.
class CreatedProject {
  CreatedProject({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.vacancies,
    required this.applicants,
  });

  String id;
  String title;
  String description;
  CreatedProjectStatus status;
  int vacancies;
  List<Applicant> applicants;

  List<Applicant> get pendingApplicants =>
      applicants.where((applicant) => applicant.isPending).toList();

  List<Applicant> get teamMembers =>
      applicants.where((applicant) => applicant.isAccepted).toList();

  factory CreatedProject.fromJson(Map<String, dynamic> json) => CreatedProject(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] ?? '',
        status: CreatedProjectStatus.fromName(json['status'] as String?),
        vacancies: json['vacancies'] as int? ?? 0,
        applicants: (json['applicants'] as List<dynamic>? ?? [])
            .map((applicant) =>
                Applicant.fromJson(applicant as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'status': status.name,
        'vacancies': vacancies,
        'applicants': applicants.map((applicant) => applicant.toJson()).toList(),
      };

  @override
  String toString() =>
      'CreatedProject{id: $id, title: $title, status: ${status.name}}';
}
