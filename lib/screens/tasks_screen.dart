import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../core/theme.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});
  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  List<dynamic> _items = [];
  bool _loading = true;
  String _status = '';
  String _priority = '';

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService.getTasks(status: _status, priority: _priority);
      setState(() { _items = data; _loading = false; });
    } catch (_) { setState(() => _loading = false); }
  }

  Color _priorityColor(String p) {
    switch (p) {
      case 'urgent': return AppTheme.danger;
      case 'high':   return AppTheme.warning;
      case 'medium': return AppTheme.info;
      default:       return AppTheme.textMuted;
    }
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'completed': return AppTheme.success;
      case 'in_progress': return AppTheme.info;
      case 'cancelled': return AppTheme.danger;
      default:          return AppTheme.textMuted;
    }
  }

  String _priorityLabel(String p) {
    switch (p) {
      case 'urgent': return 'Təcili';
      case 'high':   return 'Yüksək';
      case 'medium': return 'Orta';
      case 'low':    return 'Aşağı';
      default:       return p;
    }
  }

  String _statusLabel(String s) {
    switch (s) {
      case 'todo':        return 'Gözləyir';
      case 'in_progress': return 'Davam edir';
      case 'completed':   return 'Tamamlandı';
      case 'cancelled':   return 'Ləğv edilib';
      default:            return s;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Tapşırıqlar'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _load)],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(context),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Filterlər
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Row(
              children: [
                for (final s in ['', 'todo', 'in_progress', 'completed'])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(s.isEmpty ? 'Hamısı' : _statusLabel(s)),
                      selected: _status == s,
                      selectedColor: AppTheme.primary.withOpacity(0.2),
                      onSelected: (_) => setState(() { _status = s; _load(); }),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Row(
              children: [
                for (final p in ['', 'urgent', 'high', 'medium', 'low'])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(p.isEmpty ? 'Prioritet' : _priorityLabel(p)),
                      selected: _priority == p,
                      selectedColor: p.isEmpty ? AppTheme.primary.withOpacity(0.2)
                          : _priorityColor(p).withOpacity(0.2),
                      onSelected: (_) => setState(() { _priority = p; _load(); }),
                    ),
                  ),
              ],
            ),
          ),
          // Siyahı
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _items.isEmpty
                    ? Center(child: Text('Tapşırıq yoxdur', style: TextStyle(color: AppTheme.textMuted)))
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                          itemCount: _items.length,
                          itemBuilder: (_, i) => _TaskCard(
                            item: _items[i],
                            priorityColor: _priorityColor,
                            priorityLabel: _priorityLabel,
                            statusColor: _statusColor,
                            statusLabel: _statusLabel,
                            onTap: () => _openForm(context, item: _items[i]),
                            onDelete: () => _delete(_items[i]['id']),
                            onToggle: () => _toggleStatus(_items[i]),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleStatus(Map<String, dynamic> item) async {
    final newStatus = item['status'] == 'completed' ? 'todo' : 'completed';
    try {
      await ApiService.updateTask(item['id'], {'status': newStatus});
      _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Xəta: $e')));
    }
  }

  Future<void> _delete(int id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Silmək istəyirsiniz?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Xeyr')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sil', style: TextStyle(color: AppTheme.danger))),
        ],
      ),
    );
    if (ok == true) {
      try {
        await ApiService.deleteTask(id);
        _load();
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Xəta: $e')));
      }
    }
  }

  void _openForm(BuildContext context, {Map<String, dynamic>? item}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TaskFormScreen(item: item)),
    );
    if (result == true) _load();
  }
}

class _TaskCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final Color Function(String) priorityColor;
  final String Function(String) priorityLabel;
  final Color Function(String) statusColor;
  final String Function(String) statusLabel;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onToggle;

  const _TaskCard({required this.item, required this.priorityColor, required this.priorityLabel,
    required this.statusColor, required this.statusLabel, required this.onTap, required this.onDelete, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final priority = item['priority'] ?? 'low';
    final status   = item['status'] ?? 'todo';
    final isDone   = status == 'completed';
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: onToggle,
                child: Container(
                  width: 24, height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDone ? AppTheme.success.withOpacity(0.15) : Colors.transparent,
                    border: Border.all(color: isDone ? AppTheme.success : AppTheme.border, width: 2),
                  ),
                  child: isDone ? const Icon(Icons.check, size: 14, color: AppTheme.success) : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title'] ?? '',
                      style: TextStyle(
                        color: isDone ? AppTheme.textMuted : AppTheme.textMain,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        decoration: isDone ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    if (item['description'] != null && item['description'].toString().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(item['description'], style: const TextStyle(color: AppTheme.textMuted, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: priorityColor(priority).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(priorityLabel(priority), style: TextStyle(color: priorityColor(priority), fontSize: 10, fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: statusColor(status).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(statusLabel(status), style: TextStyle(color: statusColor(status), fontSize: 10, fontWeight: FontWeight.w600)),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 16, color: AppTheme.danger),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: onDelete,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── FORM ──────────────────────────────────────────────────────────────
class TaskFormScreen extends StatefulWidget {
  final Map<String, dynamic>? item;
  const TaskFormScreen({super.key, this.item});
  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey  = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl  = TextEditingController();
  String _status   = 'todo';
  String _priority = 'medium';
  bool _saving = false;

  bool get _isEdit => widget.item != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _titleCtrl.text = widget.item!['title'] ?? '';
      _descCtrl.text  = widget.item!['description'] ?? '';
      _status         = widget.item!['status'] ?? 'todo';
      _priority       = widget.item!['priority'] ?? 'medium';
    }
  }

  @override
  void dispose() { _titleCtrl.dispose(); _descCtrl.dispose(); super.dispose(); }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final data = {
        'title': _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'status': _status,
        'priority': _priority,
      };
      if (_isEdit) {
        await ApiService.updateTask(widget.item!['id'], data);
      } else {
        await ApiService.createTask(data);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() => _saving = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Xəta: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: Text(_isEdit ? 'Tapşırığı Düzəlt' : 'Yeni Tapşırıq'),
        actions: [
          if (_saving)
            const Padding(padding: EdgeInsets.all(16), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
          else
            TextButton(onPressed: _save, child: const Text('Saxla', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600))),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleCtrl,
              style: const TextStyle(color: AppTheme.textMain),
              decoration: const InputDecoration(labelText: 'Başlıq'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Başlıq daxil edin' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _descCtrl,
              maxLines: 3,
              style: const TextStyle(color: AppTheme.textMain),
              decoration: const InputDecoration(labelText: 'Açıqlama'),
            ),
            const SizedBox(height: 14),
            _dropdown('Status', _status, {'todo': 'Gözləyir', 'in_progress': 'Davam edir', 'completed': 'Tamamlandı', 'cancelled': 'Ləğv edilib'}, (v) => setState(() => _status = v!)),
            const SizedBox(height: 14),
            _dropdown('Prioritet', _priority, {'urgent': 'Təcili', 'high': 'Yüksək', 'medium': 'Orta', 'low': 'Aşağı'}, (v) => setState(() => _priority = v!)),
          ],
        ),
      ),
    );
  }

  Widget _dropdown(String label, String value, Map<String, String> items, void Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(color: AppTheme.surface2, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.border)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: AppTheme.surface,
          style: const TextStyle(color: AppTheme.textMain),
          isExpanded: true,
          items: items.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}