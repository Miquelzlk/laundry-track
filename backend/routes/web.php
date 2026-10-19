<?php

use App\Http\Controllers\TrackWebController;
use Illuminate\Support\Facades\Route;

Route::get('/', fn () => redirect('/lacak'));
Route::get('/lacak', [TrackWebController::class, 'index'])->name('lacak');
Route::post('/lacak/konfirmasi', [TrackWebController::class, 'konfirmasi'])->name('lacak.konfirmasi');