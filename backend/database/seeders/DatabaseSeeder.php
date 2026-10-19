<?php

namespace Database\Seeders;

use App\Models\Customer;
use App\Models\Order;
use App\Models\Service;
use App\Models\User;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        User::create([
            'name' => 'Pemilik Laundry',
            'email' => 'admin@laundry.test',
            'password' => 'admin123',
        ]);

        $services = collect([
            ['Cuci Basah', 4000],
            ['Cuci Kering Tanpa Setrika', 6000],
            ['Cuci Kering + Setrika', 8000],
            ['Setrika Saja', 5000],
        ])->map(fn ($s) => Service::create(['nama' => $s[0], 'harga_per_kg' => $s[1]]));

        $make = function (
            string $nama, string $hp, string $alamat, int $svc, float $kg,
            string $status, int $dp, $jadwal = null, string $konf = 'menunggu', $usulan = null
        ) use ($services) {
            $c = Customer::firstOrCreate(['no_hp' => $hp], ['nama' => $nama, 'alamat' => $alamat]);
            $s = $services[$svc];

            $o = Order::create([
                'no_nota' => Order::generateNota(),
                'customer_id' => $c->id,
                'service_id' => $s->id,
                'berat_kg' => $kg,
                'harga_per_kg' => $s->harga_per_kg,
                'total_harga' => (int) round($kg * $s->harga_per_kg),
                'status' => $status,
                'jadwal_antar' => $jadwal,
                'konfirmasi_jadwal' => $konf,
                'usulan_jadwal' => $usulan,
            ]);

            $upto = array_search($status, Order::STATUS) + 1;
            foreach (array_slice(Order::STATUS, 0, $upto) as $st) {
                $o->logs()->create(['status' => $st]);
            }

            if ($dp > 0) {
                $o->payments()->create(['jumlah' => $dp, 'jenis' => 'dp', 'catatan' => 'DP awal']);
            }
        };

        $make('Bu Sari', '081234567890', 'Gg. Melati No. 4', 2, 4.5, 'proses', 15000, now()->addDay()->setTime(16, 0));
        $make('Pak Dimas', '082233445566', 'Jl. Kenanga No. 12', 1, 3, 'siap_diantar', 10000, now()->addHours(3), 'usul_ulang', now()->addDay()->setTime(19, 0));
        $make('Mbak Rina', '085712349876', 'Perum Griya Asri Blok B7', 0, 6, 'proses', 0);
        $make('Bu Sari', '081234567890', 'Gg. Melati No. 4', 3, 2, 'selesai', 10000);
        $make('Pak Anton', '081355667788', 'Jl. Pelita No. 21', 2, 8, 'siap_diantar', 20000, now()->addDay()->setTime(10, 0), 'dikonfirmasi');
    }
}