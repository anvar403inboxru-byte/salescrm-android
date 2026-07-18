import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../core/theme.dart';

class CustomerDetailScreen extends StatefulWidget {
  final int id;
  const CustomerDetailScreen({super.key, required this.id});

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  Map<String, dynamic>? _c;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService.getCustomer(widget.id);
      setState(() { _c = data; _loading = false; });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_c?['name'] ?? 'Müştəri'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _c == null
              ? const Center(child: Text('Tapılmadı'))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _infoCard(),
                      const SizedBox(height: 12),
                      _contactCard(),
                      if ((_c!['notes'] ?? '').isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _notesCard(),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _infoCard() {
    return Card(
      color: AppTheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppTheme.primary.withOpacity(0.2),
                child: Text(
                  (_c!['name'] as String? ?? '?')[0].toUpperCase(),
                  style: const TextStyle(fontSize: 24, color: AppTheme.primary, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_c!['name'] ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  if ((_c!['company'] ?? '').isNotEmpty)
                    Text(_c!['company'], style: const TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                  if ((_c!['position'] ?? '').isNotEmpty)
                    Text(_c!['position'], style: const TextStyle(color: AppTheme.primary, fontSize: 12)),
                ],
              )),
              _StatusBadge(status: _c!['status'] ?? ''),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _contactCard() {
    return Card(
      color: AppTheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📞 Əlaqə', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 12),
            if ((_c!['email'] ?? '').isNotEmpty)
              _InfoRow(icon: Icons.email_outlined, label: 'Email', value: _c!['email']),
            if ((_c!['phone'] ?? '').isNotEmpty)
              _InfoRow(icon: Icons.phone_outlined, label: 'Telefon', value: _c!['phone']),
            if ((_c!['address'] ?? '').isNotEmpty)
              _InfoRow(icon: Icons.location_on_outlined, label: 'Ünvan', value: _c!['address']),
            if ((_c!['source'] ?? '').isNotEmpty)
              _InfoRow(icon: Icons.source_outlined, label: 'Mənbə', value: _c!['source']),
          ],
        ),
      ),
    );
  }

  Widget _notesCard() {
    return Card(
      color: AppTheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📝 Qeydlər', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 8),
            Text(_c!['notes'] ?? '', style: const TextStyle(fontSize: 13, color: AppTheme.textMuted)),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Icon(icon, size: 16, color: AppTheme.primary),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
      ]),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  Color _color() {
    switch (status) {
      case 'active':   return AppTheme.success;
      case 'lead':     return AppTheme.primary;
      case 'prospect': return AppTheme.warning;
      default:         return AppTheme.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color().withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color().withOpacity(0.4)),
      ),
      child: Text(status, style: TextStyle(color: _color(), fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}