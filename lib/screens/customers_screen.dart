import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/api_service.dart';
import '../core/theme.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  List<dynamic> _items = [];
  bool _loading = true;
  String _search = '';
  String _status = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService.getCustomers(search: _search, status: _status);
      setState(() { _items = data; _loading = false; });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('👥 Müştərilər'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Axtarış...',
                prefixIcon: Icon(Icons.search, size: 20),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
              onChanged: (v) {
                _search = v;
                _load();
              },
            ),
          ),
        ),
      ),
      body: Column(children: [
        // Status filter
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(children: [
            for (final s in ['', 'lead', 'prospect', 'active', 'inactive'])
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(_statusLabel(s)),
                  selected: _status == s,
                  selectedColor: AppTheme.primary.withOpacity(0.3),
                  onSelected: (_) { setState(() => _status = s); _load(); },
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
                      ? const Center(child: Text('Müştəri tapılmadı', style: TextStyle(color: AppTheme.textMuted)))
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _items.length,
                          itemBuilder: (ctx, i) => _CustomerTile(
                            c: _items[i],
                            onTap: () => ctx.push('/customers/${_items[i]['id']}'),
                          ),
                        ),
                ),
        ),
      ]),
    );
  }

  String _statusLabel(String s) {
    switch (s) {
      case '': return 'Hamısı';
      case 'lead': return 'Lead';
      case 'prospect': return 'Prospect';
      case 'active': return 'Aktiv';
      case 'inactive': return 'Passiv';
      default: return s;
    }
  }
}

class _CustomerTile extends StatelessWidget {
  final Map<String, dynamic> c;
  final VoidCallback onTap;
  const _CustomerTile({required this.c, required this.onTap});

  Color _statusColor(String? s) {
    switch (s) {
      case 'active':   return AppTheme.success;
      case 'lead':     return AppTheme.primary;
      case 'prospect': return AppTheme.warning;
      default:         return AppTheme.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = c['status'] as String? ?? '';
    return Card(
      color: AppTheme.surface,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: AppTheme.primary.withOpacity(0.2),
          child: Text(
            (c['name'] as String? ?? '?')[0].toUpperCase(),
            style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700),
          ),
        ),
        title: Text(c['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(c['company'] ?? c['email'] ?? '', style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _statusColor(status).withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(status, style: TextStyle(color: _statusColor(status), fontSize: 11, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 4),
            const Icon(Icons.chevron_right, color: AppTheme.textMuted, size: 16),
          ],
        ),
      ),
    );
  }
}