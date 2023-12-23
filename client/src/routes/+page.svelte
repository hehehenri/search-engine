<script lang="ts">
  import { Search } from "lucide-svelte";
  import Error from "$lib/Error.svelte";
  
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

<div class="w-full flex flex-col justify-center container mx-auto px-4 sm:px-6 lg:px-36">
  <h1 class="text-center text-4xl sm:text-6xl font-chubbo font-bold text-indigo-400">
    PoorMansGoogle
  </h1>

  <div class="flex flex-wrap justify-center mt-6 gap-x-8 gap-y-4 col-auto">
    <div class="relative flex items-center w-80">
      <input 
        bind:value={url}
        type="url"
        placeholder="https://example.com/"
        class="peer rounded-full placeholder:text-zinc-400 text-zinc-700 w-full px-3 py-1.5 pl-12 text-lg outline-indigo-300 shadow-[rgba(7,_65,_210,_0.1)_0px_9px_30px]"
      />
      <Error error={urlError} show={showError} />
      <Search class="mx-3 absolute left-0 text-zinc-400 peer-focus:text-indigo-500" />
    </div>

    <div class="flex justify-center items-center w-auto">
      <a
        href={searchHref()}
        on:click={() => showError = true}
        class="block text-sm px-4 py-2 rounded-full text-indigo-50 font-chubbo font-semibold transition"
        class:bg-indigo-200={urlError} 
        class:bg-indigo-500={!urlError}
      >
        Start Indexing
      </a>
    </div>
  </div>
</div>
