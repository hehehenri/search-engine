<script lang="ts">
  import { Search } from "lucide-svelte";
  import Error from "$lib/Error.svelte";
	import Logo from "$lib/Logo.svelte";
  
  let url: string = "";
  let urlError: string | null = null;
  let showError = false;

  const sanitizeUrl = (urlPayload: string) => {
    urlError = null;

    if (!url.length) {
      urlError = "First write the URL.";
      return null;
    } 
  
    try {    
      const url = new URL(urlPayload).toString();

      return url;
    } catch (_) {
      urlError = "That's not a valid URL.";
      return null;
    }
  }

  $: searchHref = () => {
    const sanitizedUrl = sanitizeUrl(url);

    return sanitizedUrl 
      ? "/search/" + encodeURIComponent(sanitizedUrl)
      : "#";    
  }
</script>

<div class="w-full h-full flex flex-col justify-center items-center container mx-auto px-4 sm:px-6 lg:px-36">
  <div class="text-4xl sm:text-6xl">
    <Logo />
  </div>

  <div class="flex flex-wrap justify-center mt-6 gap-x-8 gap-y-4 col-auto">
    <div class="relative flex items-center w-80">
      <input 
        bind:value={url}
        type="url"
        placeholder="https://example.com/"
        class="peer input-shadow dark:bg-stone-950 rounded-full placeholder:text-zinc-400 text-zinc-700 w-full px-3 py-1.5 pl-12 text-lg outline-indigo-300"
      />
      <Error error={urlError} show={showError} />
      <Search class="mx-3 absolute left-0 text-zinc-400 peer-focus:text-indigo-500" />
    </div>

    <div class="flex justify-center items-center w-auto">
      <a
        href={searchHref()}
        on:click={() => showError = true}
        class="block text-sm px-4 py-2 rounded-full font-chubbo font-semibold transition"
        class:active-index={!urlError} 
        class:inactive-index={urlError}
      >
        Start Indexing
      </a>
    </div>
  </div>
</div>

<style>
  .active-index {
    @apply bg-indigo-200 dark:bg-indigo-900;
    @apply text-indigo-50
  }
  
  .inactive-index {
    @apply bg-indigo-500 dark:bg-indigo-800/40 ;
    @apply text-indigo-50 dark:text-indigo-300/80;
  }

  .input-shadow {
    box-shadow: 0px 9px 30px rgba(35, 65, 210, 0.1);
  }

	@media screen and (prefers-color-scheme: dark) {
    .input-shadow {
      box-shadow: 0px 9px 45px rgba(30, 30, 180, 0.17);
    }
	}
</style>
