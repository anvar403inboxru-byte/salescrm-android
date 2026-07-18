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

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService.getTasks(status: _status);
      setState(() { _items = data; _loading = false; });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Color _priorityColor(String? p) {
    switch (p) {
      case 'high':   return AppTheme.danger;
      case 'medium': return AppTheme.warning;
      case 'low':    return AppTheme.success;
      default:       return AppTheme.textMuted;
    }
  }

  IconData _statusIcon(String? s) {
    switch (s) {
      case 'done':        return Icons.check_circle;
      case 'in_progress': return Icons.play_circle;
      case 'cancelled':   return Icons.cancel;
      default:            return Icons.radio_button_unchecked;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('✅ Tapşırıqlar')),
      body: Column(children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(children: [
            for (final entry in {
              '': 'Hamısı', 'todo': 'Gözləyir', 'in_progress': 'İcrada',
              'done': 'Tamamlandı', 'cancelled': 'Ləğv edildi',
            }.entries)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(entry.value),
                  selected: _status == entry.key,
                  selectedColor: AppTheme.primary.withOpacity(0.3),
                  onSelected: (_) { setState(() => _status = entry.key); _load(); },
                ),
              ),
          ]),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _load,
                  child: _items.isEmpty
                      ? const Center(child: Text('Tapşırıq tapılmadı', style: TextStyle(color: AppTheme.textMuted)))
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _items.length,
                          itemBuilder: (ctx, i) {
                            final t = _items[i];
                            final priority = t['priority'] as String? ?? 'low';
                            final status = t['status'] as String? ?? 'todo';
                            final isDone = status == 'done';
                            return Card(
                              color: AppTheme.surface,
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: Icon(_statusIcon(status),
                                  color: isDone ? AppTheme.success : AppTheme.primary, size: 28),
                                title: Text(
                                  t['title'] ?? '',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    decoration: isDone ? TextDecoration.lineThrough : null,
                                    color: isDone ? AppTheme.textMuted : AppTheme.textMain,
                                  ),
                                ),
                                subtitle: Text(
                                  '${t['assigned_to_name'] ?? 'Təyin edilməyib'} • ${t['due_date'] ?? ''}',
                                  style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: _priorityColor(priority).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(priority,
                                    style: TextStyle(color: _priorityColor(priority), fontSize: 10, fontWeight: FontWeight.w600)),
                                ),
                              ),
                            );
                          },
                        ),
                ),
        ),
      ]),
    );
  }
}