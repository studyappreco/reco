# Use the official uv Python 3.12 image
FROM python:3.12-slim AS base

# Set working directory
WORKDIR /app

# Copy project files
COPY pyproject.toml ./
COPY uv.lock ./
COPY src ./src
COPY main.py ./main.py
COPY openapi.json ./openapi.json

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# Install project dependencies
RUN uv sync

# Expose FastAPI port
EXPOSE 8000

# Start the FastAPI server with uvicorn
CMD ["uv", "run", "python", "main.py"]