import 'dart:async';

import 'package:flutter/material.dart';

import '../core/api.dart';
import '../core/theme.dart';
import '../models/models.dart';
import '../state/session.dart';
import '../widgets/common.dart';
import '../widgets/order_widgets.dart';
import 'order_detail_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final _search = TextEditingController();
  Timer? _debounce;
  String _status = '';
  late Future<List<Order>> _future;

  static const _filters = [
    ['', 'Semua'],
    ['proses', 'Diproses'],
    ['siap_diantar', 'Siap diantar'],
    ['selesai', 'Selesai'],
  ];

  @override
  void initState() {
    super.initState();
    _future = _fetch();
    DataBus.i.addListener(_reload);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    DataBus.i.removeListener(_reload);
    super.dispose();
  }

  Future<List<Order>> _fetch() async {
    final q = _search.text.trim();
    final j = await ApiClient.get(
      '/orders',
      query: {
        if (_status.isNotEmpty) 'status': _status,
        if (q.isNotEmpty) 'q': q,
      },
    );
    return (j['data'] as List)
        .map((e) => Order.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  void _reload() {
    if (!mounted) return;
    setState(() {
      _future = _fetch();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Wide(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Text('Nota', style: tx(26, w: FontWeight.w800)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _search,
              onChanged: (_) {
                _debounce?.cancel();
                _debounce = Timer(const Duration(milliseconds: 350), _reload);
              },
              decoration: InputDecoration(
                hintText: 'Cari nama, nomor HP, atau nomor nota',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _search.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _search.clear();
                          _reload();
                        },
                        icon: const Icon(Icons.close_rounded),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                for (final f in _filters)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      showCheckmark: false,
                      selected: _status == f[0],
                      onSelected: (_) {
                        setState(() {
                          _status = f[0];
                        });
                        _reload();
                      },
                      label: Text(f[1]),
                      labelStyle: tx(
                        13,
                        w: FontWeight.w700,
                        color: _status == f[0] ? Colors.white : C.ink,
                      ),
                      backgroundColor: Colors.white,
                      selectedColor: C.ink,
                      side: BorderSide(color: _status == f[0] ? C.ink : C.line),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: RefreshIndicator(
              color: C.lagoon,
              onRefresh: () async {
                _reload();
                try {
                  await _future;
                } catch (_) {}
              },
              child: FutureBuilder<List<Order>>(
                future: _future,
                builder: (context, snap) {
                  Widget inner;
                  if (snap.connectionState != ConnectionState.done) {
                    inner = const Padding(
                      padding: EdgeInsets.symmetric(vertical: 80),
                      child: Center(
                        child: CircularProgressIndicator(color: C.lagoon),
                      ),
                    );
                  } else if (snap.hasError) {
                    inner = ErrorState(
                      message: '${snap.error}',
                      onRetry: _reload,
                    );
                  } else if (snap.data!.isEmpty) {
                    inner = const EmptyState(
                      icon: Icons.receipt_long_rounded,
                      title: 'Tidak ada nota',
                      message:
                          'Belum ada nota yang cocok. Tekan Nota baru untuk membuat nota pertama.',
                    );
                  } else {
                    inner = Column(
                      children: [
                        for (final o in snap.data!)
                          OrderTicket(
                            o: o,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    OrderDetailScreen(orderId: o.id),
                              ),
                            ),
                          ),
                      ],
                    );
                  }
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                    children: [inner],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
