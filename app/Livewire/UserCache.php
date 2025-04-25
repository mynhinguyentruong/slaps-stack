<?php

namespace App\Livewire;

use App\Http\Resources\UserResource;
use App\Models\User;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Log;
use Livewire\Component;

class UserCache extends Component
{
    public User $user;

    public function mount()
    {
        $key = 'user-'. auth()->id();

        $this->user = Cache::rememberForever($key, function () {
            return User::find(auth()->id());
        });

        $this->authorize('view-any', $this->user);

        Log::error('User model retrieved successfully!',$this->user->toArray());
    }
    public function render()
    {
        return view('livewire.user-cache');
    }
}
