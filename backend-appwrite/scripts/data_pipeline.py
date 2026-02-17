"""
Data Pipeline - Main entry point for course data processing.

Orchestrates:
1. Course enrichment (summaries + keywords)
2. Course embeddings
3. Upload to MongoDB
"""

import asyncio
import json
import os
from pathlib import Path
from pydantic import BaseModel, Field

from dotenv import load_dotenv
from pydantic_ai import Agent
from scripts.agent_context import agent_context
from scripts.embedding import embed_courses
from scripts.enrichment import enrich_all_courses
from scripts.valid_paths import extract_all_valid_paths


# --- Constants ---

BASE_DIR = Path(__file__).resolve().parents[1]

# Paths
INPUT_PATH = BASE_DIR / "data" / "scraped_courses.json"
OUTPUT_PATH = BASE_DIR / "data" / "scraped_data_new.json"

# Models
ENRICHMENT_MODEL = "gpt-5-mini"
EMBEDDING_MODEL = "text-embedding-3-small"

# Tags for course categorization
TAGS = [
    "AI",
    "Data Analytics",
    "Software Engineering",
    "Infrastructure",
    "Security",
    "Networks",
    "Hardware",
    "Robotics",
    "Digital Business",
    "Theoretical",
    "Human-Computer",
    "Applied",
]

ENRICHMENT_SYSTEM_PROMPT = """\
You are a university curriculum expert.
Analyze course descriptions and categorize them accurately.
Choose keywords that best match the course content - be selective and precise.\
"""

VALID_PATHS_SYSTEM_PROMPT = """
You are a friendly helper who understands Program Paths and from Universities.
"""

class CourseEnrichment(BaseModel):
    """Response schema for course enrichment."""
    course_summary: str = Field(description="A concise summary of the course")
    keywords: list[str] = Field(
        default_factory=list,
        max_length=5,
        description="Up to 5 tags from the fixed list"
    )

class ValidPaths(BaseModel):
    """Structured output for valid paths."""
    paths: list[list[str]] = Field(
        description="List of valid paths, each path is a list of category identifiers"
    )



# --- Helper Functions ---

def load_json(path: Path) -> list[dict]:
    """Load JSON file from disk."""
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)


def save_json(path: Path, data: list[dict]) -> None:
    """Save JSON file to disk."""
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
        f.write("\n")


# --- Main ---

async def main() -> int:
    load_dotenv(BASE_DIR / ".env")
    print(f"Loading courses from {INPUT_PATH}")
    courses = load_json(INPUT_PATH)

    # chat model
    ctx_chat = agent_context(
        system_prompt=ENRICHMENT_SYSTEM_PROMPT,
        model_name=ENRICHMENT_MODEL,
        embedding_model_name=EMBEDDING_MODEL,
    )
    await ctx_chat.initialize()
    enriching_agent = Agent(
        ctx_chat._chat_model,
        system_prompt=ENRICHMENT_SYSTEM_PROMPT,
        output_type = CourseEnrichment
    )
    print("chat agent initialized")

    # paths agent (reuses chat context)
    paths_agent = Agent(
        ctx_chat._chat_model,
        system_prompt=VALID_PATHS_SYSTEM_PROMPT,
        output_type=ValidPaths
    )
    print("paths agent initialized")

    try:
        # Slice to working subset
        #courses = courses[0:2]

        # Step 1: Enrich courses
        print(f"\n--- Enriching {len(courses)} courses ---")
        await enrich_all_courses(agent=enriching_agent, courses=courses, tags=TAGS)

        # Step 2: Embed courses
        print(f"\n--- Embedding {len(courses)} courses ---")
        await ctx_chat.ensure_valid_token()
        print("starting to embed courses")
        await embed_courses(ctx_chat.embedder, courses)

        # Step 3: Valid Paths
        await extract_all_valid_paths(courses=courses, agent=paths_agent)

        # Step 4 : delete unnecessary fields
        for course in courses:
            del course["assigned_degrees"]

        # Save results
        save_json(OUTPUT_PATH, courses)
        print(f"\nWrote {len(courses)} courses to {OUTPUT_PATH}")
        return 0

    finally:
        await ctx_chat.close()


if __name__ == "__main__":
    asyncio.run(main())
