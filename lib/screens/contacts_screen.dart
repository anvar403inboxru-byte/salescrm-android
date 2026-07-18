import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../core/theme.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  List<dynamic> _items = [];
  bool _loading = true;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService.getContacts(search: _search);
      setState(() { _items = data; _loading = false; });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📇 Kontaktlar'),
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
              onChanged: (v) { _search = v; _load(); },
            ),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: _items.isEmpty
                  ? const Center(child: Text('Kontakt tapılmadı', style: TextStyle(color: AppTheme.textMuted)))
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _items.length,
                      itemBuilder: (ctx, i) {
                        final c = _items[i];
                        return Card(
                          color: AppTheme.surface,
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppTheme.success.withOpacity(0.2),
                              child: Text(
                                (c['full_name'] as String? ?? '?')[0].toUpperCase(),
                                style: const TextStyle(color: AppTheme.success, fontWeight: FontWeight.w700),
                              ),
                            ),
                            title: Text(c['full_name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if ((c['position'] ?? '').isNotEmpty)
                                  Text(c['position'], style: const TextStyle(fontSize: 11, color: AppTheme.primary)),
                                if ((c['company_name'] ?? '').isNotEmpty)
                                  Text(c['company_name'], style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                              ],
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if ((c['email'] ?? '').isNotEmpty)
                                  const Icon(Icons.email_outlined, size: 16, color: AppTheme.textMuted),
                                if ((c['phone'] ?? '').isNotEmpty)
                                  const Icon(Icons.phone_outlined, size: 16, color: AppTheme.textMuted),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}