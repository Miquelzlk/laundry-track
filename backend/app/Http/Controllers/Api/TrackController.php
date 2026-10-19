<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Order;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class TrackController extends Controller
{
    private const NOT_FOUND = 'Nota tidak ditemukan atau 4 digit terakhir nomor HP tidak cocok.';

    public function show(Request $request): JsonResponse
    {
        $v = $request->validate([
            'no_nota' => 'required|string|max:40',
            'hp_akhir' => 'required|digits:4',
        ]);

        $order = Order::findForTracking($v['no_nota'], $v['hp_akhir']);

        if (! $order) {
            return response()->json(['message' => self::NOT_FOUND], 404);
        }

        return response()->json(['data' => $order->publicPayload()]);
    }

    public function konfirmasi(Request $request): JsonResponse
    {
        $v = $request->validate([
            'no_nota' => 'required|string|max:40',
            'hp_akhir' => 'required|digits:4',
            'aksi' => 'required|in:setuju,usul',
            'usulan_jadwal' => 'nullable|required_if:aksi,usul|date|after:now',
        ]);

        $order = Order::findForTracking($v['no_nota'], $v['hp_akhir']);

        if (! $order) {
            return response()->json(['message' => self::NOT_FOUND], 404);
        }

        if (! $order->customerRespond($v['aksi'], $v['usulan_jadwal'] ?? null)) {
            return response()->json(['message' => 'Jadwal antar belum diatur atau cucian sudah selesai.'], 422);
        }

        $order->load(['customer', 'service', 'payments', 'logs']);

        return response()->json(['data' => $order->publicPayload()]);
    }
}