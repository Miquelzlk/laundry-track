import 'dart:async';

import 'package:flutter/material.dart';

import '../core/api.dart';
import '../core/theme.dart';
import '../models/models.dart';
import '../state/session.dart';
import '../widgets/common.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final _search = TextEditingController();
  Timer? _debounce;
  late Future<List<Customer>> _future;

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
            child: Text('Pelanggan', style: tx(26, w: FontWeight.w800)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _search,
              onChanged: (_) {
                _debounce?.cancel();
                _debounce = Timer(const Duration(milliseconds: 350), _reload);
              },
              decoration: const InputDecoration(
                hintText: 'Cari nama atau nomor HP',
                prefixIcon: Icon(Icons.search_rounded),
              ),
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
              child: FutureBuilder<List<Customer>>(
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
                      icon: Icons.groups_rounded,
                      title: 'Belum ada pelanggan',
                      message:
                          'Pelanggan otomatis tersimpan saat Anda membuat nota.',
                    );
                  } else {
                    final list = snap.data!;
                    inner = Panel(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          for (var i = 0; i < list.length; i++) ...[
                            if (i > 0) const Divider(),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  Initial(list[i].nama),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          list[i].nama,
                                          style: tx(15, w: FontWeight.w800),
                                        ),
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.phone_android_rounded,
                                              size: 14,
                                              color: C.muted,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              list[i].noHp,
                                              style: tx(12.5, color: C.muted),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Pill(
                                    label: '${list[i].jumlahNota} nota',
                                    color: C.lagoon,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
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
