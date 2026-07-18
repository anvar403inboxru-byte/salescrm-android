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
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService.getQuotations(status: _status);
      setState(() { _items = data; _loading = false; });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'accepted': return AppTheme.success;
      case 'sent':     return AppTheme.primary;
      case 'rejected': return AppTheme.danger;
      default:         return AppTheme.textMuted;
    }
  }

  String _statusLabel(String s) {
    switch (s) {
      case '':         return 'Hamısı';
      case 'draft':    return 'Qaralama';
      case 'sent':     return 'Göndərilib';
      case 'accepted': return 'Qəbul edildi';
      case 'rejected': return 'İmtina';
      default:         return s;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('💰 Qiymət Təklifləri')),
      body: Column(children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(children: [
            for (final s in ['', 'draft', 'sent', 'accepted', 'rejected'])
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
                      ? const Center(child: Text('Təklif tapılmadı', style: TextStyle(color: AppTheme.textMuted)))
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _items.length,
                          itemBuilder: (ctx, i) {
                            final q = _items[i];
                            final status = q['status'] as String? ?? 'draft';
                            final total = (q['grand_total'] ?? 0).toDouble();
                            final currency = q['currency'] ?? 'EUR';
                            return Card(
                              color: AppTheme.surface,
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                leading: Container(
                                  width: 40, height: 40,
                                  decoration: BoxDecoration(
                                    color: _statusColor(status).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(Icons.description_outlined, color: _statusColor(status), size: 20),
                                ),
                                title: Text(q['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                subtitle: Text(
                                  '${q['customer_name'] ?? ''} • ${q['created_at']?.toString().substring(0, 10) ?? ''}',
                                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${total.toStringAsFixed(0)} $currency',
                                      style: const TextStyle(color: AppTheme.success, fontWeight: FontWeight.w700, fontSize: 13),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: _statusColor(status).withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(_statusLabel(status), style: TextStyle(color: _statusColor(status), fontSize: 10)),
                                    ),
                                  ],
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