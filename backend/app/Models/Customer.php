<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Customer extends Model
{
    protected $fillable = ['nama', 'no_hp', 'alamat'];

    public function orders(): HasMany
    {
        return $this->hasMany(Order::class);
    }

    public static function normalizePhone(string $hp): string
    {
        $d = preg_replace('/\D/', '', $hp);
        if (str_starts_with($d, '62')) {
            return '0'.substr($d, 2);
        }
        if (str_starts_with($d, '8')) {
            return '0'.$d;
        }

        return $d;
    }
}