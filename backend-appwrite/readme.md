# Backend Appwrite

Python backend service for the Reco project.

## Prerequisites

- Python 3.12+
- [uv](https://docs.astral.sh/uv/) - Fast Python package installer and resolver

### Installing uv

```bash
# macOS/Linux
curl -LsSf https://astral.sh/uv/install.sh | sh

# Or with Homebrew
brew install uv
```

## Setup

1. **Clone the repository** and navigate to this folder:
   ```bash
   cd backend-appwrite
   ```

2. **Copy the environment file**:
   ```bash
   cp .env.example .env
   ```

3. **Fill in the environment variables** in `.env`:
   - `MONGO_URI` - Your MongoDB connection string
   - `OPENAI_API_KEY` - Your OpenAI API key

4. **Sync dependencies** with uv:
   ```bash
   uv sync
   ```

   This will create a virtual environment and install all dependencies from `uv.lock`.

## Running Scripts

Use `uv run` to execute Python scripts within the virtual environment:

```bash
uv run python web_scraper.py
```

## Adding Dependencies

```bash
# Add a new package
uv add <package-name>

# Add a dev dependency
uv add --dev <package-name>
```
