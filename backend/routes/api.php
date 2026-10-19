<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\CustomerController;
use App\Http\Controllers\Api\DashboardController;
use App\Http\Controllers\Api\OrderController;
use App\Http\Controllers\Api\ServiceController;
use App\Http\Controllers\Api\TrackController;
use Illuminate\Support\Facades\Route;

Route::post('/login', [AuthController::class, 'login'])->middleware('throttle:10,1');
Route::post('/track', [TrackController::class, 'show'])->middleware('throttle:30,1');
Route::post('/track/konfirmasi', [TrackController::class, 'konfirmasi'])->middleware('throttle:30,1');

Route::middleware('api.token')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/dashboard', DashboardController::class);
    Route::get('/services', [ServiceController::class, 'index']);
    Route::get('/customers', [CustomerController::class, 'index']);

    Route::get('/orders', [OrderController::class, 'index']);
    Route::post('/orders', [OrderController::class, 'store']);
    Route::get('/orders/{order}', [OrderController::class, 'show']);
    Route::patch('/orders/{order}/status', [OrderController::class, 'updateStatus']);
    Route::patch('/orders/{order}/jadwal', [OrderController::class, 'updateJadwal']);
    Route::post('/orders/{order}/pembayaran', [OrderController::class, 'pay']);
});