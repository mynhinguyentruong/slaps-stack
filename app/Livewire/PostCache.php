<?php

namespace App\Livewire;

use App\Models\Post;
use Illuminate\Support\Facades\Log;
use Livewire\Attributes\Computed;
use Livewire\Component;

class PostCache extends Component
{
    public int $count = 0;

    public function mount()
    {
        $this->authorize('view-any', auth()->user());
    }

    public function increment(): void
    {
        $this->count++;
    }

    #[Computed(cache: true)]
    public function post()
    {
        return Post::find(1);
    }

    public function render()
    {
        Log::info('Post model retrieved successfully!',$this->post->toArray());
        return view('livewire.post-cache');
    }
}
