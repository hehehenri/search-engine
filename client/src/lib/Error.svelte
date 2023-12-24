<script lang="ts">
	import { slide } from 'svelte/transition';
  
  export let error: string | null = null;
  export let show: boolean = true;

  const close = () => {
    error = null;
  }
</script>

{#if error && show}
  <button transition:slide={{ duration: 150 }} on:click={close} class="absolute top-full mt-2 w-full flex justify-center">
    <p class="text-rose-50 text-sm bg-rose-400 dark:bg-rose-700 rounded-full px-3 py-0.5 font-semibold">
      {error}
    </p>
  </button>
{/if}
