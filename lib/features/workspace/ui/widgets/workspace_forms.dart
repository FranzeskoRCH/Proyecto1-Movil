import 'package:flutter/material.dart';

import '../../../../core/date_labels.dart';
import '../../domain/models/project_event.dart';
import '../../domain/models/workspace_member.dart';

/// Abre el formulario de nueva tarea. [onSubmit] guarda y devuelve `true` si
/// salió bien; entonces la hoja se cierra.
Future<void> showTaskFormSheet(
  BuildContext context, {
  required List<WorkspaceMember> members,
  required Future<bool> Function({
    required String title,
    required String description,
    WorkspaceMember? assignee,
    DateTime? dueDate,
  }) onSubmit,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _TaskForm(members: members, onSubmit: onSubmit),
  );
}

/// Abre el formulario de nueva fecha importante.
Future<void> showEventFormSheet(
  BuildContext context, {
  required DateTime initialDate,
  required Future<bool> Function({
    required String title,
    required String description,
    required DateTime date,
    required ProjectEventKind kind,
  }) onSubmit,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _EventForm(initialDate: initialDate, onSubmit: onSubmit),
  );
}

// ── Tarea ──────────────────────────────────────────────────────────────────

class _TaskForm extends StatefulWidget {
  const _TaskForm({required this.members, required this.onSubmit});

  final List<WorkspaceMember> members;
  final Future<bool> Function({
    required String title,
    required String description,
    WorkspaceMember? assignee,
    DateTime? dueDate,
  }) onSubmit;

  @override
  State<_TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<_TaskForm> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  WorkspaceMember? _assignee;
  DateTime? _dueDate;
  bool _saving = false;
  bool _showTitleError = false;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_title.text.trim().isEmpty) {
      setState(() => _showTitleError = true);
      return;
    }
    setState(() => _saving = true);
    final ok = await widget.onSubmit(
      title: _title.text,
      description: _description.text,
      assignee: _assignee,
      dueDate: _dueDate,
    );
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
    } else {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SheetFrame(
      title: 'Nueva tarea',
      icon: Icons.add_task_rounded,
      children: [
        TextField(
          controller: _title,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: _inputDecoration(
            label: 'Título *',
            hint: 'Ej. Diseñar el prototipo en Figma',
            icon: Icons.task_alt_rounded,
          ).copyWith(
            errorText: _showTitleError ? 'Escribe un título' : null,
          ),
          onChanged: (_) {
            if (_showTitleError) setState(() => _showTitleError = false);
          },
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _description,
          maxLines: 2,
          textCapitalization: TextCapitalization.sentences,
          decoration: _inputDecoration(
            label: 'Descripción',
            hint: 'Detalles, enlaces o criterios de terminado',
            icon: Icons.notes_outlined,
          ),
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<WorkspaceMember?>(
          initialValue: _assignee,
          isExpanded: true,
          decoration: _inputDecoration(
            label: 'Responsable',
            hint: 'Sin asignar',
            icon: Icons.person_outline,
          ),
          items: [
            const DropdownMenuItem<WorkspaceMember?>(
              value: null,
              child: Text('Sin asignar'),
            ),
            for (final member in widget.members)
              DropdownMenuItem<WorkspaceMember?>(
                value: member,
                child: Text(
                  member.role.isEmpty
                      ? member.name
                      : '${member.name} · ${member.role}',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
          onChanged: (value) => setState(() => _assignee = value),
        ),
        const SizedBox(height: 14),
        _DateField(
          label: 'Fecha límite',
          value: _dueDate,
          onChanged: (date) => setState(() => _dueDate = date),
          allowClear: true,
        ),
        const SizedBox(height: 24),
        _GradientButton(
          label: 'Crear tarea',
          icon: Icons.check_rounded,
          loading: _saving,
          onTap: _save,
        ),
      ],
    );
  }
}

// ── Fecha importante ───────────────────────────────────────────────────────

class _EventForm extends StatefulWidget {
  const _EventForm({required this.initialDate, required this.onSubmit});

  final DateTime initialDate;
  final Future<bool> Function({
    required String title,
    required String description,
    required DateTime date,
    required ProjectEventKind kind,
  }) onSubmit;

  @override
  State<_EventForm> createState() => _EventFormState();
}

class _EventFormState extends State<_EventForm> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  late DateTime _date = widget.initialDate;
  ProjectEventKind _kind = ProjectEventKind.milestone;
  bool _saving = false;
  bool _showTitleError = false;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_title.text.trim().isEmpty) {
      setState(() => _showTitleError = true);
      return;
    }
    setState(() => _saving = true);
    final ok = await widget.onSubmit(
      title: _title.text,
      description: _description.text,
      date: _date,
      kind: _kind,
    );
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
    } else {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SheetFrame(
      title: 'Nueva fecha importante',
      icon: Icons.event_available_rounded,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final kind in ProjectEventKind.values)
              _KindChip(
                label: kind.label,
                selected: kind == _kind,
                onTap: () => setState(() => _kind = kind),
              ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _title,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: _inputDecoration(
            label: 'Título *',
            hint: 'Ej. Entrega del MVP',
            icon: Icons.flag_outlined,
          ).copyWith(
            errorText: _showTitleError ? 'Escribe un título' : null,
          ),
          onChanged: (_) {
            if (_showTitleError) setState(() => _showTitleError = false);
          },
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _description,
          textCapitalization: TextCapitalization.sentences,
          decoration: _inputDecoration(
            label: 'Nota',
            hint: 'Ej. Presentación en el aula 3-201',
            icon: Icons.notes_outlined,
          ),
        ),
        const SizedBox(height: 14),
        _DateField(
          label: 'Fecha',
          value: _date,
          onChanged: (date) {
            if (date != null) setState(() => _date = date);
          },
        ),
        const SizedBox(height: 24),
        _GradientButton(
          label: 'Guardar fecha',
          icon: Icons.check_rounded,
          loading: _saving,
          onTap: _save,
        ),
      ],
    );
  }
}

// ── Piezas compartidas ─────────────────────────────────────────────────────

class _SheetFrame extends StatelessWidget {
  const _SheetFrame({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    height: 4,
                    width: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0D8CF),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF7043).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: const Color(0xFFFF7043)),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2B2B2B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ...children,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onChanged,
    this.allowClear = false,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  final bool allowClear;

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: value ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 3),
      helpText: label.toUpperCase(),
      cancelText: 'Cancelar',
      confirmText: 'Listo',
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final date = value;
    return GestureDetector(
      onTap: () => _pick(context),
      child: InputDecorator(
        decoration: _inputDecoration(
          label: label,
          hint: 'Sin fecha',
          icon: Icons.event_outlined,
        ).copyWith(
          suffixIcon: allowClear && date != null
              ? IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  tooltip: 'Quitar fecha',
                  onPressed: () => onChanged(null),
                )
              : const Icon(Icons.expand_more, color: Color(0xFF9E9E9E)),
        ),
        isEmpty: date == null,
        child: date == null
            ? null
            : Text(
                '${DateLabels.short(date)} ${date.year} · '
                '${DateLabels.relative(date)}',
                style: const TextStyle(fontSize: 15),
              ),
      ),
    );
  }
}

class _KindChip extends StatelessWidget {
  const _KindChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFFF7043).withValues(alpha: 0.12)
              : const Color(0xFFF8F2EC),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? const Color(0xFFFF7043) : const Color(0xFFE0D8CF),
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? const Color(0xFFFF7043) : const Color(0xFF4A4A4A),
          ),
        ),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({
    required this.label,
    required this.icon,
    required this.loading,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFA741), Color(0xFFFF5252)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33FF5252),
              blurRadius: 14,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: loading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 20, color: Colors.white),
                  const SizedBox(width: 8),
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

InputDecoration _inputDecoration({
  required String label,
  required String hint,
  required IconData icon,
}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    prefixIcon: Icon(icon, color: const Color(0xFFFF7043), size: 20),
    labelStyle: const TextStyle(color: Color(0xFF757575), fontSize: 14),
    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
    filled: true,
    fillColor: const Color(0xFFFAFAFA),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: Colors.grey.shade200),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: Colors.grey.shade200),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFFF7043), width: 1.5),
    ),
  );
}
