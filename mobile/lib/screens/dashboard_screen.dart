import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/api.dart';
import '../core/config.dart';
import '../core/format.dart';
import '../core/theme.dart';
import '../models/models.dart';
import '../state/session.dart';
import '../widgets/common.dart';
import 'order_detail_screen.dart';
import 'order_form_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<Dashboard> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetch();
    DataBus.i.addListener(_reload);
  }

  @override
  void dispose() {
    DataBus.i.removeListener(_reload);
    super.dispose();
  }

  Future<Dashboard> _fetch() async {
    final j = await ApiClient.get('/dashboard');
    return Dashboard.fromJson(j['data']);
  }

  void _reload() {
    if (!mounted) return;
    setState(() {
      _future = _fetch();
    });
  }

  Widget _header() {
    final h = DateTime.now().hour;
    final sapaan = h < 11
        ? 'Selamat pagi'
        : (h < 15
              ? 'Selamat siang'
              : (h < 18 ? 'Selamat sore' : 'Selamat malam'));
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 16),
      child: Row(
        children: [
          const BrandMark(size: 46),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sapaan,
                  style: tx(13, color: C.muted, w: FontWeight.w600),
                ),
                Text(
                  AppConfig.userName ?? 'Pemilik',
                  style: tx(20, w: FontWeight.w800),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_horiz_rounded),
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            onSelected: (v) {
              if (v == 'server') showServerSheet(context);
              if (v == 'logout') Session.instance.logout();
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'server',
                child: Row(
                  children: [
                    const Icon(Icons.dns_rounded, size: 20, color: C.muted),
                    const SizedBox(width: 12),
                    Text('Alamat server', style: tx(14, w: FontWeight.w600)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    const Icon(Icons.logout_rounded, size: 20, color: C.danger),
                    const SizedBox(width: 12),
                    Text(
                      'Keluar',
                      style: tx(14, w: FontWeight.w600, color: C.danger),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bubble(double size, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );

  Widget _miniStat(String label, String value) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: tx(12, color: Colors.white.o(.65), w: FontWeight.w600),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: tx(16, w: FontWeight.w800, color: Colors.white),
        ),
      ],
    ),
  );

  Widget _hero(Dashboard d) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [C.ink, C.petrol],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -40,
              top: -40,
              child: _bubble(160, Colors.white.o(.06)),
            ),
            Positioned(
              right: 36,
              bottom: -64,
              child: _bubble(140, C.lagoon.o(.4)),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet_rounded,
                        size: 18,
                        color: Colors.white.o(.7),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Piutang berjalan',
                        style: tx(
                          13,
                          color: Colors.white.o(.75),
                          w: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    rupiah(d.piutang),
                    style: tx(
                      34,
                      w: FontWeight.w800,
                      color: Colors.white,
                      h: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'sisa pelunasan dari seluruh nota',
                    style: tx(12.5, color: Colors.white.o(.6)),
                  ),
                  const SizedBox(height: 18),
                  Container(height: 1, color: Colors.white.o(.12)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _miniStat(
                        'Pemasukan hari ini',
                        rupiah(d.pendapatanHariIni),
                      ),
                      _miniStat('Perlu tanggapan', '${d.perluTanggapan} nota'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const OrderFormScreen(),
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: C.ink,
                    ),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Buat nota baru'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(IconData icon, int n, String label, Color color) => Expanded(
    child: Panel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.o(.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, size: 19, color: color),
          ),
          const SizedBox(height: 12),
          Text('$n', style: tx(26, w: FontWeight.w800)),
          Text(
            label,
            style: tx(12, color: C.muted, w: FontWeight.w600),
          ),
        ],
      ),
    ),
  );

  Widget _scheduleRow(Order o) {
    final j = o.jadwalAntar!;
    Color c;
    switch (o.konfirmasi) {
      case 'dikonfirmasi':
        c = C.leaf;
        break;
      case 'usul_ulang':
        c = C.coral;
        break;
      default:
        c = C.amber;
    }
    final label = o.konfirmasi == 'dikonfirmasi'
        ? 'Terkonfirmasi'
        : (o.konfirmasi == 'usul_ulang' ? 'Usul jam lain' : 'Menunggu');
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: o.id)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 56,
              decoration: BoxDecoration(
                color: C.foam,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('d').format(j),
                    style: tx(18, w: FontWeight.w800, color: C.lagoon),
                  ),
                  Text(
                    DateFormat('MMM', 'id_ID').format(j),
                    style: tx(11, w: FontWeight.w700, color: C.lagoon),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    o.nama,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: tx(15, w: FontWeight.w800),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${DateFormat('HH:mm').format(j)}  ·  ${o.noNota}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: tx(12, color: C.muted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Pill(label: label, color: c),
          ],
        ),
      ),
    );
  }

  List<Widget> _content(Dashboard d) {
    return [
      _hero(d),
      const SizedBox(height: 14),
      Row(
        children: [
          _tile(
            Icons.local_laundry_service_rounded,
            d.proses,
            'Diproses',
            C.amber,
          ),
          const SizedBox(width: 10),
          _tile(Icons.local_shipping_rounded, d.siap, 'Siap diantar', C.sky),
          const SizedBox(width: 10),
          _tile(Icons.verified_rounded, d.selesai, 'Selesai', C.leaf),
        ],
      ),
      if (d.perluTanggapan > 0) ...[
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: C.coral.o(.08),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: C.coral.o(.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.event_busy_rounded, color: C.coral),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${d.perluTanggapan} pelanggan mengusulkan jadwal antar baru. Buka nota untuk menanggapi.',
                  style: tx(13, w: FontWeight.w700, h: 1.4),
                ),
              ),
            ],
          ),
        ),
      ],
      const SizedBox(height: 22),
      Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 10),
        child: Text('Jadwal antar terdekat', style: tx(16, w: FontWeight.w800)),
      ),
      if (d.jadwal.isEmpty)
        const Panel(
          child: EmptyState(
            icon: Icons.event_available_rounded,
            title: 'Belum ada jadwal antar',
            message:
                'Atur jadwal antar pada nota agar pelanggan bisa mengonfirmasi.',
          ),
        )
      else
        Panel(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < d.jadwal.length; i++) ...[
                if (i > 0) const Divider(),
                _scheduleRow(d.jadwal[i]),
              ],
            ],
          ),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Wide(
      child: RefreshIndicator(
        color: C.lagoon,
        onRefresh: () async {
          _reload();
          try {
            await _future;
          } catch (_) {}
        },
        child: FutureBuilder<Dashboard>(
          future: _future,
          builder: (context, snap) {
            final children = <Widget>[_header()];
            if (snap.connectionState != ConnectionState.done) {
              children.add(
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 80),
                  child: Center(
                    child: CircularProgressIndicator(color: C.lagoon),
                  ),
                ),
              );
            } else if (snap.hasError) {
              children.add(
                ErrorState(message: '${snap.error}', onRetry: _reload),
              );
            } else {
              children.addAll(_content(snap.data!));
            }
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: children,
            );
          },
        ),
      ),
    );
  }
}
