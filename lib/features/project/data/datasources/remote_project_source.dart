import 'package:http/http.dart' as http;

import '../../domain/models/applied_project.dart';
import '../../domain/models/created_project.dart';
import 'i_project_source.dart';

/// Fuente de datos remota (API real). Aún no implementada.
///
/// Es el punto de integración con el backend: aquí van las llamadas HTTP de
/// "Mis Proyectos" y la gestión de equipos. Se conecta en
/// `project_dependencies.dart` cuando el backend exista, reemplazando a
/// [LocalProjectSource].
class RemoteProjectSource implements IProjectSource {
  RemoteProjectSource(this.httpClient);

  final http.Client httpClient;

  @override
  Future<List<AppliedProject>> getAppliedProjects() async {
    // TODO: implementar la llamada real a la API, p. ej.:
    //   final response = await httpClient.get(Uri.parse('.../projects/applied'));
    //   return (jsonDecode(response.body) as List)
    //       .map((json) => AppliedProject.fromJson(json))
    //       .toList();
    throw UnimplementedError();
  }

  @override
  Future<List<CreatedProject>> getCreatedProjects() async {
    // TODO: implementar la llamada real a la API.
    throw UnimplementedError();
  }

  @override
  Future<CreatedProject> getCreatedProjectById(String id) async {
    // TODO: implementar la llamada real a la API.
    throw UnimplementedError();
  }

  @override
  Future<void> acceptApplicant(String projectId, String applicantId) async {
    // TODO: implementar la llamada real a la API.
    throw UnimplementedError();
  }

  @override
  Future<void> rejectApplicant(String projectId, String applicantId) async {
    // TODO: implementar la llamada real a la API.
    throw UnimplementedError();
  }

  @override
  Future<void> removeMember(String projectId, String applicantId) async {
    // TODO: implementar la llamada real a la API.
    throw UnimplementedError();
  }

  @override
  String toString() => 'RemoteProjectSource(httpClient: $httpClient)';
}
