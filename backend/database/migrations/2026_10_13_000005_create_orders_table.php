<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('orders', function (Blueprint $table) {
            $table->id();
            $table->string('no_nota', 30)->unique();
            $table->foreignId('customer_id')->constrained()->cascadeOnDelete();
            $table->foreignId('service_id')->constrained();
            $table->decimal('berat_kg', 8, 2);
            $table->unsignedInteger('harga_per_kg');
            $table->unsignedInteger('total_harga');
            $table->string('status', 20)->default('proses')->index();
            $table->dateTime('jadwal_antar')->nullable();
            $table->string('konfirmasi_jadwal', 20)->default('menunggu');
            $table->dateTime('usulan_jadwal')->nullable();
            $table->string('catatan')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('orders');
    }
};