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
  final _searchCtrl = TextEditingController();

  @override
  void initState() { super.initState(); _load(); }

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService.getContacts(search: _search);
      setState(() { _items = data; _loading = false; });
    } catch (_) { setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Kontaktlar'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _load)],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(context),
        child: const Icon(Icons.person_add_outlined),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              style: const TextStyle(color: AppTheme.textMain),
              decoration: InputDecoration(
                hintText: 'Axtar...',
                prefixIcon: const Icon(Icons.search, size: 18),
                suffixIcon: _search.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () { _searchCtrl.clear(); setState(() => _search = ''); _load(); })
                    : null,
              ),
              onChanged: (v) { setState(() => _search = v); _load(); },
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _items.isEmpty
                    ? Center(child: Text('Kontakt yoxdur', style: TextStyle(color: AppTheme.textMuted)))
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                          itemCount: _items.length,
                          itemBuilder: (_, i) => _ContactCard(
                            item: _items[i],
                            onTap: () => _openForm(context, item: _items[i]),
                            onDelete: () => _delete(_items[i]['id']),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
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
        await ApiService.deleteContact(id);
        _load();
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Xəta: $e')));
      }
    }
  }

  void _openForm(BuildContext context, {Map<String, dynamic>? item}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ContactFormScreen(item: item)),
    );
    if (result == true) _load();
  }
}

class _ContactCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ContactCard({required this.item, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final name = item['name'] ?? '';
    final initials = name.isNotEmpty ? name.trim().split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase() : '?';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppTheme.primary.withOpacity(0.15),
                child: Text(initials, style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700, fontSize: 14)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(color: AppTheme.textMain, fontWeight: FontWeight.w600, fontSize: 14)),
                    if (item['position'] != null && item['position'].toString().isNotEmpty)
                      Text(item['position'], style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                    if (item['customer_name'] != null)
                      Text(item['customer_name'], style: const TextStyle(color: AppTheme.primary, fontSize: 11)),
                    const SizedBox(height: 4),
                    if (item['phone'] != null && item['phone'].toString().isNotEmpty)
                      Row(children: [
                        const Icon(Icons.phone_outlined, size: 12, color: AppTheme.textMuted),
                        const SizedBox(width: 4),
                        Text(item['phone'], style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                      ]),
                    if (item['email'] != null && item['email'].toString().isNotEmpty)
                      Row(children: [
                        const Icon(Icons.email_outlined, size: 12, color: AppTheme.textMuted),
                        const SizedBox(width: 4),
                        Text(item['email'], style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                      ]),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18, color: AppTheme.danger),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── FORM ──────────────────────────────────────────────────────────────
class ContactFormScreen extends StatefulWidget {
  final Map<String, dynamic>? item;
  const ContactFormScreen({super.key, this.item});
  @override
  State<ContactFormScreen> createState() => _ContactFormScreenState();
}

class _ContactFormScreenState extends State<ContactFormScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _nameCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _posCtrl   = TextEditingController();
  int? _customerId;
  List<dynamic> _customers = [];
  bool _loading = false;
  bool _saving = false;

  bool get _isEdit => widget.item != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _nameCtrl.text  = widget.item!['name'] ?? '';
      _emailCtrl.text = widget.item!['email'] ?? '';
      _phoneCtrl.text = widget.item!['phone'] ?? '';
      _posCtrl.text   = widget.item!['position'] ?? '';
      _customerId     = widget.item!['customer_id'];
    }
    _loadCustomers();
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose(); _phoneCtrl.dispose(); _posCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCustomers() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService.getCustomers();
      setState(() { _customers = data; _loading = false; });
    } catch (_) { setState(() => _loading = false); }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final data = {
        'name': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'position': _posCtrl.text.trim(),
        if (_customerId != null) 'customer_id': _customerId,
      };
      if (_isEdit) {
        await ApiService.updateContact(widget.item!['id'], data);
      } else {
        await ApiService.createContact(data);
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
        title: Text(_isEdit ? 'Kontaktı Düzəlt' : 'Yeni Kontakt'),
        actions: [
          if (_saving)
            const Padding(padding: EdgeInsets.all(16), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
          else
            TextButton(onPressed: _save, child: const Text('Saxla', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600))),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _field('Ad Soyad', _nameCtrl, required: true),
                  const SizedBox(height: 14),
                  _field('Vəzifə', _posCtrl),
                  const SizedBox(height: 14),
                  _field('Email', _emailCtrl, keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 14),
                  _field('Telefon', _phoneCtrl, keyboardType: TextInputType.phone),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.surface2,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int?>(
                        value: _customerId,
                        hint: const Text('Müştəri seçin', style: TextStyle(color: AppTheme.textMuted)),
                        dropdownColor: AppTheme.surface,
                        style: const TextStyle(color: AppTheme.textMain),
                        isExpanded: true,
                        items: [
                          const DropdownMenuItem(value: null, child: Text('— Müştərisiz —')),
                          ..._customers.map((c) => DropdownMenuItem(value: c['id'] as int, child: Text(c['name'] ?? ''))),
                        ],
                        onChanged: (v) => setState(() => _customerId = v),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, {bool required = false, TextInputType? keyboardType}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppTheme.textMain),
      decoration: InputDecoration(labelText: label),
      validator: required ? (v) => (v == null || v.trim().isEmpty) ? '$label daxil edin' : null : null,
    );
  }
}