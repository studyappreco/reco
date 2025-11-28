# RECO backend

# Requirements
    - python 3.12
    - uv package manager (installed)
    - Docker desktop installed

# Getting started
    cd api
    uv sync
    uv run baml-cli generate
    docker compose build --no-cache && docker compose up ; optionally omit the no-cache flag
    uv run main.py

    check localhost:8000/docs for openApi spec
    