<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Customer;
use App\Models\Order;
use App\Models\Service;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class OrderController extends Controller
{
    private function detail(Order $order): JsonResponse
    {
        $order->load(['customer', 'service', 'payments', 'logs']);

        return response()->json(['data' => $order->payload(true)]);
    }

    public function index(Request $request): JsonResponse
    {
        $q = Order::with(['customer', 'service', 'payments'])->latest('id');

        $s = $request->query('status');
        if ($s && in_array($s, Order::STATUS, true)) {
            $q->where('status', $s);
        }

        if ($t = trim((string) $request->query('q', ''))) {
            $q->where(function ($w) use ($t) {
                $w->where('no_nota', 'like', "%{$t}%")
                    ->orWhereHas('customer', function ($c) use ($t) {
                        $c->where('nama', 'like', "%{$t}%")->orWhere('no_hp', 'like', "%{$t}%");
                    });
            });
        }

        $data = $q->limit(200)->get()->map(fn ($o) => $o->payload())->values();

        return response()->json(['data' => $data]);
    }

    public function store(Request $request): JsonResponse
    {
        $v = $request->validate([
            'nama' => 'required|string|max:100',
            'no_hp' => 'required|string|min:8|max:20',
            'alamat' => 'nullable|string|max:255',
            'service_id' => 'required|integer|exists:services,id',
            'berat_kg' => 'required|numeric|min:0.1|max:500',
            'dp' => 'nullable|integer|min:0',
            'jadwal_antar' => 'nullable|date',
            'catatan' => 'nullable|string|max:255',
        ]);

        $order = DB::transaction(function () use ($v) {
            $service = Service::findOrFail($v['service_id']);

            $customer = Customer::firstOrNew(['no_hp' => Customer::normalizePhone($v['no_hp'])]);
            $customer->nama = $v['nama'];
            if (! empty($v['alamat'])) {
                $customer->alamat = $v['alamat'];
            }
            $customer->save();

            $total = (int) round($v['berat_kg'] * $service->harga_per_kg);
            $dp = (int) ($v['dp'] ?? 0);

            if ($dp > $total) {
                throw ValidationException::withMessages(['dp' => 'DP tidak boleh melebihi total tagihan.']);
            }

            $order = Order::create([
                'no_nota' => Order::generateNota(),
                'customer_id' => $customer->id,
                'service_id' => $service->id,
                'berat_kg' => $v['berat_kg'],
                'harga_per_kg' => $service->harga_per_kg,
                'total_harga' => $total,
                'status' => 'proses',
                'jadwal_antar' => $v['jadwal_antar'] ?? null,
                'konfirmasi_jadwal' => 'menunggu',
                'catatan' => $v['catatan'] ?? null,
            ]);

            $order->logs()->create(['status' => 'proses']);

            if ($dp > 0) {
                $order->payments()->create(['jumlah' => $dp, 'jenis' => 'dp', 'catatan' => 'DP awal']);
            }

            return $order;
        });

        $order->load(['customer', 'service', 'payments', 'logs']);

        return response()->json(['data' => $order->payload(true)], 201);
    }

    public function show(Order $order): JsonResponse
    {
        return $this->detail($order);
    }

    public function updateStatus(Request $request, Order $order): JsonResponse
    {
        $v = $request->validate(['status' => 'required|in:proses,siap_diantar,selesai']);

        if ($order->status !== $v['status']) {
            $order->update(['status' => $v['status']]);
            $order->logs()->create(['status' => $v['status']]);
        }

        return $this->detail($order);
    }

    public function updateJadwal(Request $request, Order $order): JsonResponse
    {
        $v = $request->validate([
            'jadwal_antar' => 'required|date',
            'setujui' => 'nullable|boolean',
        ]);

        $order->update([
            'jadwal_antar' => $v['jadwal_antar'],
            'konfirmasi_jadwal' => $request->boolean('setujui') ? 'dikonfirmasi' : 'menunggu',
            'usulan_jadwal' => null,
        ]);

        return $this->detail($order);
    }

    public function pay(Request $request, Order $order): JsonResponse
    {
        $v = $request->validate([
            'jumlah' => 'required|integer|min:1',
            'catatan' => 'nullable|string|max:255',
        ]);

        $order->load('payments');
        $sisa = $order->sisaBayar();

        if ($v['jumlah'] > $sisa) {
            return response()->json([
                'message' => 'Jumlah melebihi sisa tagihan (Rp '.number_format($sisa, 0, ',', '.').').',
            ], 422);
        }

        $order->payments()->create([
            'jumlah' => $v['jumlah'],
            'jenis' => $v['jumlah'] == $sisa ? 'pelunasan' : 'cicilan',
            'catatan' => $v['catatan'] ?? null,
        ]);

        return $this->detail($order);
    }
}