<div class="space-y-6">
    {{ $this->post->title }}
    <br>
    <flux:button wire:click="increment">+</flux:button>
    <br>
    {{ $count }}
</div>
