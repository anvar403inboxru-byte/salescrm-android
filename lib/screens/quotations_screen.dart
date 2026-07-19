import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../core/theme.dart';

class QuotationsScreen extends StatefulWidget {
  const QuotationsScreen({super.key});
  @override
  State<QuotationsScreen> createState() => _QuotationsScreenState();
}

class _QuotationsScreenState extends State<QuotationsScreen> {
  List<dynamic> _items = [];
  bool _loading = true;
  String _status = '';

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService.getQuotations(status: _status);
      setState(() { _items = data; _loading = false; });
    } catch (_) { setState(() => _loading = false); }
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'sent':     return AppTheme.info;
      case 'accepted': return AppTheme.success;
      case 'rejected': return AppTheme.danger;
      case 'draft':    return AppTheme.textMuted;
      default:         return AppTheme.warning;
    }
  }

  String _statusLabel(String s) {
    switch (s) {
      case 'sent':     return 'Göndərilib';
      case 'accepted': return 'Qəbul edilib';
      case 'rejected': return 'Rədd edilib';
      case 'draft':    return 'Qaralama';
      default:         return s;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Qiymət Təklifləri'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(context),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Status filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                for (final s in ['', 'draft', 'sent', 'accepted', 'rejected'])
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
          // List
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _items.isEmpty
                    ? Center(child: Text('Təklif yoxdur', style: TextStyle(color: AppTheme.textMuted)))
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                          itemCount: _items.length,
                          itemBuilder: (_, i) => _QuotCard(
                            item: _items[i],
                            statusColor: _statusColor,
                            statusLabel: _statusLabel,
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
        await ApiService.deleteQuotation(id);
        _load();
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Xəta: $e')));
      }
    }
  }

  void _openForm(BuildContext context, {Map<String, dynamic>? item}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => QuotationFormScreen(item: item)),
    );
    if (result == true) _load();
  }
}

class _QuotCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final Color Function(String) statusColor;
  final String Function(String) statusLabel;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _QuotCard({required this.item, required this.statusColor, required this.statusLabel, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final status = item['status'] ?? 'draft';
    final color = statusColor(status);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item['title'] ?? 'Başlıqsız',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppTheme.textMain),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: color.withOpacity(0.4)),
                    ),
                    child: Text(statusLabel(status), style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              if (item['customer_name'] != null) ...[
                const SizedBox(height: 6),
                Row(children: [
                  const Icon(Icons.business_outlined, size: 14, color: AppTheme.textMuted),
                  const SizedBox(width: 4),
                  Text(item['customer_name'], style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                ]),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  if (item['grand_total'] != null) ...[
                    const Icon(Icons.euro_outlined, size: 14, color: AppTheme.success),
                    const SizedBox(width: 4),
                    Text(
                      '${item['grand_total']} ${item['currency'] ?? 'EUR'}',
                      style: const TextStyle(color: AppTheme.success, fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ],
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18, color: AppTheme.danger),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: onDelete,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── FORM ──────────────────────────────────────────────────────────────
class QuotationFormScreen extends StatefulWidget {
  final Map<String, dynamic>? item;
  const QuotationFormScreen({super.key, this.item});

  @override
  State<QuotationFormScreen> createState() => _QuotationFormScreenState();
}

class _QuotationFormScreenState extends State<QuotationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl   = TextEditingController();
  final _totalCtrl   = TextEditingController();
  final _notesCtrl   = TextEditingController();
  String _status = 'draft';
  String _currency = 'EUR';
  int? _customerId;
  List<dynamic> _customers = [];
  bool _loading = false;
  bool _saving = false;

  bool get _isEdit => widget.item != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _titleCtrl.text    = widget.item!['title'] ?? '';
      _totalCtrl.text    = widget.item!['grand_total']?.toString() ?? '';
      _notesCtrl.text    = widget.item!['notes'] ?? '';
      _status            = widget.item!['status'] ?? 'draft';
      _currency          = widget.item!['currency'] ?? 'EUR';
      _customerId        = widget.item!['customer_id'];
    }
    _loadCustomers();
  }

  @override
  void dispose() {
    _titleCtrl.dispose(); _totalCtrl.dispose(); _notesCtrl.dispose();
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
        'title': _titleCtrl.text.trim(),
        'status': _status,
        'currency': _currency,
        'grand_total': double.tryParse(_totalCtrl.text) ?? 0,
        'notes': _notesCtrl.text.trim(),
        if (_customerId != null) 'customer_id': _customerId,
      };
      if (_isEdit) {
        await ApiService.updateQuotation(widget.item!['id'], data);
      } else {
        await ApiService.createQuotation(data);
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
        title: Text(_isEdit ? 'Təklifi Düzəlt' : 'Yeni Təklif'),
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
                  _field('Başlıq', _titleCtrl, required: true),
                  const SizedBox(height: 14),

                  // Müştəri seçimi
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
                          ..._customers.map((c) => DropdownMenuItem(
                            value: c['id'] as int,
                            child: Text(c['name'] ?? ''),
                          )),
                        ],
                        onChanged: (v) => setState(() => _customerId = v),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Status
                  _dropdown<String>(
                    'Status',
                    _status,
                    {'draft': 'Qaralama', 'sent': 'Göndərilib', 'accepted': 'Qəbul edilib', 'rejected': 'Rədd edilib'},
                    (v) => setState(() => _status = v!),
                  ),
                  const SizedBox(height: 14),

                  // Məbləğ + Valyuta
                  Row(
                    children: [
                      Expanded(child: _field('Məbləğ', _totalCtrl, keyboardType: TextInputType.number)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _dropdown<String>(
                          'Valyuta',
                          _currency,
                          {'EUR': 'EUR', 'USD': 'USD', 'AZN': 'AZN'},
                          (v) => setState(() => _currency = v!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  _field('Qeydlər', _notesCtrl, maxLines: 4),
                ],
              ),
            ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, {bool required = false, int maxLines = 1, TextInputType? keyboardType}) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppTheme.textMain),
      decoration: InputDecoration(labelText: label),
      validator: required ? (v) => (v == null || v.trim().isEmpty) ? '$label daxil edin' : null : null,
    );
  }

  Widget _dropdown<T>(String label, T value, Map<T, String> items, void Function(T?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.surface2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
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