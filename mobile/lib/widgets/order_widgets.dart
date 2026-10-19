import 'package:flutter/material.dart';

import '../core/format.dart';
import '../core/theme.dart';
import '../models/models.dart';
import 'common.dart';

class OrderTicket extends StatelessWidget {
  final Order o;
  final VoidCallback onTap;
  const OrderTicket({super.key, required this.o, required this.onTap});

  Widget _kv(String k, String v, Color c, {bool end = false}) => Column(
    crossAxisAlignment: end ? CrossAxisAlignment.end : CrossAxisAlignment.start,
    children: [
      Text(
        k,
        style: tx(11, w: FontWeight.w600, color: C.muted),
      ),
      const SizedBox(height: 2),
      Text(
        v,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: tx(14, w: FontWeight.w800, color: c),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
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
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: onTap,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(o.noNota, style: mono(12, color: C.muted)),
                          const Spacer(),
                          StatusPill(o.status),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Initial(o.nama),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  o.nama,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: tx(16, w: FontWeight.w800),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${o.layanan}  ·  ${beratFmt(o.beratKg)} kg',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: tx(12.5, color: C.muted),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
                const Perforation(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 4, 18, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _kv(
                          'Sisa bayar',
                          o.lunas ? 'Lunas' : rupiah(o.sisaBayar),
                          o.lunas ? C.leaf : C.coral,
                        ),
                      ),
                      Expanded(
                        child: _kv(
                          'Jadwal antar',
                          o.jadwalAntar == null
                              ? 'Belum diatur'
                              : tglJam(o.jadwalAntar!),
                          C.ink,
                          end: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class StatusStepper extends StatelessWidget {
  final String status;
  const StatusStepper({super.key, required this.status});

  Widget _node(int i, int idx) {
    final key = statusOrder[i];
    final m = statusMeta(key);
    final done = i <= idx;
    final now = i == idx;
    return SizedBox(
      width: 78,
      child: Column(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: done ? m.color : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: done ? m.color : C.line, width: 2),
              boxShadow: now
                  ? [
                      BoxShadow(
                        color: m.color.o(.25),
                        blurRadius: 0,
                        spreadRadius: 5,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              done ? m.icon : Icons.circle_outlined,
              size: 20,
              color: done ? Colors.white : C.line,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            m.label,
            textAlign: TextAlign.center,
            style: tx(
              12,
              w: now ? FontWeight.w800 : FontWeight.w600,
              color: done ? C.ink : C.muted,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final idx = statusOrder.indexOf(status);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < statusOrder.length; i++) ...[
          if (i > 0)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: i <= idx ? C.lagoon : C.line,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          _node(i, idx),
        ],
      ],
    );
  }
}

class PaymentPanel extends StatelessWidget {
  final Order o;
  final Widget? action;
  const PaymentPanel({super.key, required this.o, this.action});

  Widget _line(String k, String v, {Color? color, bool bold = false}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              k,
              style: tx(13.5, color: C.muted, w: FontWeight.w600),
            ),
            Text(
              v,
              style: tx(
                bold ? 17 : 14,
                w: bold ? FontWeight.w800 : FontWeight.w700,
                color: color ?? C.ink,
              ),
            ),
          ],
        ),
      );

  String _jenis(String j) =>
      j == 'dp' ? 'DP' : (j == 'pelunasan' ? 'Pelunasan' : 'Cicilan');

  @override
  Widget build(BuildContext context) {
    final ratio = o.totalHarga == 0
        ? 0.0
        : (o.totalDibayar / o.totalHarga).clamp(0.0, 1.0).toDouble();
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PanelTitle(
            icon: Icons.account_balance_wallet_rounded,
            text: 'Pembayaran',
          ),
          const SizedBox(height: 14),
          _line('Total tagihan', rupiah(o.totalHarga)),
          _line('Sudah dibayar', rupiah(o.totalDibayar)),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: ratio,
            minHeight: 8,
            borderRadius: BorderRadius.circular(8),
            backgroundColor: C.line,
            color: C.lagoon,
          ),
          const SizedBox(height: 8),
          _line(
            'Sisa pelunasan',
            o.lunas ? 'Lunas' : rupiah(o.sisaBayar),
            color: o.lunas ? C.leaf : C.coral,
            bold: true,
          ),
          if (o.pembayaran.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Divider(),
            for (final p in o.pembayaran)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 9),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: C.leaf.o(.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.south_west_rounded,
                        size: 17,
                        color: C.leaf,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _jenis(p.jenis),
                            style: tx(14, w: FontWeight.w700),
                          ),
                          if (p.waktu != null)
                            Text(
                              tglJam(p.waktu!),
                              style: tx(12, color: C.muted),
                            ),
                        ],
                      ),
                    ),
                    Text(rupiah(p.jumlah), style: tx(14, w: FontWeight.w800)),
                  ],
                ),
              ),
          ],
          if (action != null) ...[const SizedBox(height: 10), action!],
        ],
      ),
    );
  }
}

class SchedulePanel extends StatelessWidget {
  final Order o;
  final List<Widget> actions;
  const SchedulePanel({super.key, required this.o, this.actions = const []});

  @override
  Widget build(BuildContext context) {
    Widget konf() {
      switch (o.konfirmasi) {
        case 'dikonfirmasi':
          return const Pill(
            label: 'Dikonfirmasi pelanggan',
            color: C.leaf,
            icon: Icons.check_circle_rounded,
          );
        case 'usul_ulang':
          return const Pill(
            label: 'Pelanggan mengusulkan jadwal lain',
            color: C.coral,
            icon: Icons.event_busy_rounded,
          );
        default:
          return const Pill(
            label: 'Menunggu konfirmasi pelanggan',
            color: C.amber,
            icon: Icons.hourglass_top_rounded,
          );
      }
    }

    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PanelTitle(
            icon: Icons.event_available_rounded,
            text: 'Jadwal antar',
          ),
          const SizedBox(height: 14),
          if (o.jadwalAntar == null)
            Text('Belum dijadwalkan.', style: tx(14, color: C.muted))
          else ...[
            Text(tglJam(o.jadwalAntar!), style: tx(20, w: FontWeight.w800)),
            const SizedBox(height: 10),
            Align(alignment: Alignment.centerLeft, child: konf()),
          ],
          if (o.konfirmasi == 'usul_ulang' && o.usulanJadwal != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: C.coral.o(.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: C.coral.o(.3)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.edit_calendar_rounded,
                    size: 20,
                    color: C.coral,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Usulan pelanggan: ${tglJam(o.usulanJadwal!)}',
                      style: tx(13.5, w: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (actions.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(spacing: 10, runSpacing: 10, children: actions),
          ],
        ],
      ),
    );
  }
}

class TimelinePanel extends StatelessWidget {
  final List<StatusLog> logs;
  const TimelinePanel({super.key, required this.logs});

  @override
  Widget build(BuildContext context) {
    final items = logs.reversed.toList();
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PanelTitle(icon: Icons.history_rounded, text: 'Riwayat status'),
          const SizedBox(height: 14),
          if (items.isEmpty)
            Text('Belum ada riwayat.', style: tx(13.5, color: C.muted)),
          for (var i = 0; i < items.length; i++)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: 22,
                    child: Column(
                      children: [
                        const SizedBox(height: 4),
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: statusMeta(items[i].status).color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        if (i < items.length - 1)
                          Expanded(child: Container(width: 2, color: C.line)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            statusMeta(items[i].status).label,
                            style: tx(14, w: FontWeight.w700),
                          ),
                          if (items[i].waktu != null)
                            Text(
                              tglJam(items[i].waktu!),
                              style: tx(12, color: C.muted),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
