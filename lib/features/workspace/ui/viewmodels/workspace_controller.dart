import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

import '../../../../core/date_labels.dart';
import '../../domain/models/project_event.dart';
import '../../domain/models/project_task.dart';
import '../../domain/models/workspace_member.dart';
import '../../domain/repositories/i_workspace_repository.dart';

/// Elemento del calendario: una fecha importante o el deadline de una tarea.
class CalendarEntry {
  CalendarEntry.event(ProjectEvent this.event)
      : task = null,
        date = event.date,
        title = event.title;

  CalendarEntry.task(ProjectTask this.task)
      : event = null,
        date = task.dueDate!,
        title = task.title;

  final ProjectEvent? event;
  final ProjectTask? task;
  final DateTime date;
  final String title;

  bool get isTask => task != null;
}

/// Pestañas del espacio de trabajo.
enum WorkspaceTab { tasks, calendar, log }

/// Controlador del espacio de trabajo de un proyecto en curso: tareas,
/// deadlines, calendario de fechas importantes y progreso.
class WorkspaceController extends GetxController with UiLoggy {
  WorkspaceController(this.repository);

  final IWorkspaceRepository repository;

  final _projectId = ''.obs;
  final _isOwner = false.obs;
  final _isLoading = false.obs;
  final _error = RxnString();
  final _tab = WorkspaceTab.tasks.obs;

  final RxList<ProjectTask> tasks = <ProjectTask>[].obs;
  final RxList<ProjectEvent> events = <ProjectEvent>[].obs;
  final RxList<WorkspaceMember> members = <WorkspaceMember>[].obs;

  final Rx<DateTime> selectedDay = DateLabels.dateOnly(DateTime.now()).obs;
  final Rx<DateTime> focusedMonth =
      DateTime(DateTime.now().year, DateTime.now().month).obs;

  String get projectId => _projectId.value;
  bool get isOwner => _isOwner.value;
  bool get isLoading => _isLoading.value;
  String? get error => _error.value;
  WorkspaceTab get tab => _tab.value;
  String get currentUserId => repository.currentUserId;

  void selectTab(WorkspaceTab tab) => _tab.value = tab;

  // ── Carga ────────────────────────────────────────────────────────────────

  Future<void> load(String projectId, {required bool isOwner}) async {
    _projectId.value = projectId;
    _isOwner.value = isOwner;
    _tab.value = WorkspaceTab.tasks;
    // El controlador es compartido: limpiar lo del proyecto anterior.
    tasks.clear();
    events.clear();
    members.clear();
    final today = DateLabels.dateOnly(DateTime.now());
    selectedDay.value = today;
    focusedMonth.value = DateTime(today.year, today.month);
    await refreshData();
  }

  Future<void> refreshData() async {
    if (projectId.isEmpty) return;
    _isLoading.value = true;
    _error.value = null;
    try {
      final results = await Future.wait<Object>([
        repository.getTasks(projectId),
        repository.getEvents(projectId),
        repository.getMembers(projectId),
      ]);
      tasks.assignAll(results[0] as List<ProjectTask>);
      events.assignAll(results[1] as List<ProjectEvent>);
      members.assignAll(results[2] as List<WorkspaceMember>);
    } catch (e) {
      loggy.error('WorkspaceController: error al cargar $projectId: $e');
      _error.value = 'No se pudo cargar el espacio de trabajo.';
    } finally {
      _isLoading.value = false;
    }
  }

  // ── Progreso ─────────────────────────────────────────────────────────────

  int get totalCount => tasks.length;
  int get doneCount => tasks.where((t) => t.isDone).length;

  /// Fracción de tareas completadas, entre 0 y 1.
  double get progress => totalCount == 0 ? 0 : doneCount / totalCount;

  List<ProjectTask> get overdueTasks =>
      _sortedByDue(tasks.where((t) => t.isOverdue()));

  /// Pendientes que no están vencidas: primero las de fecha más cercana y al
  /// final las que no tienen fecha.
  List<ProjectTask> get upcomingTasks =>
      _sortedByDue(tasks.where((t) => !t.isDone && !t.isOverdue()));

  /// Próxima fecha límite pendiente (hoy o después).
  ProjectTask? get nextDeadline {
    final withDate = upcomingTasks.where((t) => t.dueDate != null);
    return withDate.isEmpty ? null : withDate.first;
  }

  /// Registro de tareas completadas, de la más reciente a la más antigua.
  List<ProjectTask> get completedLog {
    final done = tasks.where((t) => t.isDone).toList();
    done.sort((a, b) {
      final ad = a.completedAt, bd = b.completedAt;
      if (ad == null && bd == null) return 0;
      if (ad == null) return 1;
      if (bd == null) return -1;
      return bd.compareTo(ad);
    });
    return done;
  }

  List<ProjectTask> _sortedByDue(Iterable<ProjectTask> source) {
    final list = source.toList();
    list.sort((a, b) {
      final ad = a.dueDate, bd = b.dueDate;
      if (ad == null && bd == null) return a.title.compareTo(b.title);
      if (ad == null) return 1;
      if (bd == null) return -1;
      return ad.compareTo(bd);
    });
    return list;
  }

  // ── Calendario ───────────────────────────────────────────────────────────

  /// Fechas importantes y deadlines de un día.
  List<CalendarEntry> entriesFor(DateTime day) => [
        for (final e in events)
          if (DateLabels.isSameDay(e.date, day)) CalendarEntry.event(e),
        for (final t in tasks)
          if (t.dueDate != null && DateLabels.isSameDay(t.dueDate!, day))
            CalendarEntry.task(t),
      ];

  /// Próximas fechas (hoy en adelante): eventos y deadlines pendientes.
  List<CalendarEntry> upcomingEntries({int limit = 5}) {
    final today = DateLabels.dateOnly(DateTime.now());
    final entries = <CalendarEntry>[
      for (final e in events)
        if (!e.date.isBefore(today)) CalendarEntry.event(e),
      for (final t in tasks)
        if (!t.isDone && t.dueDate != null && !t.dueDate!.isBefore(today))
          CalendarEntry.task(t),
    ]..sort((a, b) => a.date.compareTo(b.date));
    return entries.take(limit).toList();
  }

  void selectDay(DateTime day) {
    selectedDay.value = DateLabels.dateOnly(day);
    focusedMonth.value = DateTime(day.year, day.month);
  }

  void changeMonth(int delta) {
    final current = focusedMonth.value;
    focusedMonth.value = DateTime(current.year, current.month + delta);
  }

  // ── Tareas ───────────────────────────────────────────────────────────────

  /// Crea una tarea. Devuelve `true` si se guardó.
  Future<bool> addTask({
    required String title,
    String description = '',
    WorkspaceMember? assignee,
    DateTime? dueDate,
  }) async {
    final trimmed = title.trim();
    if (trimmed.isEmpty || projectId.isEmpty) return false;
    try {
      final created = await repository.createTask(
        ProjectTask(
          projectId: projectId,
          title: trimmed,
          description: description.trim(),
          assigneeId: assignee?.id ?? '',
          assigneeName: assignee?.name ?? '',
          dueDate: dueDate == null ? null : DateLabels.dateOnly(dueDate),
          createdById: currentUserId,
        ),
      );
      tasks.add(created);
      return true;
    } catch (e) {
      loggy.error('WorkspaceController: error al crear tarea: $e');
      return false;
    }
  }

  /// Marca o desmarca una tarea como hecha. Actualiza la vista de inmediato y
  /// la revierte si el servidor falla. Devuelve `true` si se guardó.
  Future<bool> toggleDone(ProjectTask task) async {
    final index = tasks.indexWhere((t) => t.id == task.id);
    if (index < 0) return false;

    final previous = tasks[index];
    final updated = previous.copy()
      ..isDone = !previous.isDone
      ..completedAt = previous.isDone ? null : DateTime.now()
      ..completedByName = previous.isDone ? '' : _currentMemberName;
    tasks[index] = updated;

    try {
      await repository.updateTask(updated);
      return true;
    } catch (e) {
      loggy.error('WorkspaceController: error al actualizar tarea: $e');
      final i = tasks.indexWhere((t) => t.id == task.id);
      if (i >= 0) tasks[i] = previous;
      return false;
    }
  }

  /// El creador del proyecto borra cualquier tarea; los demás, las suyas.
  bool canDeleteTask(ProjectTask task) =>
      isOwner || (task.createdById.isNotEmpty && task.createdById == currentUserId);

  Future<bool> deleteTask(ProjectTask task) async {
    try {
      await repository.deleteTask(task.id);
      tasks.removeWhere((t) => t.id == task.id);
      return true;
    } catch (e) {
      loggy.error('WorkspaceController: error al borrar tarea: $e');
      return false;
    }
  }

  String get _currentMemberName {
    final me = members.firstWhereOrNull((m) => m.id == currentUserId);
    return me?.name ?? repository.currentUserName;
  }

  // ── Fechas importantes ───────────────────────────────────────────────────

  Future<bool> addEvent({
    required String title,
    required DateTime date,
    String description = '',
    ProjectEventKind kind = ProjectEventKind.other,
  }) async {
    final trimmed = title.trim();
    if (trimmed.isEmpty || projectId.isEmpty) return false;
    try {
      final created = await repository.createEvent(
        ProjectEvent(
          projectId: projectId,
          title: trimmed,
          description: description.trim(),
          date: DateLabels.dateOnly(date),
          kind: kind,
          createdById: currentUserId,
        ),
      );
      events.add(created);
      return true;
    } catch (e) {
      loggy.error('WorkspaceController: error al crear fecha: $e');
      return false;
    }
  }

  bool canDeleteEvent(ProjectEvent event) =>
      isOwner ||
      (event.createdById.isNotEmpty && event.createdById == currentUserId);

  Future<bool> deleteEvent(ProjectEvent event) async {
    try {
      await repository.deleteEvent(event.id);
      events.removeWhere((e) => e.id == event.id);
      return true;
    } catch (e) {
      loggy.error('WorkspaceController: error al borrar fecha: $e');
      return false;
    }
  }
}
