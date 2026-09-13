import 'package:flutter/material.dart';

import '../../state/app_store.dart';
import '../../theme.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key, required this.store});
  final AppStore store;

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    final err = await widget.store.changePassword(
      current: _current.text,
      next: _next.text,
      confirm: _confirm.text,
    );
    if (!mounted) return;
    if (err != null) {
      setState(() => _error = err);
      return;
    }
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Şifre güncellendi')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Ck.bg,
      appBar: AppBar(
        backgroundColor: Ck.bg,
        title: const Text('Şifre değiştir'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          TextField(
            controller: _current,
            obscureText: true,
            decoration: _field('Mevcut şifre'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _next,
            obscureText: true,
            decoration: _field('Yeni şifre'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _confirm,
            obscureText: true,
            decoration: _field('Yeni şifre tekrar'),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: Ck.danger)),
          ],
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _submit,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              backgroundColor: Ck.mint,
              foregroundColor: Colors.white,
            ),
            child: const Text('Kaydet'),
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
