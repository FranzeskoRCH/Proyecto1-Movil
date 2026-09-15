import '../../../domain/models/applicant.dart';
import '../../../domain/models/application_status.dart';
import '../../../domain/models/applied_project.dart';
import '../../../domain/models/created_project.dart';
import '../i_project_source.dart';

/// Fuente de datos activa mientras no exista backend.
///
/// Devuelve los proyectos aplicados y creados simulando la respuesta de la API.
/// Mantiene el estado de los postulantes en memoria para que aceptar, rechazar
/// y eliminar se comporten como lo haría el backend. Cuando exista un backend
/// real, esta clase se reemplaza por [RemoteProjectSource] en
/// `project_dependencies.dart`.
class LocalProjectSource implements IProjectSource {
  LocalProjectSource()
      : _appliedProjects =
            _appliedJson.map(AppliedProject.fromJson).toList(growable: true),
        _createdProjects =
            _createdJson.map(CreatedProject.fromJson).toList(growable: true);

  final List<AppliedProject> _appliedProjects;
  final List<CreatedProject> _createdProjects;

  @override
  Future<List<AppliedProject>> getAppliedProjects() async {
    return List<AppliedProject>.unmodifiable(_appliedProjects);
  }

  @override
  Future<List<CreatedProject>> getCreatedProjects() async {
    return List<CreatedProject>.unmodifiable(_createdProjects);
  }

  @override
  Future<CreatedProject> getCreatedProjectById(String id) async {
    return _createdProjects.firstWhere((project) => project.id == id);
  }

  @override
  Future<void> acceptApplicant(String projectId, String applicantId) async {
    _applicant(projectId, applicantId).status = ApplicationStatus.accepted;
  }

  @override
  Future<void> rejectApplicant(String projectId, String applicantId) async {
    _applicant(projectId, applicantId).status = ApplicationStatus.rejected;
  }

  @override
  Future<void> removeMember(String projectId, String applicantId) async {
    _applicant(projectId, applicantId).status = ApplicationStatus.rejected;
  }

  Applicant _applicant(String projectId, String applicantId) {
    final project = _createdProjects.firstWhere(
      (project) => project.id == projectId,
    );
    return project.applicants.firstWhere(
      (applicant) => applicant.id == applicantId,
    );
  }

  // ---------------------------------------------------------------------------
  // Datos mock que retornaría el endpoint.
  // ---------------------------------------------------------------------------
  static const List<Map<String, dynamic>> _appliedJson = [
    {
      'id': 'a1',
      'title': 'EcoCampus Sorter',
      'description':
          'Una estación de clasificación con IA enfocada en plástico y residuos de comercio para maximizar los flujos de reciclaje directo.',
      'vision':
          'El EcoCampus Smart Sorter busca colocar nodos de clasificación con visión por computadora en los principales puntos de comida del campus, reduciendo las tasas de contaminación de residuos.',
      'authorName': 'Kira Vance',
      'authorCareer': 'Ciencias Ambientales',
      'authorAvatarUrl': 'https://i.pravatar.cc/150?img=47',
      'categories': ['Impacto Social', 'Medio Ambiente', 'Tech'],
      'status': 'accepted',
      'appliedDate': '12 Oct',
    },
    {
      'id': 'a2',
      'title': 'MedAlert Smart Watch',
      'description':
          'Monitorea biométricos de baja latencia para detectar emergencias, diseñado específicamente para centros de atención a adultos mayores.',
      'vision':
          'MetaAlert es un reloj inteligente de bajo coste que monitorea signos vitales y detecta caídas o emergencias médicas en adultos mayores.',
      'authorName': 'Marcos Chen',
      'authorCareer': 'Ingeniería Biomédica',
      'authorAvatarUrl': 'https://i.pravatar.cc/150?img=15',
      'categories': ['Salud', 'Tecnología'],
      'status': 'underReview',
      'appliedDate': '10 Oct',
    },
    {
      'id': 'a3',
      'title': 'CiloVia Inteligente',
      'description':
          'Optimización de semáforos y cruces peatonales prioritarios para ciclistas en zonas de alta congestión universitaria.',
      'vision':
          'CiloVia propone una red de cruces inteligentes que prioriza a ciclistas y peatones, sincronizando semáforos en tiempo real para reducir tiempos de espera y accidentes.',
      'authorName': 'Sofía Ruiz',
      'authorCareer': 'Diseño Urbano',
      'authorAvatarUrl': 'https://i.pravatar.cc/150?img=32',
      'categories': ['Movilidad', 'Impacto Social'],
      'status': 'rejected',
      'appliedDate': '05 Oct',
    },
  ];

  static const List<Map<String, dynamic>> _createdJson = [
    {
      'id': 'c1',
      'title': 'UrbanBike Network',
      'description':
          'Red de bicicletas compartidas con estaciones solares en el campus.',
      'status': 'recruiting',
      'vacancies': 3,
      'applicants': [
        {
          'id': 'ap1',
          'name': 'Diego Torres',
          'avatarUrl': 'https://i.pravatar.cc/150?img=11',
          'career': 'Ingeniería de Sistemas',
          'requestedRole': 'Backend',
          'status': 'underReview',
        },
        {
          'id': 'ap2',
          'name': 'Valentina Ríos',
          'avatarUrl': 'https://i.pravatar.cc/150?img=45',
          'career': 'Diseño Gráfico',
          'requestedRole': 'Diseño UI/UX',
          'status': 'accepted',
        },
        {
          'id': 'ap3',
          'name': 'Andrés Molina',
          'avatarUrl': 'https://i.pravatar.cc/150?img=33',
          'career': 'Ingeniería Electrónica',
          'requestedRole': 'IoT',
          'status': 'underReview',
        },
      ],
    },
    {
      'id': 'c2',
      'title': 'GreenMenu',
      'description':
          'Aplicación de menús sostenibles con proveedores locales del campus.',
      'status': 'active',
      'vacancies': 1,
      'applicants': [
        {
          'id': 'ap4',
          'name': 'Camila Pardo',
          'avatarUrl': 'https://i.pravatar.cc/150?img=23',
          'career': 'Nutrición',
          'requestedRole': 'Contenido',
          'status': 'accepted',
        },
      ],
    },
  ];
}
