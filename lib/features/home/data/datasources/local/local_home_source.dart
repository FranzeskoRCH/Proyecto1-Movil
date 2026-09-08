import '../../../domain/models/collaborator_profile.dart';
import '../i_home_source.dart';

/// Fuente de datos activa mientras no exista backend.
///
/// Devuelve datos simulando la respuesta de la API. Cuando llegue el momento
/// de consumir el backend, esta clase se reemplaza por [RemoteHomeSource]
/// en `home_dependencies.dart` sin tocar el resto de la aplicación.
class LocalHomeSource implements IHomeSource {
  const LocalHomeSource();

  @override
  Future<CollaboratorProfile> getCollaboratorProfile() async {
    // Simula la latencia de una petición real.
    await Future.delayed(const Duration(milliseconds: 600));
    return CollaboratorProfile.fromJson(_profileJson);
  }

  // ---------------------------------------------------------------------------
  // Datos mock que retornaría el endpoint.
  // ---------------------------------------------------------------------------
  static const Map<String, dynamic> _profileJson = {
    'name': 'Sarah',
    'avatarUrl': 'https://i.pravatar.cc/150?img=47',
    'career': 'Ciencias de la Computación + Diseño Sostenible',
    'skills': ['React Native', 'Figma', 'Data Analysis', 'Figma', 'Figma', 'Figma', 'Figma'],
    'interests': ['Tecnología', 'Medio Ambiente', 'Arte y Diseño', 'Figma', 'Figma', 'Figma'],
  };
}
