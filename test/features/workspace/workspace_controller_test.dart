import 'package:flutter_test/flutter_test.dart';
import 'package:movil_proyecto/core/date_labels.dart';
import 'package:movil_proyecto/features/workspace/domain/models/project_event.dart';
import 'package:movil_proyecto/features/workspace/domain/models/project_task.dart';
import 'package:movil_proyecto/features/workspace/domain/models/workspace_member.dart';
import 'package:movil_proyecto/features/workspace/domain/repositories/i_workspace_repository.dart';
import 'package:movil_proyecto/features/workspace/ui/viewmodels/workspace_controller.dart';

/// Repositorio en memoria. [failWrites] simula que el servidor rechaza los
/// cambios.
class FakeWorkspaceRepository implements IWorkspaceRepository {
  final List<ProjectTask> tasks = [];
  final List<ProjectEvent> events = [];
  final List<WorkspaceMember> members = [
    WorkspaceMember(id: 'owner', name: 'Laura', isOwner: true),
    WorkspaceMember(id: 'u2', name: 'Andrés'),
  ];
  bool failWrites = false;
  int _nextId = 1;

  @override
  String currentUserId = 'u2';

  @override
  String get currentUserName => 'Andrés';

  @override
  Future<List<ProjectTask>> getTasks(String projectId) async =>
      tasks.where((t) => t.projectId == projectId).toList();

  @override
  Future<ProjectTask> createTask(ProjectTask task) async {
    if (failWrites) throw Exception('sin conexión');
    final saved = task.copy()..id = 't${_nextId++}';
    tasks.add(saved);
    return saved;
  }

  @override
  Future<void> updateTask(ProjectTask task) async {
    if (failWrites) throw Exception('sin conexión');
  }

  @override
  Future<void> deleteTask(String taskId) async {
    if (failWrites) throw Exception('sin conexión');
    tasks.removeWhere((t) => t.id == taskId);
  }

  @override
  Future<List<ProjectEvent>> getEvents(String projectId) async =>
      events.where((e) => e.projectId == projectId).toList();

  @override
  Future<ProjectEvent> createEvent(ProjectEvent event) async {
    if (failWrites) throw Exception('sin conexión');
    event.id = 'e${_nextId++}';
    events.add(event);
    return event;
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    events.removeWhere((e) => e.id == eventId);
  }

  @override
  Future<List<WorkspaceMember>> getMembers(String projectId) async => members;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeWorkspaceRepository repo;
  late WorkspaceController controller;
  final today = DateLabels.dateOnly(DateTime.now());

  ProjectTask task(
    String id,
    String title, {
    int? dueInDays,
    bool done = false,
    String createdBy = 'owner',
  }) =>
      ProjectTask(
        id: id,
        projectId: 'p1',
        title: title,
        dueDate: dueInDays == null ? null : today.add(Duration(days: dueInDays)),
        isDone: done,
        completedAt: done ? DateTime.now() : null,
        createdById: createdBy,
      );

  setUp(() {
    repo = FakeWorkspaceRepository();
    controller = WorkspaceController(repo);
  });

  test('el progreso es la fracción de tareas completadas', () async {
    repo.tasks.addAll([
      task('1', 'A', done: true),
      task('2', 'B'),
      task('3', 'C'),
      task('4', 'D', done: true),
    ]);
    await controller.load('p1', isOwner: true);

    expect(controller.totalCount, 4);
    expect(controller.doneCount, 2);
    expect(controller.progress, 0.5);
  });

  test('sin tareas el progreso es 0 y no divide por cero', () async {
    await controller.load('p1', isOwner: true);
    expect(controller.progress, 0);
  });

  test('separa vencidas de pendientes y ordena por fecha límite', () async {
    repo.tasks.addAll([
      task('1', 'Sin fecha'),
      task('2', 'En 5 días', dueInDays: 5),
      task('3', 'Vencida', dueInDays: -2),
      task('4', 'Mañana', dueInDays: 1),
      task('5', 'Hecha y vieja', dueInDays: -10, done: true),
    ]);
    await controller.load('p1', isOwner: true);

    expect(controller.overdueTasks.map((t) => t.title), ['Vencida']);
    expect(
      controller.upcomingTasks.map((t) => t.title),
      ['Mañana', 'En 5 días', 'Sin fecha'],
    );
    expect(controller.nextDeadline?.title, 'Mañana');
  });

  test('completar una tarea registra quién y cuándo', () async {
    repo.tasks.add(task('1', 'Prototipo'));
    await controller.load('p1', isOwner: false);

    final ok = await controller.toggleDone(controller.tasks.first);

    expect(ok, isTrue);
    final done = controller.tasks.first;
    expect(done.isDone, isTrue);
    expect(done.completedByName, 'Andrés');
    expect(done.completedAt, isNotNull);
    expect(controller.completedLog.single.title, 'Prototipo');
  });

  test('reabrir una tarea limpia el registro de completado', () async {
    repo.tasks.add(task('1', 'Prototipo', done: true));
    await controller.load('p1', isOwner: false);

    await controller.toggleDone(controller.tasks.first);

    expect(controller.tasks.first.isDone, isFalse);
    expect(controller.tasks.first.completedAt, isNull);
    expect(controller.completedLog, isEmpty);
  });

  test('si el servidor falla, la tarea vuelve a su estado anterior', () async {
    repo.tasks.add(task('1', 'Prototipo'));
    await controller.load('p1', isOwner: false);
    repo.failWrites = true;

    final ok = await controller.toggleDone(controller.tasks.first);

    expect(ok, isFalse);
    expect(controller.tasks.first.isDone, isFalse);
  });

  test('crear una tarea la agrega con su responsable', () async {
    await controller.load('p1', isOwner: true);

    final ok = await controller.addTask(
      title: '  Diseñar logo  ',
      assignee: repo.members.last,
      dueDate: today.add(const Duration(days: 3)),
    );

    expect(ok, isTrue);
    final created = controller.tasks.single;
    expect(created.title, 'Diseñar logo');
    expect(created.assigneeName, 'Andrés');
    expect(created.createdById, 'u2');
  });

  test('no crea tareas con título vacío', () async {
    await controller.load('p1', isOwner: true);
    expect(await controller.addTask(title: '   '), isFalse);
    expect(controller.tasks, isEmpty);
  });

  test('solo el creador del proyecto o el autor borran una tarea', () async {
    repo.tasks.addAll([
      task('1', 'Del líder', createdBy: 'owner'),
      task('2', 'Mía', createdBy: 'u2'),
    ]);

    await controller.load('p1', isOwner: false);
    expect(controller.canDeleteTask(controller.tasks[0]), isFalse);
    expect(controller.canDeleteTask(controller.tasks[1]), isTrue);

    await controller.load('p1', isOwner: true);
    expect(controller.canDeleteTask(controller.tasks[0]), isTrue);
  });

  test('el calendario junta fechas importantes y deadlines del día', () async {
    final day = today.add(const Duration(days: 4));
    repo.tasks.add(task('1', 'Entregar informe', dueInDays: 4));
    repo.events.add(
      ProjectEvent(
        id: 'e1',
        projectId: 'p1',
        title: 'Demo con el profesor',
        date: day,
        kind: ProjectEventKind.meeting,
      ),
    );
    await controller.load('p1', isOwner: true);

    final entries = controller.entriesFor(day);
    expect(entries.length, 2);
    expect(entries.where((e) => e.isTask).single.title, 'Entregar informe');
    expect(entries.where((e) => !e.isTask).single.title, 'Demo con el profesor');
    expect(controller.entriesFor(today), isEmpty);
  });

  test('próximas fechas excluye lo pasado y lo ya completado', () async {
    repo.tasks.addAll([
      task('1', 'Pasada', dueInDays: -1),
      task('2', 'Hecha', dueInDays: 2, done: true),
      task('3', 'Próxima', dueInDays: 2),
    ]);
    repo.events.add(
      ProjectEvent(
        id: 'e1',
        projectId: 'p1',
        title: 'Hito',
        date: today.add(const Duration(days: 1)),
      ),
    );
    await controller.load('p1', isOwner: true);

    expect(
      controller.upcomingEntries().map((e) => e.title),
      ['Hito', 'Próxima'],
    );
  });

  test('cambiar de proyecto limpia los datos del anterior', () async {
    repo.tasks.add(task('1', 'Del p1'));
    await controller.load('p1', isOwner: true);
    expect(controller.tasks, isNotEmpty);

    await controller.load('p2', isOwner: true);
    expect(controller.tasks, isEmpty);
  });

  group('ProjectTask JSON', () {
    test('lee fechas date sin correrlas por zona horaria', () {
      final parsed = ProjectTask.fromJson({
        '_id': 'abc',
        'project_id': 'p1',
        'title': 'X',
        'due_date': '2026-10-24',
        'status': 'done',
      });
      expect(parsed.dueDate, DateTime(2026, 10, 24));
      expect(parsed.isDone, isTrue);
      expect(parsed.toJson()['due_date'], '2026-10-24');
    });

    test('no manda ids vacíos a columnas uuid', () {
      final json = ProjectTask(projectId: 'p1', title: 'X').toJson();
      expect(json['assignee_id'], isNull);
      expect(json['created_by'], isNull);
      expect(json['status'], 'todo');
    });
  });
}
