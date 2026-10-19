import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class C {
  static const ink = Color(0xFF0B2530);
  static const petrol = Color(0xFF123F4C);
  static const lagoon = Color(0xFF0E7C86);
  static const foam = Color(0xFFE3F2F1);
  static const bg = Color(0xFFF1F5F4);
  static const line = Color(0xFFDCE5E4);
  static const muted = Color(0xFF5B7380);
  static const coral = Color(0xFFFF6B3D);
  static const amber = Color(0xFFD98E04);
  static const sky = Color(0xFF2563EB);
  static const leaf = Color(0xFF13905C);
  static const danger = Color(0xFFB42318);
}

extension ColorOpacity on Color {
  Color o(double opacity) => withAlpha((opacity * 255).round());
}

TextStyle tx(
  double size, {
  FontWeight w = FontWeight.w500,
  Color color = C.ink,
  double? h,
  double? ls,
}) => GoogleFonts.plusJakartaSans(
  fontSize: size,
  fontWeight: w,
  color: color,
  height: h,
  letterSpacing: ls,
);

TextStyle mono(
  double size, {
  FontWeight w = FontWeight.w400,
  Color color = C.ink,
  double? ls,
}) => GoogleFonts.spaceMono(
  fontSize: size,
  fontWeight: w,
  color: color,
  letterSpacing: ls,
);

class StatusMeta {
  final String label;
  final Color color;
  final IconData icon;
  const StatusMeta(this.label, this.color, this.icon);
}

const statusOrder = ['proses', 'siap_diantar', 'selesai'];

StatusMeta statusMeta(String s) {
  switch (s) {
    case 'proses':
      return const StatusMeta(
        'Diproses',
        C.amber,
        Icons.local_laundry_service_rounded,
      );
    case 'siap_diantar':
      return const StatusMeta(
        'Siap diantar',
        C.sky,
        Icons.local_shipping_rounded,
      );
    default:
      return const StatusMeta('Selesai', C.leaf, Icons.verified_rounded);
  }
}

OutlineInputBorder _border(Color c, [double w = 1]) => OutlineInputBorder(
  borderRadius: BorderRadius.circular(14),
  borderSide: BorderSide(color: c, width: w),
);

ThemeData buildTheme() {
  final scheme =
      ColorScheme.fromSeed(
        seedColor: C.lagoon,
        brightness: Brightness.light,
      ).copyWith(
        primary: C.lagoon,
        onPrimary: Colors.white,
        secondary: C.coral,
        surface: Colors.white,
        error: C.danger,
      );
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: C.bg,
  );
  final text = GoogleFonts.plusJakartaSansTextTheme(
    base.textTheme,
  ).apply(bodyColor: C.ink, displayColor: C.ink);

  return base.copyWith(
    textTheme: text,
    appBarTheme: AppBarTheme(
      backgroundColor: C.bg,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      foregroundColor: C.ink,
      titleTextStyle: tx(18, w: FontWeight.w800),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: _border(C.line),
      enabledBorder: _border(C.line),
      focusedBorder: _border(C.lagoon, 1.8),
      labelStyle: const TextStyle(color: C.muted),
      prefixIconColor: C.muted,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: C.lagoon,
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: tx(15, w: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: C.ink,
        minimumSize: const Size(0, 52),
        side: const BorderSide(color: C.line),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: tx(15, w: FontWeight.w700),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: C.lagoon,
        textStyle: tx(14, w: FontWeight.w700),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: C.ink,
      contentTextStyle: tx(14, w: FontWeight.w600, color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    dividerTheme: const DividerThemeData(color: C.line, space: 1, thickness: 1),
  );
}
