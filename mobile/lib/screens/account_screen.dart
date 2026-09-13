import 'package:flutter/material.dart';

import '../navigation/app_tab.dart';
import '../state/app_store.dart';
import '../theme.dart';
import 'auth/change_password_screen.dart';
import 'auth/login_screen.dart';
import 'auth/register_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key, required this.store});
  final AppStore store;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      children: [
        if (!store.isSignedIn) ...[
          _SectionTitle('Üyelik'),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Giriş yap veya kayıt ol',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Favoriler, oylar ve hesap ayarların seninle kalsın.',
                  style: TextStyle(color: Ck.mute, height: 1.4),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => _openLogin(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: Ck.mint,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(44),
                  ),
                  child: const Text('Giriş yap'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () => _openRegister(context),
                  style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(44)),
                  child: const Text('Kayıt ol'),
                ),
              ],
            ),
          ),
        ] else ...[
          _SectionTitle('Kullanıcı bilgileri'),
          _Card(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Ck.mintDim,
                  child: Text(
                    _initials(store.session!.name),
                    style: const TextStyle(color: Ck.mint, fontWeight: FontWeight.w800, fontSize: 18),
                  ),
                ),
                const SizedBox(height: 12),
                Text(store.session!.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                Text(store.session!.email, style: const TextStyle(color: Ck.mute)),
                const SizedBox(height: 12),
                _ActionTile(
                  icon: Icons.badge_outlined,
                  label: 'Profili düzenle',
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
          _SectionTitle('Güvenlik ayarları'),
          _Card(
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('İki adımlı doğrulama'),
                  subtitle: const Text('Yakında', style: TextStyle(color: Ck.mute, fontSize: 12)),
                  value: false,
                  onChanged: null,
                ),
                const Divider(height: 1),
                _ActionTile(
                  icon: Icons.devices_other_outlined,
                  label: 'Aktif oturumlar',
                  subtitle: 'Bu cihaz',
                  onTap: () {},
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
        _SectionTitle('Uygulama'),
        _Card(
          child: Column(
            children: [
              _StatRow(label: 'Katalogdaki modeller', value: '${store.phones.length}'),
              const Divider(height: 1),
              _StatRow(label: 'Verdiğiniz oylar', value: '${store.votes.length}'),
              const Divider(height: 1),
              _StatRow(label: 'Kıyas sepeti', value: '${store.compareIds.length} / ${AppStore.maxCompare}'),
              const Divider(height: 1),
              _StatRow(label: 'Favoriler', value: '${store.favoriteIds.length}'),
            ],
          ),
        ),
      ],
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'TK';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
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
              const Text('Profili düzenle', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
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
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Ck.mute, letterSpacing: 0.3),
      ),
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
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: enabled ? Ck.mint : Ck.mute),
      title: Text(label, style: TextStyle(color: enabled ? Ck.ink : Ck.mute)),
      subtitle: subtitle != null ? Text(subtitle!, style: const TextStyle(color: Ck.mute, fontSize: 12)) : null,
      trailing: enabled ? const Icon(Icons.chevron_right, color: Ck.mute) : null,
      onTap: enabled ? onTap : null,
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
