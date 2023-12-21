# Search Engine: Poor Man's Google

This is a simple search engine implemented in OCaml. The search engine takes a URL as input, retrieves the content of the webpage, extracts all the anchors, indexes the content as documents, and performs searches using the TF-IDF (Term Frequency-Inverse Document Frequency) algorithm.

## Features

- Webpage Content Retrieval: Given a URL, the search engine retrieves the content of the webpage.
- Document Indexing: The content is indexed as documents for efficient searching.
- TF-IDF Search: Searches are performed using the TF-IDF algorithm to find relevant documents.

## Usage

1. **Clone the Repository:**
    ```bash
    git clone https://github.com/hnrbs/search-engine.git
    cd search-engine
    ```

2. **Build the Project:**
    ```bash
    nix build .#
    ```

3. **Run the Search Engine:**
    ```bash
    
    ```

4. **Perform a Search:**
    ```bash
    # TODO: Provide examples of how to use it
    ```
## Project Status

The project is currently in progress, and the following tasks have been completed or are still pending:

- [x] **Web Crawling:** The system is in the process of scanning the entire website to traverse its content thoroughly.
  
- [x] **HTML Parsing:** The HTML documents retrieved during web crawling are being parsed to extract relevant information. However, there are still issues to be addressed in this functionality.

- [x] **Document Tokenization:** The system successfully extracts valid tokens from parsed HTML documents.

- [ ] **Document Indexing:** The next step is to implement document indexing, creating an index of term frequencies for each document.

## License

This project is licensed under the [MIT License](LICENSE).
