<?php

namespace App\Http\Controllers;

use App\Models\Order;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\View\View;

class TrackWebController extends Controller
{
    public function index(Request $request): View
    {
        $order = null;
        $error = null;
        $nota = trim((string) $request->query('nota', ''));
        $hp = preg_replace('/\D/', '', (string) $request->query('hp', ''));

        if ($nota !== '' || $hp !== '') {
            if ($nota === '' || strlen($hp) !== 4) {
                $error = 'Isi nomor nota dan 4 digit terakhir nomor HP.';
            } else {
                $found = Order::findForTracking($nota, $hp);
                if ($found) {
                    $order = $found->publicPayload();
                } else {
                    $error = 'Nota tidak ditemukan atau 4 digit terakhir nomor HP tidak cocok.';
                }
            }
        }

        return view('track.index', [
            'order' => $order,
            'error' => $error,
            'nota' => $nota,
            'hp' => $hp,
        ]);
    }

    public function konfirmasi(Request $request): RedirectResponse
    {
        $v = $request->validate([
            'nota' => 'required|string|max:40',
            'hp' => 'required|digits:4',
            'aksi' => 'required|in:setuju,usul',
            'usulan_jadwal' => 'nullable|required_if:aksi,usul|date|after:now',
        ]);

        $order = Order::findForTracking($v['nota'], $v['hp']);
        abort_if(! $order, 404);

        $order->customerRespond($v['aksi'], $v['usulan_jadwal'] ?? null);

        return redirect()
            ->route('lacak', ['nota' => $v['nota'], 'hp' => $v['hp']])
            ->with('ok', 'Respons Anda sudah dikirim ke pihak laundry.');
    }
}