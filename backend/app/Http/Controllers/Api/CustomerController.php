<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Customer;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CustomerController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $q = Customer::withCount('orders')->orderBy('nama');

        if ($t = trim((string) $request->query('q', ''))) {
            $q->where(function ($w) use ($t) {
                $w->where('nama', 'like', "%{$t}%")->orWhere('no_hp', 'like', "%{$t}%");
            });
        }

        $data = $q->limit(200)->get()->map(fn ($c) => [
            'id' => $c->id,
            'nama' => $c->nama,
            'no_hp' => $c->no_hp,
            'alamat' => $c->alamat,
            'jumlah_nota' => $c->orders_count,
        ])->values();

        return response()->json(['data' => $data]);
    }
}