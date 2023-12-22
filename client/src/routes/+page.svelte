<script lang="ts">
  import { Search } from "lucide-svelte";
  import Error from "$lib/Error.svelte";
  
  let url: string = "";
  let urlError: string | null = null;

  const hostOfUrl = (url: string) => {
    return (new URL(url)).hostname;
  }
  
  const postIndex = (url: string) => {
    urlError = null;

    if (!url.length) 
      return urlError = "Write the URL first.";
  
    try {    
      const host = hostOfUrl(url);

      console.log(host)
    } catch (_) {
      return urlError = "That's not a valid URL.";
    }
  };

</script>

<div class="w-screen h-screen flex items-center justify-center bg-indigo-50/40 min-w-[350px]">
  <div class="w-full flex flex-col justify-center container mx-auto px-4 sm:px-6 lg:px-36">
    <h1 class="text-center text-4xl sm:text-6xl font-chubbo font-bold text-indigo-400">
      PoorMansGooggle
    </h1>

    <div class="flex flex-wrap justify-center mt-6 gap-x-8 gap-y-4 col-auto">
      <div class="relative flex items-center w-80">
        <input 
          bind:value={url}
          type="url"
          placeholder="https://example.com/"
          class="peer rounded-full placeholder:text-zinc-400 text-zinc-700 w-full px-3 py-1.5 pl-12 text-lg outline-indigo-300 shadow-[rgba(7,_65,_210,_0.1)_0px_9px_30px]"
          on:keydown={() => url.length && postIndex(url)}
        />
        <Error error={urlError} />
        <Search class="mx-3 absolute left-0 text-zinc-400 peer-focus:text-indigo-500" />
      </div>

      <div class="flex justify-center w-auto">
        <button
          on:click={() => postIndex(url)}
          class="block text-sm bg-indigo-500 disabled:bg-indigo-200 px-4 py-2 rounded-full text-indigo-50 font-chubbo font-semibold"
          disabled={!url.length ?? null}
        >
          Start Indexing
        </button>
      </div>
    </div>
  </div>
</div>
