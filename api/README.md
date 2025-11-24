# RECO backend

# Requirements
    - python 3.12
    - uv package manager (installed)
    - Docker desktop installed

# Getting started
    cd api
    uv sync
    docker compose build --no-cache && docker compose up
    uv run main.py

    check localhost:8000/docs for openApi spec
    