<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Service extends Model
{
    protected $fillable = ['nama', 'harga_per_kg'];

    protected $casts = [
        'harga_per_kg' => 'integer',
    ];
}