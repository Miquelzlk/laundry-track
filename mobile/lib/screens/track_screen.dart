import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/api.dart';
import '../core/format.dart';
import '../core/theme.dart';
import '../models/models.dart';
import '../widgets/common.dart';
import '../widgets/order_widgets.dart';

class TrackScreen extends StatefulWidget {
  const TrackScreen({super.key});

  @override
  State<TrackScreen> createState() => _TrackScreenState();
}

class _TrackScreenState extends State<TrackScreen> {
  final _nota = TextEditingController();
  final _hp = TextEditingController();
  Order? _o;
  bool _loading = false;
  String? _err;
  String _qNota = '';
  String _qHp = '';

  @override
  void dispose() {
    _nota.dispose();
    _hp.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final nota = _nota.text.trim();
    final hp = _hp.text.trim();
    if (nota.isEmpty || hp.length != 4) {
      setState(() {
        _err = 'Isi nomor nota dan 4 digit terakhir nomor HP.';
      });
      return;
    }
    setState(() {
      _loading = true;
      _err = null;
    });
    try {
      final j = await ApiClient.post('/track', {
        'no_nota': nota,
        'hp_akhir': hp,
      }, auth: false);
      if (!mounted) return;
      setState(() {
        _o = Order.fromJson(j['data']);
        _qNota = nota;
        _qHp = hp;
      });
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _err = e.message;
          _o = null;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _respond(String aksi, {DateTime? usulan}) async {
    setState(() {
      _loading = true;
    });
    try {
      final j = await ApiClient.post('/track/konfirmasi', {
        'no_nota': _qNota,
        'hp_akhir': _qHp,
        'aksi': aksi,
        if (usulan != null) 'usulan_jadwal': apiDate(usulan),
      }, auth: false);
      if (!mounted) return;
      setState(() {
        _o = Order.fromJson(j['data']);
      });
      toast(context, 'Respons Anda sudah dikirim ke pihak laundry.');
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

  Future<void> _propose() async {
    final d = await pickDateTime(context, initial: _o?.jadwalAntar);
    if (d != null) await _respond('usul', usulan: d);
  }

  Widget _result(Order o) {
    final canRespond = o.jadwalAntar != null && o.status != 'selesai';
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: C.ink.o(.06),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          o.noNota,
                          style: mono(13, w: FontWeight.w700, color: C.muted),
                        ),
                        const Spacer(),
                        StatusPill(o.status),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(o.nama, style: tx(22, w: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(
                      '${o.layanan}  ·  ${beratFmt(o.beratKg)} kg',
                      style: tx(13.5, color: C.muted),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              const Perforation(),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sisa bayar',
                          style: tx(11, color: C.muted, w: FontWeight.w600),
                        ),
                        Text(
                          o.lunas ? 'Lunas' : rupiah(o.sisaBayar),
                          style: tx(
                            17,
                            w: FontWeight.w800,
                            color: o.lunas ? C.leaf : C.coral,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Total tagihan',
                          style: tx(11, color: C.muted, w: FontWeight.w600),
                        ),
                        Text(
                          rupiah(o.totalHarga),
                          style: tx(17, w: FontWeight.w800),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PanelTitle(
                icon: Icons.track_changes_rounded,
                text: 'Progres cucian',
              ),
              const SizedBox(height: 18),
              StatusStepper(status: o.status),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SchedulePanel(
          o: o,
          actions: canRespond
              ? [
                  FilledButton.icon(
                    onPressed: _loading ? null : () => _respond('setuju'),
                    icon: const Icon(Icons.check_circle_rounded),
                    label: const Text('Saya ada di rumah'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _loading ? null : _propose,
                    icon: const Icon(Icons.edit_calendar_rounded),
                    label: const Text('Usulkan jam lain'),
                  ),
                ]
              : const [],
        ),
        const SizedBox(height: 14),
        PaymentPanel(o: o),
        const SizedBox(height: 14),
        TimelinePanel(logs: o.riwayat),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lacak cucian')),
      body: Wide(
        max: 640,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
          children: [
            Panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const PanelTitle(
                    icon: Icons.manage_search_rounded,
                    text: 'Cari nota Anda',
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.only(left: 44),
                    child: Text(
                      'Nomor nota ada di struk. Verifikasi dengan 4 digit terakhir nomor HP Anda.',
                      style: tx(12.5, color: C.muted, h: 1.5),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nota,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      labelText: 'Nomor nota',
                      hintText: 'LDR-261013-001',
                      prefixIcon: Icon(Icons.tag_rounded),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _hp,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onSubmitted: (_) => _search(),
                    decoration: const InputDecoration(
                      labelText: '4 digit terakhir nomor HP',
                      counterText: '',
                      prefixIcon: Icon(Icons.phone_android_rounded),
                    ),
                  ),
                  if (_err != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: C.coral.o(.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: C.coral.o(.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            size: 20,
                            color: C.coral,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _err!,
                              style: tx(13, w: FontWeight.w600, h: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _loading ? null : _search,
                      icon: _loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.search_rounded),
                      label: Text(_loading ? 'Mencari...' : 'Lacak sekarang'),
                    ),
                  ),
                ],
              ),
            ),
            if (_o != null) ...[const SizedBox(height: 16), _result(_o!)],
          ],
        ),
      ),
    );
  }
}
