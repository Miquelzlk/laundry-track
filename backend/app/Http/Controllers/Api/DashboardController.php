<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\Payment;
use Illuminate\Http\JsonResponse;

class DashboardController extends Controller
{
    public function __invoke(): JsonResponse
    {
        $piutang = max(0, (int) Order::sum('total_harga') - (int) Payment::sum('jumlah'));
        $hariIni = (int) Payment::whereDate('created_at', today())->sum('jumlah');
        $perlu = Order::where('status', '!=', 'selesai')->where('konfirmasi_jadwal', 'usul_ulang')->count();

        $jadwal = Order::with(['customer', 'service', 'payments'])
            ->where('status', '!=', 'selesai')
            ->whereNotNull('jadwal_antar')
            ->orderBy('jadwal_antar')
            ->limit(6)
            ->get()
            ->map(fn ($o) => $o->payload())
            ->values();

        return response()->json(['data' => [
            'ringkasan' => [
                'proses' => Order::where('status', 'proses')->count(),
                'siap_diantar' => Order::where('status', 'siap_diantar')->count(),
                'selesai' => Order::where('status', 'selesai')->count(),
                'piutang' => $piutang,
                'pendapatan_hari_ini' => $hariIni,
                'perlu_tanggapan' => $perlu,
            ],
            'jadwal_terdekat' => $jadwal,
        ]]);
    }
}