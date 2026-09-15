import '../../../domain/models/collaborator_profile.dart';
import '../../../domain/models/enrolled_project.dart';
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
    return CollaboratorProfile.fromJson(_profileJson);
  }

  @override
  Future<List<EnrolledProject>> getEnrolledProjects() async {
    return _enrolledProjectsJson
        .map(EnrolledProject.fromJson)
        .toList(growable: false);
  }

  // ---------------------------------------------------------------------------
  // Datos mock que retornaría el endpoint.
  // ---------------------------------------------------------------------------
  static const Map<String, dynamic> _profileJson = {
    'name': 'Sarah',
    'avatarUrl': 'https://i.pravatar.cc/150?img=47',
    'career': 'Ciencias de la Computación + Diseño Sostenible',
    'skills': ['React Native', 'Figma', 'Data Analysis'],
    'interests': ['Tecnología', 'Medio Ambiente', 'Arte y Diseño'],
  };

  static const List<Map<String, dynamic>> _enrolledProjectsJson = [
    {
      'id': 'a1',
      'title': 'EcoCampus Sorter',
      'description':
          'Una estación de clasificación con IA enfocada en plástico y residuos de comercio para maximizar los flujos de reciclaje directo.',
      'authorName': 'Kira Vance',
      'authorAvatarUrl': 'https://i.pravatar.cc/150?img=47',
      'role': 'Diseño UI/UX',
    },
    {
      'id': 'a2',
      'title': 'MedAlert Smart Watch',
      'description':
          'Monitorea biométricos de baja latencia para detectar emergencias en centros de atención a adultos mayores.',
      'authorName': 'Marcos Chen',
      'authorAvatarUrl': 'https://i.pravatar.cc/150?img=15',
      'role': 'Investigación Biomédica',
    },
  ];
}
