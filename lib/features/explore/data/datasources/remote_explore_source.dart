import 'package:http/http.dart' as http;

import '../../domain/models/project.dart';
import 'i_explore_source.dart';

/// Fuente de datos remota (API real). Aún no implementada.
///
/// Es el punto de integración con el backend: aquí van las llamadas HTTP que
/// devuelven la lista, el detalle y el estado de las solicitudes. Se conecta en
/// `explore_dependencies.dart` cuando el backend exista, reemplazando a
/// [LocalExploreSource].
class RemoteExploreSource implements IExploreSource {
  RemoteExploreSource(this.httpClient);

  final http.Client httpClient;

  @override
  Future<List<String>> getCategories() async {
    // TODO: implementar la llamada real a la API, p. ej.:
    //   final response = await httpClient.get(Uri.parse('.../explore/categories'));
    //   return List<String>.from(jsonDecode(response.body));
    throw UnimplementedError();
  }

  @override
  Future<List<Project>> getProjects({String? category}) async {
    // TODO: implementar la llamada real a la API, p. ej.:
    //   final response = await httpClient.get(
    //     Uri.parse('.../explore/projects?category=$category'),
    //   );
    //   return (jsonDecode(response.body) as List)
    //       .map((json) => Project.fromJson(json))
    //       .toList();
    throw UnimplementedError();
  }

  @override
  Future<Project> getProjectById(String id) async {
    // TODO: implementar la llamada real a la API.
    throw UnimplementedError();
  }

  @override
  Future<void> requestToJoin(String projectId) async {
    // TODO: implementar la llamada real a la API.
    throw UnimplementedError();
  }

  @override
  Future<void> cancelRequest(String projectId) async {
    // TODO: implementar la llamada real a la API.
    throw UnimplementedError();
  }

  @override
  String toString() => 'RemoteExploreSource(httpClient: $httpClient)';
}
