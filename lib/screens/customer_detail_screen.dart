import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../core/theme.dart';
import 'customers_screen.dart' show CustomerFormScreen;
import 'quotations_screen.dart' show QuotationFormScreen;
import 'tasks_screen.dart' show TaskFormScreen;
import 'contacts_screen.dart' show ContactFormScreen;

class CustomerDetailScreen extends StatefulWidget {
  final int id;
  const CustomerDetailScreen({super.key, required this.id});
  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? _c;
  List<dynamic> _contacts = [];
  List<dynamic> _quotations = [];
  List<dynamic> _tasks = [];
  bool _loading = true;
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
    _load();
  }

  @override
  void dispose() { _tabs.dispose(); super.dispose(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        ApiService.getCustomer(widget.id),
        ApiService.getContacts(customerId: widget.id),
        ApiService.getQuotations(),
        ApiService.getTasks(),
      ]);
      final allQuots = results[2] as List;
      final allTasks = results[3] as List;
      setState(() {
        _c         = results[0] as Map<String, dynamic>;
        _contacts  = results[1] as List;
        _quotations = allQuots.where((q) => q['customer_id'] == widget.id).toList();
        _tasks      = allTasks.where((t) => t['customer_id'] == widget.id).toList();
        _loading   = false;
      });
    } catch (_) { setState(() => _loading = false); }
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'active':   return AppTheme.success;
      case 'lead':     return AppTheme.primary;
      case 'prospect': return AppTheme.warning;
      case 'inactive': return AppTheme.textMuted;
      default:         return AppTheme.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: Text(_c?['name'] ?? 'Müştəri'),
        actions: [
          if (_c != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () async {
                final r = await Navigator.push(context,
                  MaterialPageRoute(builder: (_) => CustomerFormScreen(item: _c)));
                if (r == true) _load();
              },
            ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: AppTheme.primary,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textMuted,
          labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Məlumat'),
            Tab(text: 'Kontaktlar'),
            Tab(text: 'Təkliflər'),
            Tab(text: 'Tapşırıqlar'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _c == null
              ? const Center(child: Text('Tapılmadı'))
              : TabBarView(
                  controller: _tabs,
                  children: [
                    _InfoTab(),
                    _ContactsTab(),
                    _QuotationsTab(),
                    _TasksTab(),
                  ],
                ),
    );
  }

  // ── Info Tab ──────────────────────────────────────────────────────
  Widget _InfoTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Avatar + Ad
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: _statusColor(_c!['status'] ?? '').withOpacity(0.15),
                child: Text(
                  (_c!['name'] as String? ?? '?').trim().split(' ')
                      .map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase(),
                  style: TextStyle(fontSize: 20, color: _statusColor(_c!['status'] ?? ''),
                      fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(_c!['name'] ?? '',
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.textMain)),
                if ((_c!['company'] ?? '').isNotEmpty)
                  Text(_c!['company'], style: const TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                if ((_c!['position'] ?? '').isNotEmpty)
                  Text(_c!['position'], style: const TextStyle(color: AppTheme.primary, fontSize: 12)),
                const SizedBox(height: 6),
                _badge(_c!['status'] ?? ''),
              ])),
            ]),
          ),
        ),
        const SizedBox(height: 12),

        // Əlaqə məlumatları
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Əlaqə məlumatları',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.textMain)),
              const SizedBox(height: 12),
              if ((_c!['email'] ?? '').isNotEmpty) _row(Icons.email_outlined, 'Email', _c!['email']),
              if ((_c!['phone'] ?? '').isNotEmpty) _row(Icons.phone_outlined, 'Telefon', _c!['phone']),
              if ((_c!['address'] ?? '').isNotEmpty) _row(Icons.location_on_outlined, 'Ünvan', _c!['address']),
              if ((_c!['source'] ?? '').isNotEmpty) _row(Icons.source_outlined, 'Mənbə', _c!['source']),
            ]),
          ),
        ),

        // Qeydlər
        if ((_c!['notes'] ?? '').isNotEmpty) ...[
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Qeydlər',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.textMain)),
                const SizedBox(height: 8),
                Text(_c!['notes'], style: const TextStyle(fontSize: 13, color: AppTheme.textSub)),
              ]),
            ),
          ),
        ],

        // Statistika kartları
        const SizedBox(height: 12),
        Row(children: [
          _statCard('Kontaktlar', _contacts.length, Icons.people_outline, AppTheme.primary),
          const SizedBox(width: 10),
          _statCard('Təkliflər', _quotations.length, Icons.receipt_long_outlined, AppTheme.info),
          const SizedBox(width: 10),
          _statCard('Tapşırıqlar', _tasks.length, Icons.check_circle_outline, AppTheme.success),
        ]),
      ],
    );
  }

  // ── Contacts Tab ──────────────────────────────────────────────────
  Widget _ContactsTab() {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.person_add_outlined, size: 18),
            label: const Text('Yeni Kontakt'),
            onPressed: () async {
              final r = await Navigator.push(context, MaterialPageRoute(
                builder: (_) => ContactFormScreen(
                  item: {'customer_id': widget.id, 'customer_name': _c?['name']})));
              if (r == true) _load();
            },
          ),
        ),
      ),
      Expanded(
        child: _contacts.isEmpty
            ? Center(child: Text('Kontakt yoxdur', style: TextStyle(color: AppTheme.textMuted)))
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: _contacts.length,
                itemBuilder: (_, i) {
                  final c = _contacts[i];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.primary.withOpacity(0.15),
                        child: Text((c['name'] ?? '?')[0].toUpperCase(),
                          style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700)),
                      ),
                      title: Text(c['name'] ?? '', style: const TextStyle(color: AppTheme.textMain)),
                      subtitle: Text('${c['position'] ?? ''}\n${c['phone'] ?? c['email'] ?? ''}',
                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                      isThreeLine: true,
                      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 16, color: AppTheme.textMuted),
                          onPressed: () async {
                            final r = await Navigator.push(context,
                              MaterialPageRoute(builder: (_) => ContactFormScreen(item: c)));
                            if (r == true) _load();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 16, color: AppTheme.danger),
                          onPressed: () async {
                            await ApiService.deleteContact(c['id']);
                            _load();
                          },
                        ),
                      ]),
                    ),
                  );
                },
              ),
      ),
    ]);
  }

  // ── Quotations Tab ────────────────────────────────────────────────
  Widget _QuotationsTab() {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Yeni Təklif'),
            onPressed: () async {
              final r = await Navigator.push(context, MaterialPageRoute(
                builder: (_) => QuotationFormScreen(
                  item: {'customer_id': widget.id, 'customer_name': _c?['name']})));
              if (r == true) _load();
            },
          ),
        ),
      ),
      Expanded(
        child: _quotations.isEmpty
            ? Center(child: Text('Təklif yoxdur', style: TextStyle(color: AppTheme.textMuted)))
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: _quotations.length,
                itemBuilder: (_, i) {
                  final q = _quotations[i];
                  final status = q['status'] ?? 'draft';
                  final color = _quotStatusColor(status);
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(q['title'] ?? '', style: const TextStyle(color: AppTheme.textMain, fontWeight: FontWeight.w600)),
                      subtitle: Text('${q['grand_total'] ?? 0} ${q['currency'] ?? 'EUR'}',
                        style: const TextStyle(color: AppTheme.success, fontWeight: FontWeight.w600)),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(_quotStatusLabel(status),
                          style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  );
                },
              ),
      ),
    ]);
  }

  // ── Tasks Tab ─────────────────────────────────────────────────────
  Widget _TasksTab() {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add_task, size: 18),
            label: const Text('Yeni Tapşırıq'),
            onPressed: () async {
              final r = await Navigator.push(context, MaterialPageRoute(
                builder: (_) => TaskFormScreen(
                  item: {'customer_id': widget.id})));
              if (r == true) _load();
            },
          ),
        ),
      ),
      Expanded(
        child: _tasks.isEmpty
            ? Center(child: Text('Tapşırıq yoxdur', style: TextStyle(color: AppTheme.textMuted)))
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: _tasks.length,
                itemBuilder: (_, i) {
                  final t = _tasks[i];
                  final isDone = t['status'] == 'completed';
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Icon(
                        isDone ? Icons.check_circle_rounded : Icons.circle_outlined,
                        color: isDone ? AppTheme.success : AppTheme.textMuted,
                      ),
                      title: Text(t['title'] ?? '',
                        style: TextStyle(
                          color: isDone ? AppTheme.textMuted : AppTheme.textMain,
                          decoration: isDone ? TextDecoration.lineThrough : null,
                        )),
                      subtitle: Text(t['priority'] ?? '',
                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 16, color: AppTheme.textMuted),
                        onPressed: () async {
                          final r = await Navigator.push(context,
                            MaterialPageRoute(builder: (_) => TaskFormScreen(item: t)));
                          if (r == true) _load();
                        },
                      ),
                    ),
                  );
                },
              ),
      ),
    ]);
  }

  // ── Helpers ───────────────────────────────────────────────────────
  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Icon(icon, size: 16, color: AppTheme.primary),
        const SizedBox(width: 10),
        Text('$label: ', style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 13, color: AppTheme.textMain))),
      ]),
    );
  }

  Widget _badge(String status) {
    final color = _statusColor(status);
    final labels = {'active': 'Aktiv', 'lead': 'Lead', 'prospect': 'Prospect', 'inactive': 'Passiv'};
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(labels[status] ?? status,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }

  Widget _statCard(String label, int count, IconData icon, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text('$count', style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w700)),
            Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
          ]),
        ),
      ),
    );
  }

  Color _quotStatusColor(String s) {
    switch (s) {
      case 'accepted': return AppTheme.success;
      case 'sent':     return AppTheme.info;
      case 'rejected': return AppTheme.danger;
      default:         return AppTheme.textMuted;
    }
  }

  String _quotStatusLabel(String s) {
    switch (s) {
      case 'draft':    return 'Qaralama';
      case 'sent':     return 'Göndərilib';
      case 'accepted': return 'Qəbul edilib';
      case 'rejected': return 'Rədd edilib';
      default:         return s;
    }
  }
}