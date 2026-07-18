import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../core/theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _stats;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await ApiService.getDashboard();
      setState(() { _stats = data; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('◈ Dashboard'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _ErrorView(error: _error!, onRetry: _load)
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _kpiRow(),
                      const SizedBox(height: 16),
                      _pipelineCard(),
                      const SizedBox(height: 16),
                      _quotationsCard(),
                    ],
                  ),
                ),
    );
  }

  Widget _kpiRow() {
    final s = _stats!;
    return Row(children: [
      Expanded(child: _KpiCard(
        label: 'Ümumi Satış',
        value: '${s['total_sales'] ?? 0}',
        icon: Icons.bar_chart,
        color: AppTheme.primary,
      )),
      const SizedBox(width: 12),
      Expanded(child: _KpiCard(
        label: 'Müştərilər',
        value: '${s['total_customers'] ?? 0}',
        icon: Icons.people,
        color: AppTheme.success,
      )),
    ]);
  }

  Widget _pipelineCard() {
    final pipeline = (_stats!['pipeline'] as List?) ?? [];
    return Card(
      color: AppTheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📊 Pipeline', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 12),
            if (pipeline.isEmpty)
              const Text('Məlumat yoxdur', style: TextStyle(color: AppTheme.textMuted))
            else
              ...pipeline.map((p) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${p['status'] ?? ''}', style: const TextStyle(fontSize: 13)),
                    Text('${p['count'] ?? 0} • ${(p['total'] ?? 0).toStringAsFixed(0)} EUR',
                        style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600)),
                  ],
                ),
              )),
          ],
        ),
      ),
    );
  }

  Widget _quotationsCard() {
    final quotes = (_stats!['recent_quotations'] as List?) ?? [];
    return Card(
      color: AppTheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('💰 Son Təkliflər', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 12),
            if (quotes.isEmpty)
              const Text('Məlumat yoxdur', style: TextStyle(color: AppTheme.textMuted))
            else
              ...quotes.take(5).map((q) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.description_outlined, color: AppTheme.primary),
                title: Text('${q['title'] ?? ''}', style: const TextStyle(fontSize: 13)),
                subtitle: Text('${q['customer_name'] ?? ''}', style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                trailing: Text(
                  '${(q['grand_total'] ?? 0).toStringAsFixed(0)} ${q['currency'] ?? 'EUR'}',
                  style: const TextStyle(color: AppTheme.success, fontWeight: FontWeight.w600),
                ),
              )),
          ],
        ),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _KpiCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.wifi_off, size: 48, color: AppTheme.danger),
        const SizedBox(height: 12),
        const Text('Bağlantı xətası', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Text(error, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted), textAlign: TextAlign.center),
        const SizedBox(height: 16),
        ElevatedButton(onPressed: onRetry, child: const Text('Yenidən cəhd et')),
      ],
    ));
  }
}