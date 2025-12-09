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

# Update the openAPI specification

    cd api
    uv run -m src.scripts.generate_openapi
    