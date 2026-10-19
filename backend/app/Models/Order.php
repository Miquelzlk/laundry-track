<?php

namespace App\Models;

use Carbon\Carbon;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Order extends Model
{
    public const STATUS = ['proses', 'siap_diantar', 'selesai'];

    protected $fillable = [
        'no_nota', 'customer_id', 'service_id', 'berat_kg', 'harga_per_kg', 'total_harga',
        'status', 'jadwal_antar', 'konfirmasi_jadwal', 'usulan_jadwal', 'catatan',
    ];

    protected $casts = [
        'berat_kg' => 'float',
        'harga_per_kg' => 'integer',
        'total_harga' => 'integer',
        'jadwal_antar' => 'datetime',
        'usulan_jadwal' => 'datetime',
    ];

    public function customer(): BelongsTo
    {
        return $this->belongsTo(Customer::class);
    }

    public function service(): BelongsTo
    {
        return $this->belongsTo(Service::class);
    }

    public function payments(): HasMany
    {
        return $this->hasMany(Payment::class);
    }

    public function logs(): HasMany
    {
        return $this->hasMany(StatusLog::class)->orderBy('id');
    }

    public static function generateNota(): string
    {
        $prefix = 'LDR-'.now()->format('ymd').'-';
        $n = static::whereDate('created_at', today())->count() + 1;
        do {
            $nota = $prefix.str_pad((string) $n, 3, '0', STR_PAD_LEFT);
            $n++;
        } while (static::where('no_nota', $nota)->exists());

        return $nota;
    }

    public function sisaBayar(): int
    {
        $this->loadMissing('payments');

        return max(0, (int) $this->total_harga - (int) $this->payments->sum('jumlah'));
    }

    private static function fmt(?Carbon $d): ?string
    {
        return $d?->format('Y-m-d\TH:i:s');
    }

    public function payload(bool $detail = false): array
    {
        $this->loadMissing(['customer', 'service', 'payments']);
        $dibayar = (int) $this->payments->sum('jumlah');
        $sisa = max(0, (int) $this->total_harga - $dibayar);

        $d = [
            'id' => $this->id,
            'no_nota' => $this->no_nota,
            'status' => $this->status,
            'berat_kg' => (float) $this->berat_kg,
            'harga_per_kg' => (int) $this->harga_per_kg,
            'total_harga' => (int) $this->total_harga,
            'total_dibayar' => $dibayar,
            'sisa_bayar' => $sisa,
            'lunas' => $sisa === 0,
            'jadwal_antar' => self::fmt($this->jadwal_antar),
            'konfirmasi_jadwal' => $this->konfirmasi_jadwal,
            'usulan_jadwal' => self::fmt($this->usulan_jadwal),
            'catatan' => $this->catatan,
            'dibuat' => self::fmt($this->created_at),
            'pelanggan' => [
                'id' => $this->customer->id,
                'nama' => $this->customer->nama,
                'no_hp' => $this->customer->no_hp,
                'alamat' => $this->customer->alamat,
            ],
            'layanan' => [
                'id' => $this->service->id,
                'nama' => $this->service->nama,
            ],
        ];

        if ($detail) {
            $this->loadMissing('logs');
            $d['pembayaran'] = $this->payments->sortByDesc('id')->values()->map(fn ($p) => [
                'id' => $p->id,
                'jumlah' => (int) $p->jumlah,
                'jenis' => $p->jenis,
                'catatan' => $p->catatan,
                'waktu' => self::fmt($p->created_at),
            ])->all();
            $d['riwayat_status'] = $this->logs->map(fn ($l) => [
                'status' => $l->status,
                'waktu' => self::fmt($l->created_at),
            ])->all();
        }

        return $d;
    }

    public function publicPayload(): array
    {
        $d = $this->payload(true);
        $d['pelanggan'] = ['nama' => $this->customer->nama];

        return $d;
    }

    public static function findForTracking(string $nota, string $hp4): ?self
    {
        $hp4 = preg_replace('/\D/', '', $hp4);
        if (strlen($hp4) !== 4) {
            return null;
        }

        $order = static::with(['customer', 'service', 'payments', 'logs'])
            ->where('no_nota', strtoupper(trim($nota)))
            ->first();

        if (! $order) {
            return null;
        }

        return substr(Customer::normalizePhone($order->customer->no_hp), -4) === $hp4 ? $order : null;
    }

    public function customerRespond(string $aksi, ?string $usulan = null): bool
    {
        if ($this->status === 'selesai' || ! $this->jadwal_antar) {
            return false;
        }

        if ($aksi === 'setuju') {
            $this->update(['konfirmasi_jadwal' => 'dikonfirmasi', 'usulan_jadwal' => null]);
        } else {
            $this->update(['konfirmasi_jadwal' => 'usul_ulang', 'usulan_jadwal' => Carbon::parse($usulan)]);
        }

        return true;
    }
}