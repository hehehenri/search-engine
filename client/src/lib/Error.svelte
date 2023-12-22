<script lang="ts">
  export let error: string | null = null;

  const close = () => {
    error = null;
  }
</script>

{#if error}
  <button on:click={close} class="absolute top-full mt-2 w-full flex justify-center">
    <p class="text-rose-50 text-sm bg-rose-400 rounded-full px-3 py-0.5 font-semibold">
      {error}
    </p>
  </button>
{/if}
