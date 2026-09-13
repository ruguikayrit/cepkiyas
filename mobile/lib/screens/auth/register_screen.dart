import 'package:flutter/material.dart';

import '../../state/app_store.dart';
import '../../theme.dart';
import '../../widgets/brand_lockup.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, required this.store});
  final AppStore store;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  var _obscure = true;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    final err = await widget.store.signUp(
      name: _name.text,
      email: _email.text,
      phone: _phone.text,
      password: _password.text,
      confirm: _confirm.text,
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
        title: const Text('Kayıt ol'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        children: [
          const Center(child: BrandLockup(height: 36)),
          const SizedBox(height: 24),
          TextField(
            controller: _name,
            textCapitalization: TextCapitalization.words,
            decoration: _field('Ad soyad'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: _field('E-posta'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            decoration: _field('Telefon (isteğe bağlı)'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _password,
            obscureText: _obscure,
            decoration: _field('Şifre (en az 6 karakter)').copyWith(
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _confirm,
            obscureText: _obscure,
            decoration: _field('Şifre tekrar'),
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
            child: const Text('Hesap oluştur'),
          ),
          const SizedBox(height: 12),
          const Text(
            'Kayıt olarak kullanım koşullarını kabul etmiş olursunuz. Şifre şimdilik yalnızca bu cihazda güvenli saklanır.',
            style: TextStyle(color: Ck.mute, fontSize: 12, height: 1.45),
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
