import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../core/theme.dart';

const _roles = ['admin', 'manager', 'member'];
const _roleLabels = {'admin': 'Admin', 'manager': 'Menecer', 'member': 'Üzv'};
const _roleColors = {
  'admin':   Color(0xFFEF4444),
  'manager': Color(0xFF6366F1),
  'member':  Color(0xFF10B981),
};
const _langs = [
  {'value': 'az', 'label': '🇦🇿 AZ'},
  {'value': 'ru', 'label': '🇷🇺 RU'},
  {'value': 'en', 'label': '🇬🇧 EN'},
];

class TeamScreen extends StatefulWidget {
  const TeamScreen({super.key});
  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  List<dynamic> _users = [];
  bool _loading = true;
  Map<String, dynamic>? _currentUser;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        ApiService.getUsers(),
        ApiService.get('/auth/me'),
      ]);
      setState(() {
        _users = results[0] as List;
        _currentUser = results[1] as Map<String, dynamic>;
        _loading = false;
      });
    } catch (_) { setState(() => _loading = false); }
  }

  bool get _isAdmin => _currentUser?['role'] == 'admin';
  bool get _isManager =>
      _currentUser?['role'] == 'admin' || _currentUser?['role'] == 'manager';

  String _initials(String name) {
    final parts = name.trim().split(' ');
    return parts.map((p) => p.isNotEmpty ? p[0] : '').take(2).join().toUpperCase();
  }

  Future<void> _delete(int id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('İstifadəçini sil?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Xeyr')),
          TextButton(onPressed: () => Navigator.pop(context, true),
              child: const Text('Sil', style: TextStyle(color: AppTheme.danger))),
        ],
      ),
    );
    if (ok == true) {
      try {
        await ApiService.delete('/auth/users/$id');
        _load();
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
        title: const Text('Komanda'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _load)],
      ),
      floatingActionButton: _isManager
          ? FloatingActionButton(
              onPressed: () async {
                final r = await Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const TeamFormScreen()));
                if (r == true) _load();
              },
              child: const Icon(Icons.person_add_outlined),
            )
          : null,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _users.isEmpty
              ? Center(child: Text('İstifadəçi tapılmadı',
                  style: TextStyle(color: AppTheme.textMuted)))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                    itemCount: _users.length,
                    itemBuilder: (_, i) {
                      final u = _users[i];
                      final role  = u['role'] as String? ?? 'member';
                      final color = _roleColors[role] ?? AppTheme.textMuted;
                      final isSelf = u['id'] == _currentUser?['id'];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: color.withOpacity(0.15),
                              child: Text(_initials(u['full_name'] ?? u['email'] ?? '?'),
                                style: TextStyle(color: color,
                                    fontWeight: FontWeight.w700, fontSize: 13)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Row(children: [
                                  Text(u['full_name'] ?? '',
                                    style: const TextStyle(fontWeight: FontWeight.w600,
                                        fontSize: 14, color: AppTheme.textMain)),
                                  if (isSelf) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primary.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text('Siz', style: TextStyle(
                                          color: AppTheme.primary, fontSize: 10)),
                                    ),
                                  ],
                                ]),
                                Text(u['email'] ?? '',
                                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                                if ((u['position'] ?? '').isNotEmpty)
                                  Text(u['position'], style: const TextStyle(
                                      color: AppTheme.textSub, fontSize: 11)),
                                const SizedBox(height: 4),
                                Row(children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(_roleLabels[role] ?? role,
                                      style: TextStyle(color: color, fontSize: 10,
                                          fontWeight: FontWeight.w600)),
                                  ),
                                  if (u['language'] != null) ...[
                                    const SizedBox(width: 8),
                                    Text(
                                      _langs.firstWhere(
                                        (l) => l['value'] == u['language'],
                                        orElse: () => {'label': u['language']})['label']!,
                                      style: const TextStyle(
                                          color: AppTheme.textMuted, fontSize: 11)),
                                  ],
                                ]),
                              ]),
                            ),
                            if (_isAdmin && !isSelf)
                              Column(mainAxisSize: MainAxisSize.min, children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 18,
                                      color: AppTheme.textMuted),
                                  onPressed: () async {
                                    final r = await Navigator.push(context,
                                      MaterialPageRoute(
                                        builder: (_) => TeamFormScreen(item: u)));
                                    if (r == true) _load();
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 18,
                                      color: AppTheme.danger),
                                  onPressed: () => _delete(u['id']),
                                ),
                              ]),
                          ]),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

// ── FORM ──────────────────────────────────────────────────────────────────────
class TeamFormScreen extends StatefulWidget {
  final Map<String, dynamic>? item;
  const TeamFormScreen({super.key, this.item});
  @override
  State<TeamFormScreen> createState() => _TeamFormScreenState();
}

class _TeamFormScreenState extends State<TeamFormScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _nameCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  final _posCtrl   = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String _role     = 'member';
  String _lang     = 'az';
  bool _saving     = false;
  bool _showPass   = false;

  bool get _isEdit => widget.item != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final u = widget.item!;
      _nameCtrl.text  = u['full_name'] ?? '';
      _emailCtrl.text = u['email'] ?? '';
      _posCtrl.text   = u['position'] ?? '';
      _phoneCtrl.text = u['phone'] ?? '';
      _role = u['role'] ?? 'member';
      _lang = u['language'] ?? 'az';
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose(); _passCtrl.dispose();
    _posCtrl.dispose(); _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final data = <String, dynamic>{
        'full_name': _nameCtrl.text.trim(),
        'email':     _emailCtrl.text.trim(),
        'role':      _role,
        'language':  _lang,
        'position':  _posCtrl.text.trim(),
        'phone':     _phoneCtrl.text.trim(),
      };
      if (_passCtrl.text.isNotEmpty) data['password'] = _passCtrl.text;

      if (_isEdit) {
        await ApiService.put('/auth/users/${widget.item!['id']}', data);
      } else {
        await ApiService.post('/auth/register', data);
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
        title: Text(_isEdit ? 'İstifadəçini Düzəlt' : 'Yeni İstifadəçi'),
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
            _field('Email *', _emailCtrl,
                required: true, keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 14),
            TextFormField(
              controller: _passCtrl,
              obscureText: !_showPass,
              style: const TextStyle(color: AppTheme.textMain),
              decoration: InputDecoration(
                labelText: _isEdit ? 'Yeni Şifrə (boş buraxsanız dəyişməz)' : 'Şifrə *',
                suffixIcon: IconButton(
                  icon: Icon(_showPass ? Icons.visibility_off : Icons.visibility,
                      size: 18, color: AppTheme.textMuted),
                  onPressed: () => setState(() => _showPass = !_showPass),
                ),
              ),
              validator: _isEdit
                  ? null
                  : (v) => (v == null || v.isEmpty) ? 'Şifrə vacibdir' : null,
            ),
            const SizedBox(height: 14),
            _field('Vəzifə', _posCtrl),
            const SizedBox(height: 14),
            _field('Telefon', _phoneCtrl, keyboardType: TextInputType.phone),
            const SizedBox(height: 14),
            _dropdownWidget('Rol', _role, _roles,
                (v) => setState(() => _role = v ?? _role),
                (r) => _roleLabels[r] ?? r),
            const SizedBox(height: 14),
            _dropdownWidget('Dil', _lang, ['az', 'ru', 'en'],
                (v) => setState(() => _lang = v ?? _lang),
                (l) => _langs.firstWhere((x) => x['value'] == l,
                    orElse: () => {'label': l})['label']!),
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

  Widget _dropdownWidget(String label, String value, List<String> items,
      void Function(String?) onChange, String Function(String) toLabel) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.surface2, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value, dropdownColor: AppTheme.surface,
          style: const TextStyle(color: AppTheme.textMain),
          isExpanded: true,
          items: items.map((i) => DropdownMenuItem(
            value: i, child: Text(toLabel(i)))).toList(),
          onChanged: onChange,
        ),
      ),
    );
  }
}