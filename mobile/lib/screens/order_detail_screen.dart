import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/api.dart';
import '../core/config.dart';
import '../core/format.dart';
import '../core/theme.dart';
import '../models/models.dart';
import '../state/session.dart';
import '../widgets/common.dart';
import '../widgets/order_widgets.dart';

class OrderDetailScreen extends StatefulWidget {
  final int orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  Order? _o;
  String? _err;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _err = null;
    });
    try {
      final j = await ApiClient.get('/orders/${widget.orderId}');
      if (!mounted) return;
      setState(() {
        _o = Order.fromJson(j['data']);
      });
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _err = e.message;
        });
      }
    }
  }

  Future<void> _act(Future<dynamic> Function() f, {String? okMessage}) async {
    setState(() {
      _busy = true;
    });
    try {
      final j = await f();
      if (!mounted) return;
      setState(() {
        _o = Order.fromJson(j['data']);
      });
      DataBus.i.bump();
      if (okMessage != null) toast(context, okMessage);
    } on ApiException catch (e) {
      if (mounted) toast(context, e.message, error: true);
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  Future<void> _setStatus(String s) async {
    final o = _o!;
    if (s == 'selesai' && !o.lunas) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text('Nota belum lunas', style: tx(18, w: FontWeight.w800)),
          content: Text(
            'Masih ada sisa pembayaran ${rupiah(o.sisaBayar)}. Tetap tandai selesai?',
            style: tx(14, color: C.muted, h: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Tetap selesai'),
            ),
          ],
        ),
      );
      if (ok != true) return;
    }
    await _act(
      () => ApiClient.patch('/orders/${o.id}/status', {'status': s}),
      okMessage: 'Status diubah menjadi ${statusMeta(s).label}.',
    );
  }

  Future<void> _pay() async {
    final o = _o!;
    final r = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _PaySheet(sisa: o.sisaBayar),
    );
    if (r == null) return;
    await _act(
      () => ApiClient.post('/orders/${o.id}/pembayaran', r),
      okMessage: 'Pembayaran dicatat.',
    );
  }

  Future<void> _schedule() async {
    final o = _o!;
    final d = await pickDateTime(context, initial: o.jadwalAntar);
    if (d == null) return;
    await _act(
      () => ApiClient.patch('/orders/${o.id}/jadwal', {
        'jadwal_antar': apiDate(d),
      }),
      okMessage: 'Jadwal antar disimpan.',
    );
  }

  Future<void> _approve() async {
    final o = _o!;
    await _act(
      () => ApiClient.patch('/orders/${o.id}/jadwal', {
        'jadwal_antar': apiDate(o.usulanJadwal!),
        'setujui': true,
      }),
      okMessage: 'Usulan pelanggan disetujui.',
    );
  }

  String _link(Order o) =>
      '${AppConfig.baseUrl}/lacak?nota=${Uri.encodeQueryComponent(o.noNota)}&hp=${o.hpAkhir}';

  String _waText(Order o) {
    final b = StringBuffer('Halo ${o.nama}, ');
    switch (o.status) {
      case 'proses':
        b.write('cucian Anda (nota ${o.noNota}) sedang kami proses.');
        break;
      case 'siap_diantar':
        b.write(
          'cucian Anda (nota ${o.noNota}) sudah selesai dan siap diantar.',
        );
        if (o.jadwalAntar != null) {
          b.write(
            ' Jadwal antar: ${tglJam(o.jadwalAntar!)}. Mohon konfirmasi kehadiran Anda lewat tautan di bawah.',
          );
        }
        break;
      default:
        b.write(
          'cucian Anda (nota ${o.noNota}) sudah diserahkan. Terima kasih telah mempercayakan cucian Anda kepada kami.',
        );
    }
    if (!o.lunas) b.write('\nSisa pembayaran: ${rupiah(o.sisaBayar)}.');
    b.write('\nPantau status: ${_link(o)}');
    return b.toString();
  }

  Future<void> _whatsapp() async {
    final o = _o!;
    var d = o.noHp.replaceAll(RegExp(r'\D'), '');
    if (d.startsWith('0')) d = '62${d.substring(1)}';
    final uri = Uri.parse(
      'https://wa.me/$d?text=${Uri.encodeComponent(_waText(o))}',
    );
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && mounted)
        toast(context, 'Tidak dapat membuka WhatsApp.', error: true);
    } catch (_) {
      if (mounted) toast(context, 'Tidak dapat membuka WhatsApp.', error: true);
    }
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: _link(_o!)));
    if (mounted) toast(context, 'Tautan pelacakan disalin.');
  }

  Widget _infoLine(IconData icon, String text) => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Row(
      children: [
        Icon(icon, size: 16, color: C.muted),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: tx(13.5, color: C.muted, w: FontWeight.w600),
          ),
        ),
      ],
    ),
  );

  Widget _header(Order o) => Container(
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
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 6),
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
              const SizedBox(height: 14),
              Text(o.nama, style: tx(24, w: FontWeight.w800)),
              _infoLine(Icons.phone_android_rounded, o.noHp),
              if (o.alamat != null && o.alamat!.isNotEmpty)
                _infoLine(Icons.place_rounded, o.alamat!),
              if (o.catatan != null && o.catatan!.isNotEmpty)
                _infoLine(Icons.notes_rounded, o.catatan!),
              const SizedBox(height: 12),
            ],
          ),
        ),
        const Perforation(),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 18),
          child: Row(
            children: [
              Icon(serviceIcon(o.layanan), color: C.lagoon),
              const SizedBox(width: 10),
              Expanded(
                child: Text(o.layanan, style: tx(14, w: FontWeight.w700)),
              ),
              Text(
                '${beratFmt(o.beratKg)} kg',
                style: tx(14, w: FontWeight.w800),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _progress(Order o) {
    final idx = statusOrder.indexOf(o.status);
    final next = idx < statusOrder.length - 1 ? statusOrder[idx + 1] : null;
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PanelTitle(
            icon: Icons.track_changes_rounded,
            text: 'Progres cucian',
          ),
          const SizedBox(height: 18),
          StatusStepper(status: o.status),
          const SizedBox(height: 18),
          if (next != null)
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _busy ? null : () => _setStatus(next),
                icon: Icon(statusMeta(next).icon),
                label: Text(
                  next == 'siap_diantar'
                      ? 'Tandai siap diantar'
                      : 'Tandai selesai dan diserahkan',
                ),
              ),
            ),
          if (idx > 0)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _busy
                    ? null
                    : () => _setStatus(statusOrder[idx - 1]),
                icon: const Icon(Icons.undo_rounded, size: 18),
                label: const Text('Kembalikan ke tahap sebelumnya'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _share(Order o) => Panel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PanelTitle(icon: Icons.forum_rounded, text: 'Kabari pelanggan'),
        const SizedBox(height: 14),
        Text(
          'Kirim status terbaru dan tautan pelacakan ke pelanggan.',
          style: tx(13.5, color: C.muted, h: 1.5),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            FilledButton.icon(
              onPressed: _whatsapp,
              style: FilledButton.styleFrom(backgroundColor: C.leaf),
              icon: const Icon(Icons.send_rounded),
              label: const Text('Kirim lewat WhatsApp'),
            ),
            OutlinedButton.icon(
              onPressed: _copy,
              icon: const Icon(Icons.content_copy_rounded),
              label: const Text('Salin tautan'),
            ),
          ],
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final o = _o;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail nota'),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh_rounded)),
        ],
      ),
      body: o == null
          ? (_err != null
                ? ErrorState(message: _err!, onRetry: _load)
                : const Center(
                    child: CircularProgressIndicator(color: C.lagoon),
                  ))
          : Wide(
              max: 720,
              child: RefreshIndicator(
                color: C.lagoon,
                onRefresh: _load,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                  children: [
                    _header(o),
                    const SizedBox(height: 14),
                    _progress(o),
                    const SizedBox(height: 14),
                    SchedulePanel(
                      o: o,
                      actions: [
                        OutlinedButton.icon(
                          onPressed: _busy ? null : _schedule,
                          icon: const Icon(Icons.edit_calendar_rounded),
                          label: Text(
                            o.jadwalAntar == null
                                ? 'Atur jadwal'
                                : 'Ubah jadwal',
                          ),
                        ),
                        if (o.konfirmasi == 'usul_ulang' &&
                            o.usulanJadwal != null)
                          FilledButton.icon(
                            onPressed: _busy ? null : _approve,
                            icon: const Icon(Icons.thumb_up_alt_rounded),
                            label: const Text('Setujui usulan'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    PaymentPanel(
                      o: o,
                      action: o.lunas
                          ? null
                          : SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: _busy ? null : _pay,
                                icon: const Icon(Icons.add_card_rounded),
                                label: const Text('Catat pembayaran'),
                              ),
                            ),
                    ),
                    const SizedBox(height: 14),
                    _share(o),
                    const SizedBox(height: 14),
                    TimelinePanel(logs: o.riwayat),
                  ],
                ),
              ),
            ),
    );
  }
}

class _PaySheet extends StatefulWidget {
  final int sisa;
  const _PaySheet({required this.sisa});

  @override
  State<_PaySheet> createState() => _PaySheetState();
}

class _PaySheetState extends State<_PaySheet> {
  final _amount = TextEditingController();
  final _note = TextEditingController();

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  void _save() {
    final v = int.tryParse(_amount.text) ?? 0;
    if (v <= 0) {
      toast(context, 'Masukkan jumlah pembayaran.', error: true);
      return;
    }
    if (v > widget.sisa) {
      toast(context, 'Jumlah melebihi sisa tagihan.', error: true);
      return;
    }
    Navigator.pop(context, {'jumlah': v, 'catatan': _note.text.trim()});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        22,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PanelTitle(
            icon: Icons.add_card_rounded,
            text: 'Catat pembayaran',
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 44),
            child: Text(
              'Sisa tagihan ${rupiah(widget.sisa)}',
              style: tx(13, color: C.coral, w: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amount,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Jumlah dibayar',
              prefixText: 'Rp ',
              prefixIcon: Icon(Icons.payments_rounded),
            ),
          ),
          const SizedBox(height: 10),
          ActionChip(
            onPressed: () => _amount.text = '${widget.sisa}',
            avatar: const Icon(
              Icons.done_all_rounded,
              size: 18,
              color: C.lagoon,
            ),
            label: Text('Lunasi sisa (${rupiah(widget.sisa)})'),
            labelStyle: tx(12.5, w: FontWeight.w700),
            backgroundColor: C.foam,
            side: BorderSide.none,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(99),
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
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check_rounded),
              label: const Text('Simpan pembayaran'),
            ),
          ),
        ],
      ),
    );
  }
}
