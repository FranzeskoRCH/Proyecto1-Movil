import 'package:get/get.dart';

import 'package:movil_proyecto/features/auth/domain/models/user_session.dart';
import 'package:movil_proyecto/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:movil_proyecto/features/auth/ui/viewmodels/auth_controller.dart';
import 'package:movil_proyecto/features/create/domain/repositories/i_create_repository.dart';
import 'package:movil_proyecto/features/create/ui/viewmodels/create_project_controller.dart';
import 'package:movil_proyecto/features/explore/domain/models/project.dart';
import 'package:movil_proyecto/features/explore/domain/repositories/i_explore_repository.dart';
import 'package:movil_proyecto/features/explore/ui/viewmodels/explore_controller.dart';
import 'package:movil_proyecto/features/home/domain/models/collaborator_profile.dart';
import 'package:movil_proyecto/features/home/domain/models/enrolled_project.dart';
import 'package:movil_proyecto/features/home/domain/repositories/i_home_repository.dart';
import 'package:movil_proyecto/features/home/ui/viewmodels/home_controller.dart';
import 'package:movil_proyecto/features/profile/domain/repositories/i_profile_repository.dart';
import 'package:movil_proyecto/features/profile/ui/viewmodels/profile_controller.dart';
import 'package:movil_proyecto/features/project/domain/models/applied_project.dart';
import 'package:movil_proyecto/features/project/domain/models/created_project.dart';
import 'package:movil_proyecto/features/project/domain/repositories/i_project_repository.dart';
import 'package:movil_proyecto/features/project/ui/viewmodels/my_projects_controller.dart';

/// Nombre que devuelven los fakes; las pruebas lo usan para verificar que la
/// navegación llegó a la home autenticada.
const String testUserName = 'Ana Integracion';

class FakeAuthRepository implements IAuthRepository {
  FakeAuthRepository({this.userName = testUserName});

  final String userName;
  UserSession? _user;

  @override
  UserSession? get currentUser => _user;

  @override
  bool get isLoggedIn => _user != null;

  @override
  Future<UserSession> login({
    required String email,
    required String password,
  }) async {
    _user = UserSession(userId: 'user-1', email: email, name: userName);
    return _user!;
  }

  @override
  Future<UserSession> register({
    required String email,
    required String password,
    required String name,
  }) async {
    _user = UserSession(userId: 'user-1', email: email, name: name);
    return _user!;
  }

  @override
  Future<void> logout() async {
    _user = null;
  }

  @override
  Future<bool> restoreSession() async => _user != null;
}

class FakeHomeRepository implements IHomeRepository {
  FakeHomeRepository({required this.profile});

  final CollaboratorProfile profile;

  @override
  Future<CollaboratorProfile> getCollaboratorProfile() async => profile;

  @override
  Future<List<EnrolledProject>> getEnrolledProjects() async => [];

  @override
  Future<void> leaveProject(String projectId) async {}
}

/// Fuente de proyectos en memoria. [FakeCreateRepository] agrega aquí el
/// proyecto creado, de modo que la lista de "Mis Proyectos" lo refleje.
class FakeProjectRepository implements IProjectRepository {
  FakeProjectRepository({List<CreatedProject>? createdProjects})
      : createdProjects = createdProjects ?? [];

  final List<CreatedProject> createdProjects;
  final List<AppliedProject> appliedProjects = [];

  @override
  Future<List<AppliedProject>> getAppliedProjects() async =>
      List.of(appliedProjects);

  @override
  Future<List<CreatedProject>> getCreatedProjects() async =>
      List.of(createdProjects);

  @override
  Future<CreatedProject> getCreatedProjectById(String id) async =>
      createdProjects.firstWhere((project) => project.id == id);

  @override
  Future<void> acceptApplicant(String projectId, String applicantId) async {}

  @override
  Future<void> rejectApplicant(String projectId, String applicantId) async {}

  @override
  Future<void> removeMember(String projectId, String applicantId) async {}

  @override
  Future<void> withdrawApplication(String applicationId) async {}

  @override
  Future<void> updateProject({
    required String projectId,
    required String title,
    required String description,
    required String vision,
    required int vacancies,
    required CreatedProjectStatus status,
    required List<String> categories,
    required List<String> roles,
    String? imageUrl,
  }) async {}

  @override
  Future<void> deleteProject(String projectId) async {}
}

class FakeCreateRepository implements ICreateRepository {
  FakeCreateRepository(this.projects);

  final FakeProjectRepository projects;
  bool created = false;

  @override
  Future<String> createProject({
    required String title,
    required String description,
    required String vision,
    required List<String> categories,
    required List<String> roles,
    required int vacancies,
    String? imageUrl,
  }) async {
    created = true;
    final id = 'created-${projects.createdProjects.length + 1}';
    projects.createdProjects.add(
      CreatedProject(
        id: id,
        title: title,
        description: description,
        vision: vision,
        categories: categories,
        roles: roles,
        vacancies: vacancies,
        status: CreatedProjectStatus.recruiting,
        applicants: const [],
      ),
    );
    return id;
  }
}

class FakeExploreRepository implements IExploreRepository {
  @override
  Future<List<String>> getCategories() async => ['Para Ti', 'Tech'];

  @override
  Future<List<Project>> getProjects({
    String? category,
    String? search,
    int limit = 20,
    int offset = 0,
  }) async =>
      [];

  @override
  Future<Project> getProjectById(String id) async =>
      throw UnimplementedError('FakeExploreRepository.getProjectById');

  @override
  Future<void> requestToJoin(String projectId, {String? role}) async {}

  @override
  Future<void> cancelRequest(String projectId) async {}
}

class FakeProfileRepository implements IProfileRepository {
  FakeProfileRepository({required this.profile});

  final CollaboratorProfile profile;

  @override
  Future<CollaboratorProfile> getProfile() async => profile;

  @override
  Future<CollaboratorProfile> getCollaborator(String userId) async => profile;

  @override
  Future<void> updateProfile({
    required String name,
    required String career,
    required String avatarUrl,
  }) async {}

  @override
  Future<void> addSkill(String skill) async {}

  @override
  Future<void> removeSkill(String skill) async {}

  @override
  Future<void> addInterest(String interest) async {}

  @override
  Future<void> removeInterest(String interest) async {}

  @override
  Future<Map<String, int>> getStats() async =>
      {'created': 0, 'member': 0, 'applied': 0};

  @override
  Future<Map<String, int>> getStatsFor(String userId) async => getStats();
}

/// Conjunto de dependencias falsas de todas las features. Registrarlas en GetX
/// permite montar [MainShell] sin tocar Roble ni la red.
class TestDependencies {
  TestDependencies({List<CreatedProject>? createdProjects})
      : auth = FakeAuthRepository(),
        projectRepository =
            FakeProjectRepository(createdProjects: createdProjects),
        profile = CollaboratorProfile(
          name: testUserName,
          avatarUrl: '',
          career: 'Ingenieria de Sistemas',
          skills: const ['Flutter'],
          interests: const ['Tech'],
        ) {
    createRepository = FakeCreateRepository(projectRepository);
  }

  final FakeAuthRepository auth;
  final FakeProjectRepository projectRepository;
  final CollaboratorProfile profile;
  late final FakeCreateRepository createRepository;

  void register() {
    Get.put<AuthController>(AuthController(auth));
    Get.put<HomeController>(
        HomeController(FakeHomeRepository(profile: profile)));
    Get.put<MyProjectsController>(MyProjectsController(projectRepository));
    Get.put<ExploreController>(ExploreController(FakeExploreRepository()));
    Get.put<CreateProjectController>(
      CreateProjectController(createRepository),
    );
    Get.put<ProfileController>(
        ProfileController(FakeProfileRepository(profile: profile)));
  }
}
