/// Estado de una postulación, tanto de los proyectos a los que aplicaste como
/// de los postulantes que recibieron tus proyectos.
enum ApplicationStatus {
  underReview('En revisión'),
  accepted('Aceptado'),
  rejected('Rechazado');

  const ApplicationStatus(this.label);

  final String label;

  static ApplicationStatus fromName(String? value) => values.firstWhere(
        (status) => status.name == value,
        orElse: () => ApplicationStatus.underReview,
      );
}
