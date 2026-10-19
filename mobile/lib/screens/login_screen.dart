import 'package:flutter/material.dart';

import '../core/api.dart';
import '../core/theme.dart';
import '../state/session.dart';
import '../widgets/common.dart';
import 'track_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController(text: 'admin@laundry.test');
  final _pass = TextEditingController(text: 'admin123');
  bool _hide = true;
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_email.text.trim().isEmpty || _pass.text.isEmpty) {
      toast(context, 'Isi email dan kata sandi.', error: true);
      return;
    }
    setState(() {
      _loading = true;
    });
    try {
      await Session.instance.login(_email.text.trim(), _pass.text);
    } on ApiException catch (e) {
      if (mounted) toast(context, e.message, error: true);
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Widget _feature(IconData icon, String title, String sub) => Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.o(.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: tx(15, w: FontWeight.w700, color: Colors.white),
              ),
              const SizedBox(height: 2),
              Text(sub, style: tx(13, color: Colors.white.o(.7), h: 1.4)),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _brandPanel({required bool compact}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 24 : 48),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [C.ink, C.petrol],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: !compact,
        child: Column(
          mainAxisAlignment: compact
              ? MainAxisAlignment.start
              : MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const BrandMark(size: 48),
                const SizedBox(width: 12),
                Text(
                  'Bilas',
                  style: tx(26, w: FontWeight.w800, color: Colors.white),
                ),
              ],
            ),
            SizedBox(height: compact ? 20 : 40),
            Text(
              'Cucian beres,\nstatus jelas.',
              style: tx(
                compact ? 28 : 40,
                w: FontWeight.w800,
                color: Colors.white,
                h: 1.12,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Kelola nota, DP, dan jadwal antar laundry kiloan dalam satu aplikasi.',
              style: tx(14, color: Colors.white.o(.72), h: 1.5),
            ),
            if (!compact) ...[
              const SizedBox(height: 36),
              _feature(
                Icons.track_changes_rounded,
                'Pelacakan status',
                'Pelanggan memantau cucian tanpa perlu bertanya.',
              ),
              _feature(
                Icons.account_balance_wallet_rounded,
                'DP tercatat rapi',
                'Sisa pelunasan dihitung otomatis dari setiap pembayaran.',
              ),
              _feature(
                Icons.event_available_rounded,
                'Jadwal antar terkonfirmasi',
                'Pelanggan konfirmasi atau usul jam lain.',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _form() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Masuk', style: tx(28, w: FontWeight.w800)),
              const SizedBox(height: 6),
              Text(
                'Khusus pemilik atau admin laundry.',
                style: tx(14, color: C.muted),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.alternate_email_rounded),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _pass,
                obscureText: _hide,
                onSubmitted: (_) => _login(),
                decoration: InputDecoration(
                  labelText: 'Kata sandi',
                  prefixIcon: const Icon(Icons.lock_rounded),
                  suffixIcon: IconButton(
                    onPressed: () => setState(() {
                      _hide = !_hide;
                    }),
                    icon: Icon(
                      _hide
                          ? Icons.visibility_rounded
                          : Icons.visibility_off_rounded,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _loading ? null : _login,
                  icon: _loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.login_rounded),
                  label: Text(_loading ? 'Memproses...' : 'Masuk'),
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'untuk pelanggan',
                      style: tx(12, color: C.muted, w: FontWeight.w600),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TrackScreen()),
                  ),
                  icon: const Icon(Icons.manage_search_rounded),
                  label: const Text('Lacak cucian saya'),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton.icon(
                  onPressed: () => showServerSheet(context),
                  icon: const Icon(Icons.dns_rounded, size: 18),
                  label: const Text('Alamat server'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, c) {
          if (c.maxWidth >= 860) {
            return Row(
              children: [
                Expanded(flex: 5, child: _brandPanel(compact: false)),
                Expanded(flex: 4, child: _form()),
              ],
            );
          }
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: c.maxHeight),
              child: Column(children: [_brandPanel(compact: true), _form()]),
            ),
          );
        },
      ),
    );
  }
}
