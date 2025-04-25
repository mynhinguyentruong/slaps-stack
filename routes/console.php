<?php

use App\Models\User;
use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Schedule;

Artisan::command('inspire', function () {
    $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote');

Artisan::command('clear:all', function () {
    $this->call('cache:clear');
    $this->call('config:clear');
    $this->call('view:clear');
    $this->call('route:clear');
})->purpose('Clear all cache')->everyMinute();


//Schedule::command('clear:all')->everyFiveSeconds();

Schedule::call(function () {
    $user = User::find(1);
    Log::critical($user->name);
})->everyFiveSeconds();
