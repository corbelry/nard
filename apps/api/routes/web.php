<?php

use App\Http\Controllers\AccountDeletionController;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

// Web account deletion for Google Play (QUESTIONS #45).
Route::get('/delete-account', [AccountDeletionController::class, 'show']);
Route::post('/delete-account/code', [AccountDeletionController::class, 'sendCode'])->middleware('throttle:email-start');
Route::post('/delete-account/confirm', [AccountDeletionController::class, 'confirm'])->middleware('throttle:email-verify');
