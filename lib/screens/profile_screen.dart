import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../core/theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final user = auth.user ?? {};

    return Scaffold(
      appBar: AppBar(title: const Text('👤 Profil')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Avatar + ad
          Card(
            color: AppTheme.surface,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppTheme.primary.withOpacity(0.2),
                  child: Text(
                    (user['full_name'] as String? ?? 'U')[0].toUpperCase(),
                    style: const TextStyle(fontSize: 28, color: AppTheme.primary, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user['full_name'] ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    Text(user['email'] ?? '', style: const TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(user['role'] ?? '', style: const TextStyle(color: AppTheme.primary, fontSize: 11, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ]),
            ),
          ),
          const SizedBox(height: 16),

          // Məlumatlar
          Card(
            color: AppTheme.surface,
            child: Column(children: [
              _InfoTile(icon: Icons.badge_outlined, label: 'Ad Soyad', value: user['full_name'] ?? '—'),
              _InfoTile(icon: Icons.email_outlined,  label: 'Email',    value: user['email'] ?? '—'),
              _InfoTile(icon: Icons.phone_outlined,  label: 'Telefon',  value: user['phone'] ?? '—'),
              _InfoTile(icon: Icons.work_outline,    label: 'Vəzifə',   value: user['position'] ?? '—'),
            ]),
          ),
          const SizedBox(height: 24),

          // Çıxış düyməsi
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
              icon: const Icon(Icons.logout),
              label: const Text('Çıxış'),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: AppTheme.surface,
                    title: const Text('Çıxış'),
                    content: const Text('Hesabdan çıxmaq istəyirsiniz?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Xeyr')),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Bəli', style: TextStyle(color: AppTheme.danger)),
                      ),
                    ],
                  ),
                );
                if (confirm == true && context.mounted) {
                  await context.read<AuthService>().logout();
                }
              },
            ),
          ),
          const SizedBox(height: 12),
          const Center(
            child: Text('ORBITSON CRM v1.0.0', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _InfoTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primary, size: 20),
      title: Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
      subtitle: Text(value, style: const TextStyle(fontSize: 13, color: AppTheme.textMain)),
    );
  }
}