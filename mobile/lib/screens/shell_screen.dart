import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../widgets/common.dart';
import 'customers_screen.dart';
import 'dashboard_screen.dart';
import 'order_form_screen.dart';
import 'orders_screen.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _i = 0;

  static const _pages = <Widget>[
    DashboardScreen(),
    OrdersScreen(),
    CustomersScreen(),
  ];

  void _newOrder() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const OrderFormScreen()),
    );
  }

  Widget? _fab() {
    if (_i != 1) return null;
    return FloatingActionButton.extended(
      onPressed: _newOrder,
      backgroundColor: C.coral,
      foregroundColor: Colors.white,
      elevation: 2,
      icon: const Icon(Icons.add_rounded),
      label: Text(
        'Nota baru',
        style: tx(14, w: FontWeight.w800, color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final wide = c.maxWidth >= 800;
        final body = IndexedStack(index: _i, children: _pages);

        if (wide) {
          final extended = c.maxWidth >= 1100;
          return Scaffold(
            floatingActionButton: _fab(),
            body: SafeArea(
              child: Row(
                children: [
                  NavigationRail(
                    selectedIndex: _i,
                    onDestinationSelected: (v) => setState(() {
                      _i = v;
                    }),
                    extended: extended,
                    labelType: extended ? null : NavigationRailLabelType.all,
                    backgroundColor: Colors.white,
                    indicatorColor: C.foam,
                    leading: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: BrandMark(size: 44),
                    ),
                    destinations: const [
                      NavigationRailDestination(
                        icon: Icon(Icons.space_dashboard_outlined),
                        selectedIcon: Icon(
                          Icons.space_dashboard_rounded,
                          color: C.lagoon,
                        ),
                        label: Text('Beranda'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.receipt_long_outlined),
                        selectedIcon: Icon(
                          Icons.receipt_long_rounded,
                          color: C.lagoon,
                        ),
                        label: Text('Nota'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.groups_outlined),
                        selectedIcon: Icon(
                          Icons.groups_rounded,
                          color: C.lagoon,
                        ),
                        label: Text('Pelanggan'),
                      ),
                    ],
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(child: body),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          floatingActionButton: _fab(),
          body: SafeArea(child: body),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _i,
            backgroundColor: Colors.white,
            indicatorColor: C.foam,
            surfaceTintColor: Colors.transparent,
            onDestinationSelected: (v) => setState(() {
              _i = v;
            }),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.space_dashboard_outlined),
                selectedIcon: Icon(
                  Icons.space_dashboard_rounded,
                  color: C.lagoon,
                ),
                label: 'Beranda',
              ),
              NavigationDestination(
                icon: Icon(Icons.receipt_long_outlined),
                selectedIcon: Icon(Icons.receipt_long_rounded, color: C.lagoon),
                label: 'Nota',
              ),
              NavigationDestination(
                icon: Icon(Icons.groups_outlined),
                selectedIcon: Icon(Icons.groups_rounded, color: C.lagoon),
                label: 'Pelanggan',
              ),
            ],
          ),
        );
      },
    );
  }
}
