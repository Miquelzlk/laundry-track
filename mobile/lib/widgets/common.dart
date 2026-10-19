import 'package:flutter/material.dart';

import '../core/config.dart';
import '../core/theme.dart';

class Wide extends StatelessWidget {
  final Widget child;
  final double max;
  const Wide({super.key, required this.child, this.max = 880});

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: max),
      child: child,
    ),
  );
}

class BrandMark extends StatelessWidget {
  final double size;
  const BrandMark({super.key, this.size = 44});

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [C.lagoon, Color(0xFF16A394)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(size * .3),
    ),
    child: Icon(
      Icons.local_laundry_service_rounded,
      color: Colors.white,
      size: size * .58,
    ),
  );
}

class Panel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const Panel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: padding,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: C.line),
    ),
    child: child,
  );
}

class PanelTitle extends StatelessWidget {
  final IconData icon;
  final String text;
  final Widget? trailing;
  const PanelTitle({
    super.key,
    required this.icon,
    required this.text,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: C.foam,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: C.lagoon),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Text(text, style: tx(15, w: FontWeight.w800)),
      ),
      if (trailing != null) trailing!,
    ],
  );
}

class Pill extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  const Pill({super.key, required this.label, required this.color, this.icon});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: color.o(.12),
      borderRadius: BorderRadius.circular(99),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
        ],
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: tx(12, w: FontWeight.w700, color: color),
          ),
        ),
      ],
    ),
  );
}

class StatusPill extends StatelessWidget {
  final String status;
  const StatusPill(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    final m = statusMeta(status);
    return Pill(label: m.label, color: m.color, icon: m.icon);
  }
}

class Initial extends StatelessWidget {
  final String name;
  final double size;
  const Initial(this.name, {super.key, this.size = 42});

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: const BoxDecoration(color: C.foam, shape: BoxShape.circle),
    child: Text(
      name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase(),
      style: tx(size * .42, w: FontWeight.w800, color: C.lagoon),
    ),
  );
}

class Perforation extends StatelessWidget {
  const Perforation({super.key});

  Widget _notch() => Container(
    width: 20,
    height: 20,
    decoration: const BoxDecoration(color: C.bg, shape: BoxShape.circle),
  );

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 20,
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: LayoutBuilder(
              builder: (_, c) {
                final n = (c.maxWidth / 9).floor();
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    n,
                    (_) => Container(width: 5, height: 1.6, color: C.line),
                  ),
                );
              },
            ),
          ),
        ),
        Positioned(left: -10, top: 0, child: _notch()),
        Positioned(right: -10, top: 0, child: _notch()),
      ],
    ),
  );
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 24),
    child: Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
            color: C.foam,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 32, color: C.lagoon),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: tx(17, w: FontWeight.w800),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          message,
          style: tx(13.5, color: C.muted, h: 1.5),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const ErrorState({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
    child: Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: C.coral.o(.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.cloud_off_rounded, size: 32, color: C.coral),
        ),
        const SizedBox(height: 16),
        Text('Gagal memuat data', style: tx(17, w: FontWeight.w800)),
        const SizedBox(height: 6),
        Text(
          message,
          style: tx(13.5, color: C.muted, h: 1.5),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Coba lagi'),
        ),
      ],
    ),
  );
}

void toast(BuildContext context, String message, {bool error = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? C.danger : C.ink,
      ),
    );
}

IconData serviceIcon(String nama) {
  final n = nama.toLowerCase();
  if (n.contains('basah')) return Icons.water_drop_rounded;
  if (n.contains('setrika') && !n.contains('tanpa'))
    return Icons.dry_cleaning_rounded;
  return Icons.local_laundry_service_rounded;
}

Future<DateTime?> pickDateTime(
  BuildContext context, {
  DateTime? initial,
}) async {
  final now = DateTime.now();
  final d = await showDatePicker(
    context: context,
    initialDate: (initial != null && initial.isAfter(now)) ? initial : now,
    firstDate: DateTime(now.year, now.month, now.day),
    lastDate: now.add(const Duration(days: 90)),
  );
  if (d == null || !context.mounted) return null;
  final t = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.fromDateTime(
      initial ?? now.add(const Duration(hours: 2)),
    ),
  );
  if (t == null) return null;
  return DateTime(d.year, d.month, d.day, t.hour, t.minute);
}

Future<void> showServerSheet(BuildContext context) async {
  final ctrl = TextEditingController(text: AppConfig.baseUrl);
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        22,
        20,
        20 + MediaQuery.of(ctx).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PanelTitle(icon: Icons.dns_rounded, text: 'Alamat server'),
          const SizedBox(height: 12),
          Text(
            'Emulator Android: http://10.0.2.2:8000\nWindows / Web: http://localhost:8000\nHP fisik: http://IP-LAPTOP:8000',
            style: tx(12.5, color: C.muted, h: 1.6),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: ctrl,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              labelText: 'URL server',
              prefixIcon: Icon(Icons.link_rounded),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () async {
                await AppConfig.setBaseUrl(ctrl.text);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              icon: const Icon(Icons.check_rounded),
              label: const Text('Simpan alamat'),
            ),
          ),
        ],
      ),
    ),
  );
}
