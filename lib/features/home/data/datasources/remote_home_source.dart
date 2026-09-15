import 'package:http/http.dart' as http;

import '../../domain/models/collaborator_profile.dart';
import '../../domain/models/enrolled_project.dart';
import 'i_home_source.dart';

/// Fuente de datos remota (API real). Aún no implementada.
///
/// Es el punto de integración con el backend: aquí van las llamadas HTTP que
/// devuelven el perfil y los proyectos en los que participa el colaborador. Se
/// conecta en `home_dependencies.dart` cuando el backend exista, reemplazando a
/// [LocalHomeSource].
class RemoteHomeSource implements IHomeSource {
  RemoteHomeSource(this.httpClient);

  final http.Client httpClient;

  @override
  Future<CollaboratorProfile> getCollaboratorProfile() async {
    // TODO: implementar la llamada real a la API, p. ej.:
    //   final response = await httpClient.get(Uri.parse('.../home/profile'));
    //   return CollaboratorProfile.fromJson(jsonDecode(response.body));
    throw UnimplementedError();
  }

  @override
  Future<List<EnrolledProject>> getEnrolledProjects() async {
    // TODO: implementar la llamada real a la API, p. ej.:
    //   final response = await httpClient.get(Uri.parse('.../home/projects'));
    //   return (jsonDecode(response.body) as List)
    //       .map((json) => EnrolledProject.fromJson(json))
    //       .toList();
    throw UnimplementedError();
  }

  @override
  String toString() => 'RemoteHomeSource(httpClient: $httpClient)';
}
