import 'package:flutter/material.dart';

import '../../state/app_store.dart';
import '../../theme.dart';
import '../../widgets/brand_lockup.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.store});
  final AppStore store;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  var _obscure = true;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    final err = await widget.store.signIn(
      email: _email.text,
      password: _password.text,
    );
    if (!mounted) return;
    if (err != null) {
      setState(() => _error = err);
      return;
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Ck.bg,
      appBar: AppBar(
        backgroundColor: Ck.bg,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        children: [
          const Center(child: BrandLockup(height: 40)),
          const SizedBox(height: 28),
          Text(
            'Giriş yap',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.6),
          ),
          const SizedBox(height: 8),
          const Text(
            'Favoriler, oylar ve hesap ayarların cihazlar arasında senkronlanacak.',
            style: TextStyle(color: Ck.mute, height: 1.45),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            decoration: _field('E-posta'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _password,
            obscureText: _obscure,
            autofillHints: const [AutofillHints.password],
            decoration: _field('Şifre').copyWith(
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: Ck.danger, fontSize: 13)),
          ],
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _submit,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              backgroundColor: Ck.mint,
              foregroundColor: Colors.white,
            ),
            child: const Text('Giriş yap'),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Hesabın yok mu?', style: TextStyle(color: Ck.mute)),
              TextButton(
                onPressed: () async {
                  final ok = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(builder: (_) => RegisterScreen(store: widget.store)),
                  );
                  if (ok == true && mounted) Navigator.of(context).pop(true);
                },
                child: const Text('Kayıt ol'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _field(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Ck.panel2,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Ck.line)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Ck.line)),
    );
  }
}
