# RECO backend

# Requirements
    - python 3.12
    - uv package manager (installed)
    - Docker desktop installed

# Getting started
    cd api
    uv sync
    copy the contents of .env.example into an an .env in the ./api folder
    uv run baml-cli generate
    docker compose build --no-cache && docker compose up ; optionally omit the no-cache flag
    uv run main.py

    check localhost:8000/docs for openApi spec

## Embedding scraped courses
The scraped course data lives in `src/data/course_contents.json`. To embed and persist it to Postgres:

- Set the embedding backend in `.env` (defaults to local Ollama):
  - `EMBEDDING_PROVIDER=ollama|openai`
  - `EMBEDDING_MODEL` (e.g. `mxbai-embed-large` for multilingual Ollama, `text-embedding-3-large` for OpenAI or an OpenAI-compatible local server)
  - `OPENAI_API_KEY` if needed by your provider
- Ensure Postgres is running and accessible via the DB settings in `.env`.
- Run the ingest script: `uv run python -m src.service.course_embeddings`

The pipeline stores vectors and metadata in the `course_embeddings` table. Null or empty rows in the source data are skipped, and multilingual text is embedded as-is so you can switch providers without changing application code.

________________________________________ 
 
# frontend

Frontend for reco.

## Getting Started

- [Install Flutter SDK](https://docs.flutter.dev/install/manual)
- [Install Android Studio](https://developer.android.com/studio)
- [Install the Flutter plugin](https://docs.flutter.dev/tools/android-studio)
- Run `flutter doctor` and follow the instructions to build apps for different targets