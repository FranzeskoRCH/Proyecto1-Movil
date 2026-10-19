import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/date_labels.dart';
import '../../../../core/roble_error_handler.dart';
import '../../../../core/widgets/app_confirm_dialog.dart';
import '../../../../core/widgets/section_label.dart';
import '../../../project/ui/widgets/segmented_tabs.dart';
import '../../domain/models/project_event.dart';
import '../../domain/models/project_task.dart';
import '../../domain/models/workspace_member.dart';
import '../viewmodels/workspace_controller.dart';
import '../widgets/calendar_entry_tile.dart';
import '../widgets/month_calendar.dart';
import '../widgets/task_tile.dart';
import '../widgets/workspace_forms.dart';
import '../widgets/workspace_progress_card.dart';

/// Espacio de trabajo de un proyecto en curso: progreso, tareas con
/// deadlines, calendario de fechas importantes y registro de lo completado.
class ProjectWorkspacePage extends StatefulWidget {
  const ProjectWorkspacePage({
    super.key,
    required this.projectId,
    required this.projectTitle,
    required this.isOwner,
  });

  final String projectId;
  final String projectTitle;

  /// El creador puede borrar cualquier tarea o fecha; los demás, las suyas.
  final bool isOwner;

  @override
  State<ProjectWorkspacePage> createState() => _ProjectWorkspacePageState();
}

class _ProjectWorkspacePageState extends State<ProjectWorkspacePage> {
  final WorkspaceController controller = Get.find();

  @override
  void initState() {
    super.initState();
    controller.load(widget.projectId, isOwner: widget.isOwner);
  }

  // ── Acciones ─────────────────────────────────────────────────────────────

  Future<void> _openTaskForm() {
    return showTaskFormSheet(
      context,
      members: controller.members.toList(),
      onSubmit: ({
        required String title,
        required String description,
        WorkspaceMember? assignee,
        DateTime? dueDate,
      }) async {
        final ok = await controller.addTask(
          title: title,
          description: description,
          assignee: assignee,
          dueDate: dueDate,
        );
        if (!ok) _showError('No se pudo crear la tarea');
        return ok;
      },
    );
  }

  Future<void> _openEventForm() {
    return showEventFormSheet(
      context,
      initialDate: controller.selectedDay.value,
      onSubmit: ({
        required String title,
        required String description,
        required DateTime date,
        required ProjectEventKind kind,
      }) async {
        final ok = await controller.addEvent(
          title: title,
          description: description,
          date: date,
          kind: kind,
        );
        if (ok) {
          controller.selectDay(date);
        } else {
          _showError('No se pudo guardar la fecha');
        }
        return ok;
      },
    );
  }

  Future<void> _toggle(ProjectTask task) async {
    final ok = await controller.toggleDone(task);
    if (!ok) _showError('No se pudo actualizar la tarea');
  }

  Future<void> _confirmDeleteTask(ProjectTask task) async {
    final confirmed = await showAppConfirmDialog(
      title: 'Eliminar tarea',
      message: '¿Eliminar "${task.title}"? Esta acción no se puede deshacer.',
      confirmText: 'Sí, eliminar',
      confirmColor: const Color(0xFFD32F2F),
      icon: Icons.delete_outline_rounded,
    );
    if (!confirmed) return;
    final ok = await controller.deleteTask(task);
    if (!ok) _showError('No se pudo eliminar la tarea');
  }

  Future<void> _confirmDeleteEvent(ProjectEvent event) async {
    final confirmed = await showAppConfirmDialog(
      title: 'Eliminar fecha',
      message: '¿Eliminar "${event.title}" del calendario?',
      confirmText: 'Sí, eliminar',
      confirmColor: const Color(0xFFD32F2F),
      icon: Icons.event_busy_outlined,
    );
    if (!confirmed) return;
    final ok = await controller.deleteEvent(event);
    if (!ok) _showError('No se pudo eliminar la fecha');
  }

  void _showError(String title) {
    RobleErrorHandler.showErrorSnackbar(
      title: title,
      error: 'Revisa tu conexión e inténtalo de nuevo.',
    );
  }

  // ── Vista ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Obx(() {
        switch (controller.tab) {
          case WorkspaceTab.tasks:
            return _AddButton(label: 'Nueva tarea', onTap: _openTaskForm);
          case WorkspaceTab.calendar:
            return _AddButton(label: 'Nueva fecha', onTap: _openEventForm);
          case WorkspaceTab.log:
            return const SizedBox.shrink();
        }
      }),
      body: SafeArea(
        child: Obx(() {
          final loadingFirstTime = controller.isLoading &&
              controller.tasks.isEmpty &&
              controller.events.isEmpty;

          return RefreshIndicator(
            color: const Color(0xFFFF7043),
            onRefresh: controller.refreshData,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
              children: [
                _Header(
                  title: widget.projectTitle,
                  members: controller.members.toList(),
                ),
                const SizedBox(height: 20),
                if (loadingFirstTime)
                  const Padding(
                    padding: EdgeInsets.only(top: 80),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFF7043),
                      ),
                    ),
                  )
                else if (controller.error != null)
                  _EmptyState(
                    icon: Icons.cloud_off_outlined,
                    title: controller.error!,
                    message: 'Desliza hacia abajo para volver a intentarlo.',
                  )
                else ...[
                  WorkspaceProgressCard(
                    progress: controller.progress,
                    doneCount: controller.doneCount,
                    totalCount: controller.totalCount,
                    overdueCount: controller.overdueTasks.length,
                    nextDeadline: controller.nextDeadline,
                  ),
                  const SizedBox(height: 22),
                  SegmentedTabs<WorkspaceTab>(
                    segments: const {
                      'Tareas': WorkspaceTab.tasks,
                      'Calendario': WorkspaceTab.calendar,
                      'Registro': WorkspaceTab.log,
                    },
                    selected: controller.tab,
                    onSelected: controller.selectTab,
                  ),
                  const SizedBox(height: 20),
                  ...switch (controller.tab) {
                    WorkspaceTab.tasks => _buildTasks(),
                    WorkspaceTab.calendar => _buildCalendar(),
                    WorkspaceTab.log => _buildLog(),
                  },
                ],
              ],
            ),
          );
        }),
      ),
    );
  }

  List<Widget> _buildTasks() {
    final overdue = controller.overdueTasks;
    final upcoming = controller.upcomingTasks;
    final doneCount = controller.doneCount;

    if (overdue.isEmpty && upcoming.isEmpty) {
      return [
        _EmptyState(
          icon: doneCount > 0
              ? Icons.celebration_outlined
              : Icons.playlist_add_check_rounded,
          title: doneCount > 0
              ? '¡No quedan tareas pendientes!'
              : 'Aún no hay tareas',
          message: doneCount > 0
              ? 'Revisa lo completado en la pestaña Registro.'
              : 'Divide el proyecto en tareas con responsable y fecha '
                  'límite para seguir el avance del equipo.',
        ),
      ];
    }

    return [
      if (overdue.isNotEmpty) ...[
        _SectionHeader(
          label: 'VENCIDAS',
          count: overdue.length,
          color: const Color(0xFFD45A5A),
        ),
        const SizedBox(height: 10),
        for (final task in overdue) ..._taskTile(task),
        const SizedBox(height: 12),
      ],
      if (upcoming.isNotEmpty) ...[
        _SectionHeader(label: 'PENDIENTES', count: upcoming.length),
        const SizedBox(height: 10),
        for (final task in upcoming) ..._taskTile(task),
      ],
      if (doneCount > 0) ...[
        const SizedBox(height: 6),
        Center(
          child: TextButton.icon(
            onPressed: () => controller.selectTab(WorkspaceTab.log),
            icon: const Icon(Icons.history_rounded, size: 18),
            label: Text(
              doneCount == 1
                  ? 'Ver 1 tarea completada'
                  : 'Ver $doneCount tareas completadas',
            ),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFFF7043),
              textStyle: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    ];
  }

  List<Widget> _taskTile(ProjectTask task) => [
        TaskTile(
          task: task,
          onToggle: () => _toggle(task),
          onDelete: controller.canDeleteTask(task)
              ? () => _confirmDeleteTask(task)
              : null,
        ),
        const SizedBox(height: 10),
      ];

  List<Widget> _buildCalendar() {
    final selected = controller.selectedDay.value;
    final dayEntries = controller.entriesFor(selected);
    final upcoming = controller.upcomingEntries();

    return [
      MonthCalendar(
        month: controller.focusedMonth.value,
        selectedDay: selected,
        markersFor: (day) {
          final entries = controller.entriesFor(day);
          return DayMarkers(
            hasEvent: entries.any((e) => !e.isTask),
            hasDeadline: entries.any((e) => e.isTask),
          );
        },
        onDaySelected: controller.selectDay,
        onPreviousMonth: () => controller.changeMonth(-1),
        onNextMonth: () => controller.changeMonth(1),
      ),
      const SizedBox(height: 22),
      SectionLabel(
        DateLabels.isSameDay(selected, DateTime.now())
            ? 'HOY · ${DateLabels.short(selected).toUpperCase()}'
            : DateLabels.short(selected).toUpperCase(),
      ),
      const SizedBox(height: 10),
      if (dayEntries.isEmpty)
        _InlineHint(
          text: 'Nada programado este día.',
          actionLabel: 'Agregar fecha',
          onAction: _openEventForm,
        )
      else
        for (final entry in dayEntries) ..._entryTile(entry),
      const SizedBox(height: 18),
      const SectionLabel('PRÓXIMAS FECHAS'),
      const SizedBox(height: 10),
      if (upcoming.isEmpty)
        const _InlineHint(
          text: 'No hay hitos ni deadlines próximos.',
        )
      else
        for (final entry in upcoming) ..._entryTile(entry, showDate: true),
    ];
  }

  List<Widget> _entryTile(CalendarEntry entry, {bool showDate = false}) {
    final event = entry.event;
    return [
      CalendarEntryTile(
        entry: entry,
        showDate: showDate,
        onDelete: event != null && controller.canDeleteEvent(event)
            ? () => _confirmDeleteEvent(event)
            : null,
      ),
      const SizedBox(height: 8),
    ];
  }

  List<Widget> _buildLog() {
    final log = controller.completedLog;
    if (log.isEmpty) {
      return const [
        _EmptyState(
          icon: Icons.history_rounded,
          title: 'Todavía no hay tareas completadas',
          message: 'Cada tarea que el equipo marque como hecha quedará '
              'registrada aquí, con quién la terminó y cuándo.',
        ),
      ];
    }

    return [
      _SectionHeader(label: 'TAREAS REALIZADAS', count: log.length),
      const SizedBox(height: 14),
      for (int i = 0; i < log.length; i++)
        _LogItem(
          task: log[i],
          isLast: i == log.length - 1,
          onReopen: () => _toggle(log[i]),
        ),
    ];
  }
}

// ── Piezas de la pantalla ───────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.members});

  final String title;
  final List<WorkspaceMember> members;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: Get.back,
          child: Container(
            height: 40,
            width: 40,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back,
              size: 20,
              color: Color(0xFF2B2B2B),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Espacio de trabajo',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF9E9E9E),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF2B2B2B),
                ),
              ),
            ],
          ),
        ),
        if (members.isNotEmpty) _TeamStack(members: members),
      ],
    );
  }
}

/// Avatares superpuestos del equipo.
class _TeamStack extends StatelessWidget {
  const _TeamStack({required this.members});

  final List<WorkspaceMember> members;

  @override
  Widget build(BuildContext context) {
    const int maxShown = 3;
    final shown = members.take(maxShown).toList();
    final extra = members.length - shown.length;
    final count = shown.length + (extra > 0 ? 1 : 0);

    return Tooltip(
      message: members.map((m) => m.name).join(', '),
      child: SizedBox(
        height: 34,
        width: 34.0 + (count - 1) * 22,
        child: Stack(
          children: [
            for (int i = 0; i < shown.length; i++)
              Positioned(
                left: i * 22,
                child: _RingAvatar(url: shown[i].avatarUrl),
              ),
            if (extra > 0)
              Positioned(
                left: shown.length * 22.0,
                child: Container(
                  height: 34,
                  width: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF7043),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Text(
                    '+$extra',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RingAvatar extends StatelessWidget {
  const _RingAvatar({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: CircleAvatar(
        radius: 15,
        backgroundColor: const Color(0xFFEADFD6),
        backgroundImage: url.isEmpty ? null : NetworkImage(url),
        child: url.isEmpty
            ? const Icon(Icons.person, size: 16, color: Color(0xFF9E9E9E))
            : null,
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.label,
    required this.count,
    this.color = const Color(0xFF9E9E9E),
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
            color: color,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

/// Elemento de la línea de tiempo del registro.
class _LogItem extends StatelessWidget {
  const _LogItem({
    required this.task,
    required this.isLast,
    required this.onReopen,
  });

  final ProjectTask task;
  final bool isLast;
  final VoidCallback onReopen;

  @override
  Widget build(BuildContext context) {
    final who = task.completedByName.isEmpty ? 'Alguien' : task.completedByName;
    final when = task.completedAt;
    final due = task.dueDate;
    final lateDays = (when != null && due != null)
        ? DateLabels.dateOnly(when).difference(due).inDays
        : 0;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                height: 28,
                width: 28,
                decoration: const BoxDecoration(
                  color: Color(0xFFE3F5EA),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 16,
                  color: Color(0xFF2E9E5B),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: const Color(0xFFE0D8CF),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: who,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const TextSpan(text: ' completó'),
                        ],
                      ),
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF757575),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      task.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2B2B2B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule_rounded,
                          size: 14,
                          color: Color(0xFF9E9E9E),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            [
                              when == null
                                  ? 'Fecha no registrada'
                                  : DateLabels.shortWithTime(when),
                              if (lateDays > 0)
                                '$lateDays ${lateDays == 1 ? 'día' : 'días'} tarde'
                              else if (due != null && when != null)
                                'a tiempo',
                            ].join(' · '),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: lateDays > 0
                                  ? const Color(0xFFC98A2B)
                                  : const Color(0xFF9E9E9E),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: onReopen,
                          child: const Text(
                            'Reabrir',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFFF7043),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineHint extends StatelessWidget {
  const _InlineHint({required this.text, this.actionLabel, this.onAction});

  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0D8CF), width: 1.2),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)),
            ),
          ),
          if (actionLabel != null && onAction != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                actionLabel!,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFFF7043),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE0D8CF), width: 1.2),
      ),
      child: Column(
        children: [
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFFF7043).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 28, color: const Color(0xFFFF7043)),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2B2B2B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              height: 1.4,
              color: Color(0xFF9E9E9E),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFA741), Color(0xFFFF5252)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(
              color: Color(0x40FF5252),
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add_rounded, color: Colors.white, size: 22),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
