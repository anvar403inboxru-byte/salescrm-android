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
  final _searchCtrl = TextEditingController();

  @override
  void initState() { super.initState(); _load(); }

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService.getCustomers(search: _search, status: _status);
      setState(() { _items = data; _loading = false; });
    } catch (_) { setState(() => _loading = false); }
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

  Color _statusColor(String s) {
    switch (s) {
      case 'active':   return AppTheme.success;
      case 'lead':     return AppTheme.primary;
      case 'prospect': return AppTheme.warning;
      case 'inactive': return AppTheme.textMuted;
      default:         return AppTheme.textMuted;
    }
  }

  Future<void> _delete(int id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Müştərini sil?'),
        content: const Text('Bu əməliyyat geri alına bilməz.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Xeyr')),
          TextButton(onPressed: () => Navigator.pop(context, true),
              child: const Text('Sil', style: TextStyle(color: AppTheme.danger))),
        ],
      ),
    );
    if (ok == true) {
      try {
        await ApiService.deleteCustomer(id);
        _load();
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Müştəri silindi')));
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Xəta: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Müştərilər'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _load)],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(context,
            MaterialPageRoute(builder: (_) => const CustomerFormScreen()));
          if (result == true) _load();
        },
        child: const Icon(Icons.person_add_outlined),
      ),
      body: Column(children: [
        // Axtarış
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _searchCtrl,
            style: const TextStyle(color: AppTheme.textMain),
            decoration: InputDecoration(
              hintText: 'Ad, şirkət, email axtar...',
              prefixIcon: const Icon(Icons.search, size: 18),
              suffixIcon: _search.isNotEmpty
                  ? IconButton(icon: const Icon(Icons.close, size: 18),
                      onPressed: () { _searchCtrl.clear(); setState(() => _search = ''); _load(); })
                  : null,
            ),
            onChanged: (v) { setState(() => _search = v); _load(); },
          ),
        ),
        // Status filter
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(children: [
            for (final s in ['', 'lead', 'prospect', 'active', 'inactive'])
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(_statusLabel(s)),
                  selected: _status == s,
                  selectedColor: AppTheme.primary.withOpacity(0.2),
                  onSelected: (_) { setState(() => _status = s); _load(); },
                ),
              ),
          ]),
        ),
        // Siyahı
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _items.isEmpty
                  ? Center(child: Text('Müştəri tapılmadı',
                      style: TextStyle(color: AppTheme.textMuted)))
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                        itemCount: _items.length,
                        itemBuilder: (ctx, i) {
                          final c = _items[i];
                          final status = c['status'] as String? ?? '';
                          final name = c['name'] as String? ?? '?';
                          final initials = name.trim().split(' ')
                              .map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase();
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () => ctx.push('/customers/${c['id']}'),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Row(children: [
                                  CircleAvatar(
                                    radius: 22,
                                    backgroundColor: _statusColor(status).withOpacity(0.15),
                                    child: Text(initials,
                                      style: TextStyle(color: _statusColor(status),
                                          fontWeight: FontWeight.w700, fontSize: 14)),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      Text(name, style: const TextStyle(
                                          fontWeight: FontWeight.w600, fontSize: 14, color: AppTheme.textMain)),
                                      if ((c['company'] ?? '').isNotEmpty)
                                        Text(c['company'], style: const TextStyle(
                                            color: AppTheme.textMuted, fontSize: 12)),
                                      if ((c['phone'] ?? '').isNotEmpty)
                                        Text(c['phone'], style: const TextStyle(
                                            color: AppTheme.textMuted, fontSize: 11)),
                                    ]),
                                  ),
                                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: _statusColor(status).withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(_statusLabel(status),
                                        style: TextStyle(color: _statusColor(status),
                                            fontSize: 11, fontWeight: FontWeight.w600)),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined, size: 16, color: AppTheme.textMuted),
                                        padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                                        onPressed: () async {
                                          final result = await Navigator.push(context,
                                            MaterialPageRoute(builder: (_) => CustomerFormScreen(item: c)));
                                          if (result == true) _load();
                                        },
                                      ),
                                      const SizedBox(width: 12),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, size: 16, color: AppTheme.danger),
                                        padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                                        onPressed: () => _delete(c['id']),
                                      ),
                                    ]),
                                  ]),
                                ]),
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

// ── FORM ──────────────────────────────────────────────────────────────────────
class CustomerFormScreen extends StatefulWidget {
  final Map<String, dynamic>? item;
  const CustomerFormScreen({super.key, this.item});
  @override
  State<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends State<CustomerFormScreen> {
  final _formKey      = GlobalKey<FormState>();
  final _nameCtrl     = TextEditingController();
  final _companyCtrl  = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _phoneCtrl    = TextEditingController();
  final _posCtrl      = TextEditingController();
  final _addressCtrl  = TextEditingController();
  final _notesCtrl    = TextEditingController();
  String _status = 'lead';
  String _source = '';
  bool _saving = false;

  bool get _isEdit => widget.item != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _nameCtrl.text    = widget.item!['name'] ?? '';
      _companyCtrl.text = widget.item!['company'] ?? '';
      _emailCtrl.text   = widget.item!['email'] ?? '';
      _phoneCtrl.text   = widget.item!['phone'] ?? '';
      _posCtrl.text     = widget.item!['position'] ?? '';
      _addressCtrl.text = widget.item!['address'] ?? '';
      _notesCtrl.text   = widget.item!['notes'] ?? '';
      _status           = widget.item!['status'] ?? 'lead';
      _source           = widget.item!['source'] ?? '';
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _companyCtrl.dispose(); _emailCtrl.dispose();
    _phoneCtrl.dispose(); _posCtrl.dispose(); _addressCtrl.dispose(); _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final data = {
        'name': _nameCtrl.text.trim(),
        'company': _companyCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'position': _posCtrl.text.trim(),
        'address': _addressCtrl.text.trim(),
        'notes': _notesCtrl.text.trim(),
        'status': _status,
        'source': _source,
      };
      if (_isEdit) {
        await ApiService.updateCustomer(widget.item!['id'], data);
      } else {
        await ApiService.createCustomer(data);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() => _saving = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xəta: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: Text(_isEdit ? 'Müştərini Düzəlt' : 'Yeni Müştəri'),
        actions: [
          if (_saving)
            const Padding(padding: EdgeInsets.all(16),
              child: SizedBox(width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2)))
          else
            TextButton(onPressed: _save,
              child: const Text('Saxla',
                style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600))),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _field('Ad Soyad *', _nameCtrl, required: true),
            const SizedBox(height: 14),
            _field('Şirkət', _companyCtrl),
            const SizedBox(height: 14),
            _field('Email', _emailCtrl, keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 14),
            _field('Telefon', _phoneCtrl, keyboardType: TextInputType.phone),
            const SizedBox(height: 14),
            _field('Vəzifə', _posCtrl),
            const SizedBox(height: 14),
            _field('Ünvan', _addressCtrl),
            const SizedBox(height: 14),
            _dropdown('Status', _status,
              {'lead': 'Lead', 'prospect': 'Prospect', 'active': 'Aktiv', 'inactive': 'Passiv'},
              (v) => setState(() => _status = v!)),
            const SizedBox(height: 14),
            _dropdown('Mənbə', _source.isEmpty ? '' : _source,
              {'': '— Seçin —', 'referral': 'Referans', 'website': 'Sayt', 'cold_call': 'Zəng',
               'email': 'Email', 'social': 'Sosial şəbəkə', 'other': 'Digər'},
              (v) => setState(() => _source = v ?? '')),
            const SizedBox(height: 14),
            _field('Qeydlər', _notesCtrl, maxLines: 4),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl,
      {bool required = false, int maxLines = 1, TextInputType? keyboardType}) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppTheme.textMain),
      decoration: InputDecoration(labelText: label),
      validator: required
          ? (v) => (v == null || v.trim().isEmpty) ? 'Daxil edin' : null
          : null,
    );
  }

  Widget _dropdown(String label, String value, Map<String, String> items,
      void Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.surface2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.containsKey(value) ? value : items.keys.first,
          dropdownColor: AppTheme.surface,
          style: const TextStyle(color: AppTheme.textMain),
          isExpanded: true,
          items: items.entries
              .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}