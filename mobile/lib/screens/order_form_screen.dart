import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/api.dart';
import '../core/format.dart';
import '../core/theme.dart';
import '../models/models.dart';
import '../state/session.dart';
import '../widgets/common.dart';
import 'order_detail_screen.dart';

class OrderFormScreen extends StatefulWidget {
  const OrderFormScreen({super.key});

  @override
  State<OrderFormScreen> createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends State<OrderFormScreen> {
  final _phone = TextEditingController();
  final _name = TextEditingController();
  final _addr = TextEditingController();
  final _berat = TextEditingController(text: '1');
  final _dp = TextEditingController();
  final _note = TextEditingController();

  List<Service> _services = [];
  Service? _service;
  DateTime? _jadwal;
  bool _loading = true;
  bool _saving = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _berat.addListener(_tick);
    _dp.addListener(_tick);
    _loadServices();
  }

  @override
  void dispose() {
    for (final c in [_phone, _name, _addr, _berat, _dp, _note]) {
      c.dispose();
    }
    super.dispose();
  }

  void _tick() {
    if (mounted) setState(() {});
  }

  Future<void> _loadServices() async {
    try {
      final j = await ApiClient.get('/services');
      final list = (j['data'] as List)
          .map((e) => Service.fromJson(e as Map<String, dynamic>))
          .toList();
      if (!mounted) return;
      setState(() {
        _services = list;
        _service = list.isNotEmpty ? list.first : null;
        _loading = false;
        _loadError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = '$e';
        _loading = false;
      });
    }
  }

  double get _kg => double.tryParse(_berat.text.replaceAll(',', '.')) ?? 0;
  int get _total => _service == null ? 0 : (_kg * _service!.hargaPerKg).round();
  int get _dpVal => int.tryParse(_dp.text) ?? 0;

  void _stepKg(double delta) {
    final v = (_kg + delta).clamp(0.0, 500.0).toDouble();
    _berat.text = beratFmt(v);
  }

  Future<void> _pickCustomer() async {
    final c = await showModalBottomSheet<Customer>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _CustomerPicker(),
    );
    if (c != null) {
      setState(() {
        _phone.text = c.noHp;
        _name.text = c.nama;
        _addr.text = c.alamat ?? '';
      });
    }
  }

  Future<void> _pickJadwal() async {
    final d = await pickDateTime(context, initial: _jadwal);
    if (d != null) {
      setState(() {
        _jadwal = d;
      });
    }
  }

  Future<void> _submit() async {
    final hp = _phone.text.replaceAll(RegExp(r'\D'), '');
    String? err;
    if (_name.text.trim().isEmpty) {
      err = 'Nama pelanggan wajib diisi.';
    } else if (hp.length < 9) {
      err = 'Nomor HP tidak valid.';
    } else if (_service == null) {
      err = 'Pilih jenis layanan.';
    } else if (_kg <= 0) {
      err = 'Berat cucian harus lebih dari 0.';
    } else if (_dpVal > _total) {
      err = 'DP tidak boleh melebihi total tagihan.';
    }
    if (err != null) {
      toast(context, err, error: true);
      return;
    }

    setState(() {
      _saving = true;
    });
    try {
      final j = await ApiClient.post('/orders', {
        'nama': _name.text.trim(),
        'no_hp': hp,
        'alamat': _addr.text.trim(),
        'service_id': _service!.id,
        'berat_kg': _kg,
        'dp': _dpVal,
        'jadwal_antar': _jadwal == null ? null : apiDate(_jadwal!),
        'catatan': _note.text.trim(),
      });
      final o = Order.fromJson(j['data']);
      DataBus.i.bump();
      if (!mounted) return;
      toast(context, 'Nota ${o.noNota} berhasil dibuat.');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: o.id)),
      );
    } on ApiException catch (e) {
      if (mounted) toast(context, e.message, error: true);
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  Widget _section(
    IconData icon,
    String title,
    List<Widget> children, {
    Widget? trailing,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PanelTitle(icon: icon, text: title, trailing: trailing),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    ),
  );

  Widget _serviceTile(Service s) {
    final sel = _service?.id == s.id;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => setState(() {
        _service = s;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: sel ? C.foam : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: sel ? C.lagoon : C.line,
            width: sel ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(serviceIcon(s.nama), color: sel ? C.lagoon : C.muted),
            const SizedBox(height: 8),
            Text(s.nama, style: tx(13, w: FontWeight.w700)),
            const SizedBox(height: 2),
            Text('${rupiah(s.hargaPerKg)}/kg', style: tx(12, color: C.muted)),
          ],
        ),
      ),
    );
  }

  Widget _quick(String label, VoidCallback onTap) => ActionChip(
    onPressed: onTap,
    label: Text(label),
    labelStyle: tx(12.5, w: FontWeight.w700),
    backgroundColor: Colors.white,
    side: const BorderSide(color: C.line),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
  );

  @override
  Widget build(BuildContext context) {
    final sisa = (_total - _dpVal).clamp(0, 1 << 31);
    return Scaffold(
      appBar: AppBar(title: const Text('Nota baru')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: C.lagoon))
          : _loadError != null
          ? ErrorState(
              message: _loadError!,
              onRetry: () {
                setState(() {
                  _loading = true;
                });
                _loadServices();
              },
            )
          : Wide(
              max: 720,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                children: [
                  _section(
                    Icons.person_rounded,
                    'Pelanggan',
                    [
                      TextField(
                        controller: _phone,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9+ ]')),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Nomor HP',
                          prefixIcon: Icon(Icons.phone_android_rounded),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _name,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'Nama pelanggan',
                          prefixIcon: Icon(Icons.badge_rounded),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _addr,
                        decoration: const InputDecoration(
                          labelText: 'Alamat (opsional)',
                          prefixIcon: Icon(Icons.place_rounded),
                        ),
                      ),
                    ],
                    trailing: TextButton.icon(
                      onPressed: _pickCustomer,
                      icon: const Icon(Icons.person_search_rounded, size: 18),
                      label: const Text('Pilih'),
                    ),
                  ),
                  _section(Icons.local_laundry_service_rounded, 'Cucian', [
                    LayoutBuilder(
                      builder: (context, cons) {
                        final w = (cons.maxWidth - 10) / 2;
                        return Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            for (final s in _services)
                              SizedBox(width: w, child: _serviceTile(s)),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Berat cucian',
                      style: tx(12.5, w: FontWeight.w700, color: C.muted),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        IconButton.filledTonal(
                          onPressed: () => _stepKg(-0.5),
                          icon: const Icon(Icons.remove_rounded),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _berat,
                            textAlign: TextAlign.center,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9.,]'),
                              ),
                            ],
                            style: tx(22, w: FontWeight.w800),
                            decoration: const InputDecoration(
                              suffixText: 'kg',
                              prefixIcon: Icon(Icons.scale_rounded),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton.filledTonal(
                          onPressed: () => _stepKg(0.5),
                          icon: const Icon(Icons.add_rounded),
                        ),
                      ],
                    ),
                  ]),
                  _section(Icons.account_balance_wallet_rounded, 'Pembayaran', [
                    TextField(
                      controller: _dp,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: 'DP (opsional)',
                        prefixText: 'Rp ',
                        prefixIcon: Icon(Icons.payments_rounded),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _quick('Tanpa DP', () => _dp.text = ''),
                        _quick(
                          'DP 50%',
                          () => _dp.text = '${(_total / 2).round()}',
                        ),
                        _quick('Bayar lunas', () => _dp.text = '$_total'),
                      ],
                    ),
                  ]),
                  _section(Icons.event_available_rounded, 'Jadwal antar', [
                    OutlinedButton.icon(
                      onPressed: _pickJadwal,
                      icon: const Icon(Icons.edit_calendar_rounded),
                      label: Text(
                        _jadwal == null
                            ? 'Atur jadwal antar (opsional)'
                            : tglJam(_jadwal!),
                      ),
                    ),
                    if (_jadwal != null)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () => setState(() {
                            _jadwal = null;
                          }),
                          icon: const Icon(Icons.close_rounded, size: 18),
                          label: const Text('Hapus jadwal'),
                        ),
                      ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _note,
                      decoration: const InputDecoration(
                        labelText: 'Catatan (opsional)',
                        prefixIcon: Icon(Icons.notes_rounded),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
      bottomNavigationBar: _loading || _loadError != null
          ? null
          : Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: C.line)),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total tagihan',
                            style: tx(12, color: C.muted, w: FontWeight.w600),
                          ),
                          Text(
                            rupiah(_total),
                            style: tx(20, w: FontWeight.w800),
                          ),
                          Text(
                            'Sisa bayar ${rupiah(sisa)}',
                            style: tx(12, color: C.coral, w: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: _saving ? null : _submit,
                      icon: _saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check_rounded),
                      label: Text(_saving ? 'Menyimpan...' : 'Simpan nota'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _CustomerPicker extends StatefulWidget {
  const _CustomerPicker();

  @override
  State<_CustomerPicker> createState() => _CustomerPickerState();
}

class _CustomerPickerState extends State<_CustomerPicker> {
  final _search = TextEditingController();
  Timer? _debounce;
  late Future<List<Customer>> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetch();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  Future<List<Customer>> _fetch() async {
    final q = _search.text.trim();
    final j = await ApiClient.get(
      '/customers',
      query: {if (q.isNotEmpty) 'q': q},
    );
    return (j['data'] as List)
        .map((e) => Customer.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * .72,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Column(
            children: [
              const PanelTitle(
                icon: Icons.person_search_rounded,
                text: 'Pilih pelanggan lama',
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _search,
                onChanged: (_) {
                  _debounce?.cancel();
                  _debounce = Timer(const Duration(milliseconds: 300), () {
                    if (mounted) {
                      setState(() {
                        _future = _fetch();
                      });
                    }
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'Cari nama atau nomor HP',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: FutureBuilder<List<Customer>>(
                  future: _future,
                  builder: (context, snap) {
                    if (snap.connectionState != ConnectionState.done) {
                      return const Center(
                        child: CircularProgressIndicator(color: C.lagoon),
                      );
                    }
                    if (snap.hasError) {
                      return Center(
                        child: Text(
                          '${snap.error}',
                          style: tx(13, color: C.muted),
                        ),
                      );
                    }
                    final list = snap.data!;
                    if (list.isEmpty) {
                      return const EmptyState(
                        icon: Icons.groups_rounded,
                        title: 'Tidak ditemukan',
                        message: 'Isi data pelanggan baru pada formulir.',
                      );
                    }
                    return ListView.separated(
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (_, i) => ListTile(
                        onTap: () => Navigator.pop(context, list[i]),
                        leading: Initial(list[i].nama),
                        title: Text(
                          list[i].nama,
                          style: tx(15, w: FontWeight.w800),
                        ),
                        subtitle: Text(
                          list[i].noHp,
                          style: tx(12.5, color: C.muted),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right_rounded,
                          color: C.muted,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
