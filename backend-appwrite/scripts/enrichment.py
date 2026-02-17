"""Course enrichment functions using OpenAI."""

import json
from typing import List
from openai import OpenAI
from pydantic import BaseModel, Field
from pydantic_ai import Agent
from enum import Enum


# --- Pydantic Models ---

class Term(Enum):
    SUMMER = "summer"
    WINTER = "winter"

class CourseEnrichment(BaseModel):
    """Response schema for course enrichment."""
    course_summary: str = Field(description="A concise summary of the course always written in english. Even if the content is provided in German")
    keywords: list[str] = Field(
        default_factory=list,
        max_length=2,
        description="Up to 2 tags from the fixed list"
    )



async def enrich_course(
    agent: Agent,
    course: dict,
    tags: list[str],
) -> CourseEnrichment:
    """Call OpenAI to enrich a course with summary and keywords."""
    title = course.get("title", "")
    outcomes = course.get("learn_outcomes") or course.get("learn_result") or ""
    content = course.get("learn_content", "")

    result = await agent.run(
        f"""
            Summarize the following course outcomes and content and choose up to 2 tags from the fixed list.
            Tags should be unique and accurately match the course content. Also provide in which terms the course is offerend
            and give it back in a cleanly formatted array.

            ## Course Information
            - Title: {title}
            - Learning outcomes: {outcomes}
            - Learning content: {content}

            Always provide the summary in english.

            ## Available Tags (choose ONLY from these)
            {', '.join(tags)}

            Always provide the summary in english.

        """
    )
    return result.output

async def enrich_all_courses(agent: Agent,
    courses: List[dict],
    tags: list[str],) -> None:
    for idx, course in enumerate(courses):
        title = course.get("title") or "<no title>"
        number = course.get("number", "?")
        print(f"[{idx}] Enriching: {number} - {title}")

        enrichment = await enrich_course(
            agent=agent,
            course=course,
            tags=tags,
        )

        course["course_summary"] = enrichment.course_summary
        course["keywords"] = enrichment.keywords
        print(f"[{idx}] Done: {len(enrichment.keywords)} keywords")
    
