import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../core/theme.dart';

const _statuses = ['lead', 'contact', 'proposal', 'negotiation', 'won', 'lost'];
const _statusLabels = {
  'lead': 'Lıd', 'contact': 'Əlaqə', 'proposal': 'Təklif',
  'negotiation': 'Danışıq', 'won': 'Qazanıldı', 'lost': 'İtirildi',
};
const _products = [
  'SAP ERP / S4HANA', 'Ariba', 'SAP SuccessFactors', 'SAP Consulting', 'Digər'
];
const _saleTypes = {
  'license': 'Lisenziya', 'implementation': 'İmplementasiya',
  'support': 'Dəstək', 'consulting': 'Konsaltinq', 'other': 'Digər',
};

Color _statusColor(String s) {
  switch (s) {
    case 'lead':        return const Color(0xFF8B5CF6);
    case 'contact':     return const Color(0xFF3B82F6);
    case 'proposal':    return const Color(0xFFF59E0B);
    case 'negotiation': return const Color(0xFFF97316);
    case 'won':         return AppTheme.success;
    case 'lost':        return AppTheme.danger;
    default:            return AppTheme.textMuted;
  }
}

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});
  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  List<dynamic> _sales = [];
  List<dynamic> _customers = [];
  List<dynamic> _users = [];
  bool _loading = true;
  String _search = '';
  String _filterStatus = '';
  String _filterProduct = '';

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        ApiService.get('/sales'),
        ApiService.getCustomers(),
        ApiService.getUsers(),
      ]);
      setState(() {
        _sales     = results[0] as List;
        _customers = results[1] as List;
        _users     = results[2] as List;
        _loading   = false;
      });
    } catch (_) { setState(() => _loading = false); }
  }

  List<dynamic> get _filtered {
    return _sales.where((s) {
      final q = _search.toLowerCase();
      if (q.isNotEmpty) {
        final name = (s['customer_name'] ?? s['product_name'] ?? '').toLowerCase();
        if (!name.contains(q)) return false;
      }
      if (_filterStatus.isNotEmpty && s['status'] != _filterStatus) return false;
      if (_filterProduct.isNotEmpty && s['product_name'] != _filterProduct) return false;
      return true;
    }).toList();
  }

  // KPI
  int get _won => _sales.where((s) => s['status'] == 'won').length;
  double get _totalRev => _sales
      .where((s) => s['status'] == 'won')
      .fold(0.0, (a, s) => a + (s['selling_price'] ?? 0));

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Satışlar'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _load)],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final r = await Navigator.push(context, MaterialPageRoute(
            builder: (_) => SaleFormScreen(customers: _customers, users: _users)));
          if (r == true) _load();
        },
        child: const Icon(Icons.add),
      ),
      body: Column(children: [
        // KPI sətri
        if (!_loading) Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(children: [
            _kpi('Qazanılan', '$_won', AppTheme.success, Icons.emoji_events_outlined),
            const SizedBox(width: 10),
            _kpi('Cəmi gəlir', '${_totalRev.toStringAsFixed(0)} EUR',
                AppTheme.primary, Icons.bar_chart),
            const SizedBox(width: 10),
            _kpi('Ümumi', '${_sales.length}', AppTheme.info, Icons.list_alt_outlined),
          ]),
        ),
        // Axtarış
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: TextField(
            style: const TextStyle(color: AppTheme.textMain),
            decoration: const InputDecoration(
              hintText: 'Axtar...',
              prefixIcon: Icon(Icons.search, size: 18),
              isDense: true,
            ),
            onChanged: (v) => setState(() => _search = v),
          ),
        ),
        // Filter sətri
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Row(children: [
            _chip('Hamısı', _filterStatus.isEmpty && _filterProduct.isEmpty,
                () => setState(() { _filterStatus = ''; _filterProduct = ''; })),
            const SizedBox(width: 6),
            for (final s in _statuses)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: _chip(_statusLabels[s]!, _filterStatus == s,
                    () => setState(() { _filterStatus = s; _filterProduct = ''; })),
              ),
          ]),
        ),
        // Siyahı
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : filtered.isEmpty
                  ? Center(child: Text('Satış tapılmadı',
                      style: TextStyle(color: AppTheme.textMuted)))
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                        itemCount: filtered.length,
                        itemBuilder: (_, i) => _SaleTile(
                          s: filtered[i],
                          onEdit: () async {
                            final r = await Navigator.push(context,
                              MaterialPageRoute(builder: (_) => SaleFormScreen(
                                item: filtered[i],
                                customers: _customers,
                                users: _users,
                              )));
                            if (r == true) _load();
                          },
                          onDelete: () async {
                            await ApiService.delete('/sales/${filtered[i]['id']}');
                            _load();
                          },
                        ),
                      ),
                    ),
        ),
      ]),
    );
  }

  Widget _kpi(String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13)),
          Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 10)),
        ]),
      ),
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary.withOpacity(0.15) : AppTheme.surface2,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppTheme.primary : AppTheme.border),
        ),
        child: Text(label, style: TextStyle(
          color: selected ? AppTheme.primary : AppTheme.textMuted,
          fontSize: 12, fontWeight: selected ? FontWeight.w600 : FontWeight.w400)),
      ),
    );
  }
}

class _SaleTile extends StatelessWidget {
  final Map<String, dynamic> s;
  final VoidCallback onEdit, onDelete;
  const _SaleTile({required this.s, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final status = s['status'] as String? ?? '';
    final color  = _statusColor(status);
    final price  = (s['selling_price'] ?? 0).toStringAsFixed(0);
    final cur    = s['currency'] ?? 'EUR';
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
              child: Text(s['customer_name'] ?? s['product_name'] ?? '',
                style: const TextStyle(fontWeight: FontWeight.w600,
                    fontSize: 14, color: AppTheme.textMain)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(_statusLabels[status] ?? status,
                style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
            ),
          ]),
          const SizedBox(height: 6),
          Row(children: [
            Text(s['product_name'] ?? '',
              style: const TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.w500)),
            const Spacer(),
            Text('$price $cur',
              style: const TextStyle(color: AppTheme.success,
                  fontWeight: FontWeight.w700, fontSize: 14)),
          ]),
          if ((s['notes'] ?? '').isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(s['notes'], style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
              maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            TextButton.icon(
              icon: const Icon(Icons.edit_outlined, size: 14),
              label: const Text('Düzəlt', style: TextStyle(fontSize: 12)),
              style: TextButton.styleFrom(foregroundColor: AppTheme.textMuted,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
              onPressed: onEdit,
            ),
            TextButton.icon(
              icon: const Icon(Icons.delete_outline, size: 14),
              label: const Text('Sil', style: TextStyle(fontSize: 12)),
              style: TextButton.styleFrom(foregroundColor: AppTheme.danger,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
              onPressed: onDelete,
            ),
          ]),
        ]),
      ),
    );
  }
}

// ── FORM ──────────────────────────────────────────────────────────────────────
class SaleFormScreen extends StatefulWidget {
  final Map<String, dynamic>? item;
  final List<dynamic> customers, users;
  const SaleFormScreen({super.key, this.item, required this.customers, required this.users});
  @override
  State<SaleFormScreen> createState() => _SaleFormScreenState();
}

class _SaleFormScreenState extends State<SaleFormScreen> {
  final _formKey     = GlobalKey<FormState>();
  final _priceCtrl   = TextEditingController();
  final _costCtrl    = TextEditingController();
  final _notesCtrl   = TextEditingController();
  String _customerId = '';
  String _product    = 'SAP ERP / S4HANA';
  String _saleType   = 'license';
  String _status     = 'lead';
  String _currency   = 'EUR';
  String _userId     = '';
  bool _saving       = false;

  bool get _isEdit => widget.item != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final it = widget.item!;
      _customerId = '${it['customer_id'] ?? ''}';
      _product    = it['product_name'] ?? 'SAP ERP / S4HANA';
      _saleType   = it['sale_type'] ?? 'license';
      _status     = it['status'] ?? 'lead';
      _currency   = it['currency'] ?? 'EUR';
      _userId     = '${it['employee_id'] ?? ''}';
      _priceCtrl.text = '${it['selling_price'] ?? ''}';
      _costCtrl.text  = '${it['cost_price'] ?? ''}';
      _notesCtrl.text = it['notes'] ?? '';
    } else {
      if (widget.users.isNotEmpty) _userId = '${widget.users[0]['id']}';
    }
  }

  @override
  void dispose() { _priceCtrl.dispose(); _costCtrl.dispose(); _notesCtrl.dispose(); super.dispose(); }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final data = {
        'customer_id': _customerId.isNotEmpty ? int.tryParse(_customerId) : null,
        'product_name': _product,
        'sale_type': _saleType,
        'status': _status,
        'currency': _currency,
        'selling_price': double.tryParse(_priceCtrl.text) ?? 0,
        'cost_price': double.tryParse(_costCtrl.text) ?? 0,
        'notes': _notesCtrl.text.trim(),
        'employee_id': _userId.isNotEmpty ? int.tryParse(_userId) : null,
      };
      if (_isEdit) {
        await ApiService.put('/sales/${widget.item!['id']}', data);
      } else {
        await ApiService.post('/sales', data);
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
        title: Text(_isEdit ? 'Satışı Düzəlt' : 'Yeni Satış'),
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
            _label('Müştəri'),
            _dropdown2(_customerId,
              [{'id': '', 'name': '— Seçin —'}, ...widget.customers],
              (v) => setState(() => _customerId = v ?? ''),
              (c) => '${c['id']}', (c) => c['name'] ?? ''),
            const SizedBox(height: 14),
            _label('Məhsul'),
            _simple(_product, _products,
                (v) => setState(() => _product = v ?? _product),
                (p) => p, (p) => p),
            const SizedBox(height: 14),
            _label('Növ'),
            _simple(_saleType, _saleTypes.keys.toList(),
                (v) => setState(() => _saleType = v ?? _saleType),
                (k) => k, (k) => _saleTypes[k] ?? k),
            const SizedBox(height: 14),
            _label('Status'),
            _simple(_status, _statuses,
                (v) => setState(() => _status = v ?? _status),
                (s) => s, (s) => _statusLabels[s] ?? s),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _label('Satış qiyməti'),
                TextFormField(
                  controller: _priceCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AppTheme.textMain),
                  decoration: const InputDecoration(hintText: '0'),
                  validator: (v) => (v == null || v.isEmpty) ? 'Daxil edin' : null,
                ),
              ])),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _label('Maya dəyəri'),
                TextFormField(
                  controller: _costCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AppTheme.textMain),
                  decoration: const InputDecoration(hintText: '0'),
                ),
              ])),
            ]),
            const SizedBox(height: 14),
            _label('Valyuta'),
            _simple(_currency, ['EUR', 'USD', 'AZN'],
                (v) => setState(() => _currency = v ?? _currency),
                (c) => c, (c) => c),
            const SizedBox(height: 14),
            _label('Məsul şəxs'),
            _dropdown2(_userId, widget.users,
                (v) => setState(() => _userId = v ?? ''),
                (u) => '${u['id']}', (u) => u['full_name'] ?? u['email'] ?? ''),
            const SizedBox(height: 14),
            _label('Qeydlər'),
            TextFormField(
              controller: _notesCtrl,
              maxLines: 3,
              style: const TextStyle(color: AppTheme.textMain),
              decoration: const InputDecoration(hintText: 'Əlavə qeydlər...'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(t, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)));

  Widget _simple<T>(T value, List<T> items, void Function(T?) onChange,
      T Function(T) toVal, String Function(T) toLabel) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.surface2, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value, dropdownColor: AppTheme.surface,
          style: const TextStyle(color: AppTheme.textMain),
          isExpanded: true,
          items: items.map((i) => DropdownMenuItem(value: toVal(i), child: Text(toLabel(i)))).toList(),
          onChanged: onChange,
        ),
      ),
    );
  }

  Widget _dropdown2<T>(String value, List<T> items, void Function(String?) onChange,
      String Function(T) toVal, String Function(T) toLabel) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.surface2, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.any((i) => toVal(i) == value) ? value : toVal(items.first),
          dropdownColor: AppTheme.surface,
          style: const TextStyle(color: AppTheme.textMain),
          isExpanded: true,
          items: items.map((i) => DropdownMenuItem(value: toVal(i), child: Text(toLabel(i)))).toList(),
          onChanged: onChange,
        ),
      ),
    );
  }
}