import 'package:intl/intl.dart';

final _rp = NumberFormat.currency(
  locale: 'id_ID',
  symbol: 'Rp ',
  decimalDigits: 0,
);

String rupiah(num v) => _rp.format(v);

String tgl(DateTime d) => DateFormat('d MMM yyyy', 'id_ID').format(d);

String tglJam(DateTime d) =>
    DateFormat('EEE, d MMM · HH:mm', 'id_ID').format(d);

String apiDate(DateTime d) => DateFormat('yyyy-MM-dd HH:mm:ss').format(d);

String beratFmt(double v) => v
    .toStringAsFixed(2)
    .replaceFirst(RegExp(r'\.?0+$'), '')
    .replaceAll('.', ',');
