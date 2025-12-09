from __future__ import annotations
import json
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Sequence
from loguru import logger
from sqlmodel import Session, select
from src.service.embedding_provider import EmbeddingProvider, FallbackEmbeddingProvider, build_embedding_provider
from src.model.courses import CourseEmbedding
from src.app import create_db_engine
from src.settings import Settings


DATA_PATH = Path(__file__).resolve().parents[1] / "data" / "course_contents.json"


@dataclass
class CourseRecord:
    number: str
    title: str | None
    learn_content: str | None
    learn_result: str | None

    @classmethod
    def from_dict(cls, payload: Dict) -> "CourseRecord":
        return cls(
            number=str(payload.get("number", "")).strip(),
            title=_safe_strip(payload.get("title")),
            learn_content=_safe_strip(payload.get("learn_content")),
            learn_result=_safe_strip(payload.get("learn_result")),
        )

    @property
    def description(self) -> str | None:
        parts = [self.title, self.learn_content, self.learn_result]
        combined = "\n\n".join(part for part in parts if part)
        return combined if combined else None


def _safe_strip(value) -> str | None:
    if value is None:
        return None
    text = str(value).strip()
    return text if text else None


class CourseEmbeddingService:
    """
    Generates embeddings for course content and persists them to Postgres.
    """

    def __init__(self, engine, provider: EmbeddingProvider):
        self.engine = engine
        self.provider = provider

    def load_courses(self, data_path: Path = DATA_PATH) -> List[CourseRecord]:
        with data_path.open("r", encoding="utf-8") as f:
            raw_courses = json.load(f)
        courses = [CourseRecord.from_dict(item) for item in raw_courses]
        logger.info(f"Loaded {len(courses)} courses from {data_path}")
        return courses

    def ingest(self, courses: Sequence[CourseRecord]) -> Dict[str, int]:
        inserted = updated = skipped = 0

        with Session(self.engine) as session:
            for course in courses:
                if not course.number:
                    skipped += 1
                    continue

                description = course.description
                if not description:
                    logger.debug(f"Skipping course {course.number} - empty description")
                    skipped += 1
                    continue

                embedding = self.provider.embed_one(description)
                existing = session.exec(
                    select(CourseEmbedding).where(CourseEmbedding.course_number == course.number)
                ).first()

                if existing:
                    existing.course_name = course.title or existing.course_name
                    existing.description = description
                    existing.embedding = embedding
                    existing.updated_at = datetime.utcnow()
                    updated += 1
                else:
                    session.add(
                        CourseEmbedding(
                            course_number=course.number,
                            course_name=course.title or "Unknown course",
                            description=description,
                            embedding=embedding,
                        )
                    )
                    inserted += 1

            session.commit()

        logger.info(f"Embeddings persisted - inserted: {inserted}, updated: {updated}, skipped: {skipped}")
        return {"inserted": inserted, "updated": updated, "skipped": skipped}


def ingest_course_embeddings(
    *,
    data_path: Path = DATA_PATH,
    settings: Settings | None = None,
) -> Dict[str, int]:
    """
    Convenience function to run the full ingest pipeline with application settings.
    """
    settings = settings or Settings()
    engine = create_db_engine(settings)
    ollama_host = settings.llm_host
    if settings.embedding_provider.lower() == "ollama" and ollama_host:
        ollama_host = ollama_host.removesuffix("/v1")
    primary_provider = build_embedding_provider(
        provider=settings.embedding_provider,
        model=settings.embedding_model,
        api_key=settings.openai_api_key,
        base_url=settings.embedding_base_url,
        host=ollama_host if settings.embedding_provider.lower() == "ollama" else None,
    )
    provider: EmbeddingProvider = primary_provider
    if settings.embedding_provider.lower() == "ollama" and settings.openai_api_key:
        fallback_provider = build_embedding_provider(
            provider="openai",
            model=settings.embedding_model,
            api_key=settings.openai_api_key,
            base_url=settings.embedding_base_url,
        )
        provider = FallbackEmbeddingProvider(primary=primary_provider, fallback=fallback_provider)
    service = CourseEmbeddingService(engine=engine, provider=provider)
    courses = service.load_courses(data_path=data_path)
    return service.ingest(courses)


if __name__ == "__main__":
    results = ingest_course_embeddings()
    logger.info(f"Embedding ingest completed: {results}")
