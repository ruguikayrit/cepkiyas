import 'package:flutter/material.dart';

import '../navigation/app_tab.dart';
import '../state/app_store.dart';
import '../theme.dart';
import '../typography.dart';
import 'auth/change_password_screen.dart';
import 'auth/login_screen.dart';
import 'auth/register_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key, required this.store});
  final AppStore store;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      children: [
        if (!store.isSignedIn) ...[
          _SectionTitle('Üyelik'),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Giriş yap veya kayıt ol', style: text.headlineSmall),
                const SizedBox(height: 8),
                Text(
                  'Favoriler, oylar ve hesap ayarların seninle kalsın.',
                  style: text.bodyMedium?.copyWith(color: Ck.mute),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => _openLogin(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: Ck.mint,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Giriş yap'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () => _openRegister(context),
                  child: const Text('Kayıt ol'),
                ),
              ],
            ),
          ),
        ] else ...[
          _SectionTitle('Temel bilgiler'),
          _Card(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Ck.mintDim,
                  child: Text(
                    _initials(store.session!.name),
                    style: text.titleLarge?.copyWith(color: Ck.mint, fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(height: 16),
                _InfoRow(label: 'Ad soyad', value: store.session!.name),
                const Divider(height: 1),
                _InfoRow(label: 'E-posta', value: store.session!.email),
                const Divider(height: 1),
                _InfoRow(
                  label: 'Telefon',
                  value: store.session!.phone.isEmpty ? '—' : store.session!.phone,
                ),
                const SizedBox(height: 8),
                _ActionTile(
                  icon: Icons.edit_outlined,
                  label: 'Bilgileri düzenle',
                  onTap: () => _editProfile(context),
                ),
              ],
            ),
          ),
          _SectionTitle('Şifre işlemleri'),
          _Card(
            child: Column(
              children: [
                _ActionTile(
                  icon: Icons.lock_outline_rounded,
                  label: 'Şifre değiştir',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => ChangePasswordScreen(store: store)),
                  ),
                ),
                const Divider(height: 1),
                _ActionTile(
                  icon: Icons.mail_outline_rounded,
                  label: 'E-posta doğrulama',
                  subtitle: 'Yakında',
                  enabled: false,
                  onTap: () {},
                ),
              ],
            ),
          ),
          _SectionTitle('Güvenlik'),
          _Card(
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('İki adımlı doğrulama', style: text.titleMedium),
                  subtitle: Text('Yakında', style: text.bodySmall),
                  value: false,
                  onChanged: null,
                ),
                const Divider(height: 1),
                _ActionTile(
                  icon: Icons.devices_other_outlined,
                  label: 'Aktif oturumlar',
                  subtitle: 'Bu cihaz · güvenli',
                  onTap: () => _showSessions(context),
                ),
                const Divider(height: 1),
                _ActionTile(
                  icon: Icons.shield_outlined,
                  label: 'Hesap güvenliği',
                  subtitle: 'Şifre ve oturum özeti',
                  onTap: () => _showSecuritySummary(context),
                ),
                const Divider(height: 1),
                _ActionTile(
                  icon: Icons.logout_rounded,
                  label: 'Çıkış yap',
                  onTap: () => store.signOut(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'TK';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
  }

  void _showSessions(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aktif oturumlar'),
        content: const Text(
          'Şu an yalnızca bu cihazda oturum açık. Diğer cihaz yönetimi yakında eklenecek.',
          style: TextStyle(height: 1.45),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tamam')),
        ],
      ),
    );
  }

  void _showSecuritySummary(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hesap güvenliği'),
        content: const Text(
          'Şifrenizi düzenli güncelleyin. İki adımlı doğrulama ve e-posta doğrulama yakında devreye alınacak.',
          style: TextStyle(height: 1.45),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tamam')),
        ],
      ),
    );
  }

  Future<void> _openLogin(BuildContext context) async {
    final ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => LoginScreen(store: store)),
    );
    if (ok == true) store.goTab(AppTab.account);
  }

  Future<void> _openRegister(BuildContext context) async {
    final ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => RegisterScreen(store: store)),
    );
    if (ok == true) store.goTab(AppTab.account);
  }

  Future<void> _editProfile(BuildContext context) async {
    final user = store.session!;
    final nameCtrl = TextEditingController(text: user.name);
    final phoneCtrl = TextEditingController(text: user.phone);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Ck.bg,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.paddingOf(context).bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Bilgileri düzenle', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Ad soyad')),
              const SizedBox(height: 8),
              TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Telefon')),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () async {
                  await store.updateProfile(name: nameCtrl.text, phone: phoneCtrl.text);
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Kaydet'),
              ),
            ],
          ),
        );
      },
    );
    nameCtrl.dispose();
    phoneCtrl.dispose();
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 18, 4, 8),
      child: Text(text.toUpperCase(), style: CkType.sectionLabel()),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Ck.panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Ck.line),
      ),
      child: child,
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(label, style: text.bodySmall?.copyWith(color: Ck.mute)),
          ),
          Expanded(child: Text(value, style: text.titleMedium)),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    this.subtitle,
    this.enabled = true,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: enabled ? Ck.mint : Ck.mute),
      title: Text(label, style: text.titleMedium?.copyWith(color: enabled ? Ck.ink : Ck.mute)),
      subtitle: subtitle != null ? Text(subtitle!, style: text.bodySmall) : null,
      trailing: enabled ? const Icon(Icons.chevron_right, color: Ck.mute) : null,
      onTap: enabled ? onTap : null,
    );
  }
}
