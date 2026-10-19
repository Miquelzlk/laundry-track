@php
    $rp = fn ($n) => 'Rp '.number_format($n, 0, ',', '.');
    $steps = ['proses' => 'Diproses', 'siap_diantar' => 'Siap diantar', 'selesai' => 'Selesai'];
    $keys = array_keys($steps);
@endphp
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Lacak Cucian - Bilas</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@500;600;700;800&family=Space+Mono:wght@400;700&display=swap" rel="stylesheet">
    <style>
        :root { --ink:#0B2530; --petrol:#123F4C; --lagoon:#0E7C86; --foam:#E3F2F1; --bg:#F1F5F4; --line:#DCE5E4; --muted:#5B7380; --coral:#FF6B3D; --amber:#D98E04; --leaf:#13905C; }
        * { box-sizing: border-box; }
        body { margin:0; background:var(--bg); color:var(--ink); font-family:'Plus Jakarta Sans',system-ui,sans-serif; }
        .shell { max-width:560px; margin:0 auto; padding:20px 16px 48px; }
        .top { display:flex; align-items:center; gap:12px; padding:6px 4px 18px; }
        .mark { width:44px; height:44px; border-radius:14px; background:linear-gradient(135deg,var(--lagoon),#16A394); display:grid; place-items:center; color:#fff; }
        .top strong { display:block; font-size:18px; font-weight:800; }
        .top span { font-size:12px; color:var(--muted); font-weight:600; }
        .hero { background:linear-gradient(135deg,var(--ink),var(--petrol)); color:#fff; border-radius:28px; padding:26px 24px; position:relative; overflow:hidden; margin-bottom:16px; }
        .hero:before { content:''; position:absolute; right:-40px; top:-40px; width:160px; height:160px; border-radius:50%; background:rgba(255,255,255,.06); }
        .hero:after { content:''; position:absolute; right:40px; bottom:-70px; width:130px; height:130px; border-radius:50%; background:rgba(14,124,134,.4); }
        .hero h1 { margin:0 0 8px; font-size:28px; line-height:1.15; font-weight:800; position:relative; }
        .hero p { margin:0; color:rgba(255,255,255,.72); font-size:14px; line-height:1.5; position:relative; max-width:360px; }
        .card { background:#fff; border:1px solid var(--line); border-radius:20px; padding:18px; margin-bottom:14px; }
        .form label { display:block; font-size:12px; font-weight:700; color:var(--muted); margin-bottom:12px; }
        .form input { display:block; width:100%; margin-top:6px; padding:14px; border:1px solid var(--line); border-radius:14px; font:600 15px 'Plus Jakarta Sans',sans-serif; color:var(--ink); background:#fff; outline:none; }
        .form input:focus { border-color:var(--lagoon); box-shadow:0 0 0 3px rgba(14,124,134,.15); }
        button { width:100%; border:0; border-radius:14px; padding:15px; background:var(--lagoon); color:#fff; font:700 15px 'Plus Jakarta Sans',sans-serif; cursor:pointer; display:flex; align-items:center; justify-content:center; gap:8px; }
        button.ghost { background:#fff; color:var(--ink); border:1px solid var(--line); }
        .alert { border-radius:14px; padding:13px 14px; font-size:13px; font-weight:600; margin-bottom:14px; }
        .alert.err { background:rgba(255,107,61,.1); border:1px solid rgba(255,107,61,.35); color:#B23A14; }
        .alert.ok { background:rgba(19,144,92,.1); border:1px solid rgba(19,144,92,.35); color:#0C6B43; }
        .ticket { background:#fff; border-radius:22px; box-shadow:0 8px 18px rgba(11,37,48,.06); margin-bottom:14px; position:relative; }
        .ticket .head { padding:18px 18px 14px; }
        .ticket .row { display:flex; justify-content:space-between; align-items:center; gap:10px; }
        .mono { font-family:'Space Mono',monospace; font-size:12px; color:var(--muted); }
        .pill { display:inline-flex; align-items:center; gap:6px; padding:5px 10px; border-radius:99px; font-size:12px; font-weight:700; }
        .pill.proses { background:rgba(217,142,4,.12); color:var(--amber); }
        .pill.siap_diantar { background:rgba(37,99,235,.12); color:#2563EB; }
        .pill.selesai { background:rgba(19,144,92,.12); color:var(--leaf); }
        .name { font-size:22px; font-weight:800; margin:12px 0 2px; }
        .sub { color:var(--muted); font-size:13px; font-weight:600; }
        .perf { position:relative; height:20px; }
        .perf:before { content:''; position:absolute; left:18px; right:18px; top:9px; border-top:2px dashed var(--line); }
        .perf i { position:absolute; top:0; width:20px; height:20px; border-radius:50%; background:var(--bg); }
        .perf i:first-child { left:-10px; } .perf i:last-child { right:-10px; }
        .ticket .foot { display:flex; justify-content:space-between; padding:6px 18px 18px; }
        .k { font-size:11px; font-weight:700; color:var(--muted); } .v { font-size:16px; font-weight:800; margin-top:2px; }
        .steps { display:flex; align-items:flex-start; }
        .step { width:76px; text-align:center; font-size:12px; font-weight:700; color:var(--muted); }
        .step .dot { width:40px; height:40px; border-radius:50%; margin:0 auto 6px; display:grid; place-items:center; border:2px solid var(--line); background:#fff; color:var(--muted); }
        .step.done .dot { background:var(--lagoon); border-color:var(--lagoon); color:#fff; }
        .step.now { color:var(--ink); } .step.now .dot { box-shadow:0 0 0 5px rgba(14,124,134,.18); }
        .bar { flex:1; height:3px; border-radius:2px; background:var(--line); margin-top:19px; } .bar.done { background:var(--lagoon); }
        h3 { margin:0 0 12px; font-size:15px; font-weight:800; display:flex; align-items:center; gap:8px; }
        h3 svg { color:var(--lagoon); }
        .line { display:flex; justify-content:space-between; font-size:14px; padding:7px 0; font-weight:600; }
        .line span:first-child { color:var(--muted); }
        .prog { height:8px; border-radius:8px; background:var(--line); overflow:hidden; margin:8px 0 12px; }
        .prog div { height:100%; background:var(--lagoon); border-radius:8px; }
        .pay { display:flex; justify-content:space-between; padding:10px 0; border-top:1px solid var(--line); font-size:13px; font-weight:600; }
        .pay small { display:block; color:var(--muted); font-weight:600; }
        .when { font-size:20px; font-weight:800; margin-bottom:8px; }
        .actions { display:grid; gap:10px; margin-top:14px; }
        .actions input { display:block; width:100%; padding:13px; border:1px solid var(--line); border-radius:14px; font:600 14px 'Plus Jakarta Sans',sans-serif; margin-bottom:10px; }
        .tl { list-style:none; margin:0; padding:0; }
        .tl li { display:flex; gap:12px; padding:0 0 14px; font-size:13px; font-weight:600; position:relative; }
        .tl li:before { content:''; width:10px; height:10px; border-radius:50%; background:var(--lagoon); margin-top:4px; flex:none; }
        .tl small { display:block; color:var(--muted); }
        footer { text-align:center; color:var(--muted); font-size:12px; font-weight:600; margin-top:24px; }
    </style>
</head>
<body>
<div class="shell">
    <header class="top">
        <div class="mark">
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M7 16.3c2.2 0 4-1.83 4-4.05 0-1.16-.57-2.26-1.71-3.19S7.29 6.75 7 5.3c-.29 1.45-1.14 2.84-2.29 3.76S3 11.1 3 12.25c0 2.22 1.8 4.05 4 4.05z"/><path d="M12.56 6.6A10.97 10.97 0 0 0 14 3.02c.5 2.5 2 4.9 4 6.5s3 3.5 3 5.5a6.98 6.98 0 0 1-11.91 4.97"/></svg>
        </div>
        <div><strong>Bilas</strong><span>Lacak status cucian</span></div>
    </header>

    <section class="hero">
        <h1>Cucian Anda,<br>terpantau jelas.</h1>
        <p>Masukkan nomor nota dan 4 digit terakhir nomor HP yang terdaftar di laundry.</p>
    </section>

    @if (session('ok'))
        <div class="alert ok">{{ session('ok') }}</div>
    @endif
    @if ($error)
        <div class="alert err">{{ $error }}</div>
    @endif
    @if ($errors->any())
        <div class="alert err">{{ $errors->first() }}</div>
    @endif

    <form class="card form" method="GET" action="{{ route('lacak') }}">
        <label>Nomor nota
            <input name="nota" value="{{ $nota }}" placeholder="LDR-261013-001" autocomplete="off" required>
        </label>
        <label>4 digit terakhir nomor HP
            <input name="hp" value="{{ $hp }}" inputmode="numeric" maxlength="4" pattern="[0-9]{4}" placeholder="7890" required>
        </label>
        <button type="submit">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><path d="m21 21-4.3-4.3"/></svg>
            Lacak sekarang
        </button>
    </form>

    @if ($order)
        @php $idx = array_search($order['status'], $keys); @endphp

        <div class="ticket">
            <div class="head">
                <div class="row">
                    <span class="mono">{{ $order['no_nota'] }}</span>
                    <span class="pill {{ $order['status'] }}">{{ $steps[$order['status']] }}</span>
                </div>
                <div class="name">{{ $order['pelanggan']['nama'] }}</div>
                <div class="sub">{{ $order['layanan']['nama'] }} · {{ rtrim(rtrim(number_format($order['berat_kg'], 2, ',', '.'), '0'), ',') }} kg</div>
            </div>
            <div class="perf"><i></i><i></i></div>
            <div class="foot">
                <div><div class="k">Sisa bayar</div><div class="v" style="color: {{ $order['lunas'] ? 'var(--leaf)' : 'var(--coral)' }}">{{ $order['lunas'] ? 'Lunas' : $rp($order['sisa_bayar']) }}</div></div>
                <div style="text-align:right"><div class="k">Total tagihan</div><div class="v">{{ $rp($order['total_harga']) }}</div></div>
            </div>
        </div>

        <div class="card">
            <h3>
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 18V6a2 2 0 0 0-2-2H4a2 2 0 0 0-2 2v11a1 1 0 0 0 1 1h2"/><path d="M15 18H9"/><path d="M19 18h2a1 1 0 0 0 1-1v-3.65a1 1 0 0 0-.22-.624l-3.48-4.35A1 1 0 0 0 17.52 8H14"/><circle cx="17" cy="18" r="2"/><circle cx="7" cy="18" r="2"/></svg>
                Progres cucian
            </h3>
            <div class="steps">
                @foreach ($keys as $i => $k)
                    @if ($i > 0)<div class="bar {{ $i <= $idx ? 'done' : '' }}"></div>@endif
                    <div class="step {{ $i <= $idx ? 'done' : '' }} {{ $i === $idx ? 'now' : '' }}">
                        <div class="dot">
                            @if ($i <= $idx)
                                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><path d="M20 6 9 17l-5-5"/></svg>
                            @else
                                {{ $i + 1 }}
                            @endif
                        </div>
                        {{ $steps[$k] }}
                    </div>
                @endforeach
            </div>
        </div>

        <div class="card">
            <h3>
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M8 2v4"/><path d="M16 2v4"/><rect width="18" height="18" x="3" y="4" rx="2"/><path d="M3 10h18"/></svg>
                Jadwal antar
            </h3>
            @if (! $order['jadwal_antar'])
                <div class="sub">Jadwal antar belum ditentukan. Anda akan dihubungi pihak laundry.</div>
            @else
                <div class="when">{{ \Carbon\Carbon::parse($order['jadwal_antar'])->translatedFormat('l, j F Y · H:i') }}</div>
                @if ($order['konfirmasi_jadwal'] === 'dikonfirmasi')
                    <span class="pill selesai">Anda sudah mengonfirmasi</span>
                @elseif ($order['konfirmasi_jadwal'] === 'usul_ulang')
                    <span class="pill proses">Usulan Anda: {{ \Carbon\Carbon::parse($order['usulan_jadwal'])->translatedFormat('j M · H:i') }} (menunggu laundry)</span>
                @else
                    <span class="pill proses">Menunggu konfirmasi Anda</span>
                @endif

                @if ($order['status'] !== 'selesai')
                    <div class="actions">
                        <form method="POST" action="{{ route('lacak.konfirmasi') }}">
                            @csrf
                            <input type="hidden" name="nota" value="{{ $order['no_nota'] }}">
                            <input type="hidden" name="hp" value="{{ $hp }}">
                            <input type="hidden" name="aksi" value="setuju">
                            <button type="submit">
                                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><path d="m9 12 2 2 4-4"/></svg>
                                Saya ada di rumah pada jadwal ini
                            </button>
                        </form>
                        <form method="POST" action="{{ route('lacak.konfirmasi') }}">
                            @csrf
                            <input type="hidden" name="nota" value="{{ $order['no_nota'] }}">
                            <input type="hidden" name="hp" value="{{ $hp }}">
                            <input type="hidden" name="aksi" value="usul">
                            <input type="datetime-local" name="usulan_jadwal" required>
                            <button type="submit" class="ghost">Usulkan jam lain</button>
                        </form>
                    </div>
                @endif
            @endif
        </div>

        <div class="card">
            <h3>
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M19 7V4a1 1 0 0 0-1-1H5a2 2 0 0 0 0 4h15a1 1 0 0 1 1 1v4h-3a2 2 0 0 0 0 4h3a1 1 0 0 0 1-1v-2a1 1 0 0 0-1-1"/><path d="M3 5v14a2 2 0 0 0 2 2h15a1 1 0 0 0 1-1v-4"/></svg>
                Pembayaran
            </h3>
            <div class="line"><span>Total tagihan</span><span>{{ $rp($order['total_harga']) }}</span></div>
            <div class="line"><span>Sudah dibayar</span><span>{{ $rp($order['total_dibayar']) }}</span></div>
            <div class="prog"><div style="width: {{ $order['total_harga'] > 0 ? min(100, round($order['total_dibayar'] / $order['total_harga'] * 100)) : 0 }}%"></div></div>
            <div class="line"><span>Sisa pelunasan</span><span style="font-weight:800; color: {{ $order['lunas'] ? 'var(--leaf)' : 'var(--coral)' }}">{{ $order['lunas'] ? 'Lunas' : $rp($order['sisa_bayar']) }}</span></div>
            @foreach ($order['pembayaran'] as $p)
                <div class="pay">
                    <div>{{ strtoupper($p['jenis']) === 'DP' ? 'DP' : ucfirst($p['jenis']) }}<small>{{ \Carbon\Carbon::parse($p['waktu'])->translatedFormat('j M Y · H:i') }}</small></div>
                    <div>{{ $rp($p['jumlah']) }}</div>
                </div>
            @endforeach
        </div>

        <div class="card">
            <h3>
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><path d="M12 6v6l4 2"/></svg>
                Riwayat status
            </h3>
            <ul class="tl">
                @foreach (array_reverse($order['riwayat_status']) as $l)
                    <li><div>{{ $steps[$l['status']] ?? $l['status'] }}<small>{{ \Carbon\Carbon::parse($l['waktu'])->translatedFormat('l, j M Y · H:i') }}</small></div></li>
                @endforeach
            </ul>
        </div>
    @endif

    <footer>Bilas · Manajemen dan pelacakan laundry kiloan</footer>
</div>
</body>
</html>