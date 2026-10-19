int _i(dynamic v) => v is num ? v.toInt() : (int.tryParse('${v ?? ''}') ?? 0);
double _d(dynamic v) =>
    v is num ? v.toDouble() : (double.tryParse('${v ?? ''}') ?? 0);
DateTime? _dt(dynamic v) => v == null ? null : DateTime.tryParse('$v');

class Service {
  final int id;
  final String nama;
  final int hargaPerKg;
  const Service({
    required this.id,
    required this.nama,
    required this.hargaPerKg,
  });

  factory Service.fromJson(Map<String, dynamic> j) => Service(
    id: _i(j['id']),
    nama: '${j['nama']}',
    hargaPerKg: _i(j['harga_per_kg']),
  );
}

class Customer {
  final int id;
  final String nama;
  final String noHp;
  final String? alamat;
  final int jumlahNota;
  const Customer({
    required this.id,
    required this.nama,
    required this.noHp,
    this.alamat,
    required this.jumlahNota,
  });

  factory Customer.fromJson(Map<String, dynamic> j) => Customer(
    id: _i(j['id']),
    nama: '${j['nama']}',
    noHp: '${j['no_hp']}',
    alamat: j['alamat'] as String?,
    jumlahNota: _i(j['jumlah_nota']),
  );
}

class PaymentItem {
  final int id;
  final int jumlah;
  final String jenis;
  final String? catatan;
  final DateTime? waktu;
  const PaymentItem({
    required this.id,
    required this.jumlah,
    required this.jenis,
    this.catatan,
    this.waktu,
  });

  factory PaymentItem.fromJson(Map<String, dynamic> j) => PaymentItem(
    id: _i(j['id']),
    jumlah: _i(j['jumlah']),
    jenis: '${j['jenis']}',
    catatan: j['catatan'] as String?,
    waktu: _dt(j['waktu']),
  );
}

class StatusLog {
  final String status;
  final DateTime? waktu;
  const StatusLog({required this.status, this.waktu});

  factory StatusLog.fromJson(Map<String, dynamic> j) =>
      StatusLog(status: '${j['status']}', waktu: _dt(j['waktu']));
}

class Order {
  final int id;
  final String noNota;
  final String status;
  final double beratKg;
  final int hargaPerKg;
  final int totalHarga;
  final int totalDibayar;
  final int sisaBayar;
  final DateTime? jadwalAntar;
  final String konfirmasi;
  final DateTime? usulanJadwal;
  final String? catatan;
  final DateTime? dibuat;
  final String nama;
  final String noHp;
  final String? alamat;
  final String layanan;
  final List<PaymentItem> pembayaran;
  final List<StatusLog> riwayat;

  const Order({
    required this.id,
    required this.noNota,
    required this.status,
    required this.beratKg,
    required this.hargaPerKg,
    required this.totalHarga,
    required this.totalDibayar,
    required this.sisaBayar,
    this.jadwalAntar,
    required this.konfirmasi,
    this.usulanJadwal,
    this.catatan,
    this.dibuat,
    required this.nama,
    required this.noHp,
    this.alamat,
    required this.layanan,
    required this.pembayaran,
    required this.riwayat,
  });

  bool get lunas => sisaBayar <= 0;

  String get hpAkhir {
    final d = noHp.replaceAll(RegExp(r'\D'), '');
    return d.length >= 4 ? d.substring(d.length - 4) : d;
  }

  factory Order.fromJson(Map<String, dynamic> j) {
    final p =
        (j['pelanggan'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};
    final l =
        (j['layanan'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};
    return Order(
      id: _i(j['id']),
      noNota: '${j['no_nota']}',
      status: '${j['status']}',
      beratKg: _d(j['berat_kg']),
      hargaPerKg: _i(j['harga_per_kg']),
      totalHarga: _i(j['total_harga']),
      totalDibayar: _i(j['total_dibayar']),
      sisaBayar: _i(j['sisa_bayar']),
      jadwalAntar: _dt(j['jadwal_antar']),
      konfirmasi: '${j['konfirmasi_jadwal'] ?? 'menunggu'}',
      usulanJadwal: _dt(j['usulan_jadwal']),
      catatan: j['catatan'] as String?,
      dibuat: _dt(j['dibuat']),
      nama: '${p['nama'] ?? ''}',
      noHp: '${p['no_hp'] ?? ''}',
      alamat: p['alamat'] as String?,
      layanan: '${l['nama'] ?? ''}',
      pembayaran: ((j['pembayaran'] as List?) ?? const [])
          .map((e) => PaymentItem.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
      riwayat: ((j['riwayat_status'] as List?) ?? const [])
          .map((e) => StatusLog.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
    );
  }
}

class Dashboard {
  final int proses;
  final int siap;
  final int selesai;
  final int piutang;
  final int pendapatanHariIni;
  final int perluTanggapan;
  final List<Order> jadwal;

  const Dashboard({
    required this.proses,
    required this.siap,
    required this.selesai,
    required this.piutang,
    required this.pendapatanHariIni,
    required this.perluTanggapan,
    required this.jadwal,
  });

  factory Dashboard.fromJson(Map<String, dynamic> j) {
    final r = (j['ringkasan'] as Map).cast<String, dynamic>();
    return Dashboard(
      proses: _i(r['proses']),
      siap: _i(r['siap_diantar']),
      selesai: _i(r['selesai']),
      piutang: _i(r['piutang']),
      pendapatanHariIni: _i(r['pendapatan_hari_ini']),
      perluTanggapan: _i(r['perlu_tanggapan']),
      jadwal: ((j['jadwal_terdekat'] as List?) ?? const [])
          .map((e) => Order.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
    );
  }
}
