from __future__ import annotations
from sqlmodel import Session, select
from src.app import create_db_engine
from src.model.course_embedding import CourseEmbedding
from src.service.course_embeddings import CourseEmbeddingService
from src.settings import Settings
from src.embedding_provider import EmbeddingProvider


class DummyEmbeddingProvider(EmbeddingProvider):
    """
    Deterministic provider used for tests so we do not hit external models.
    """

    def embed_one(self, text: str):
        # Simple fixed-length vector; real dimensions depend on the chosen model.
        return [0.1, 0.2, 0.3]


def test_ingest_course_embeddings_runs_with_dummy_provider():
    """
    Smoke test: loads scraped course data, runs ingest with a dummy provider,
    and verifies rows exist in the course_embeddings table.
    Requires Postgres reachable per Settings (default: localhost:5432).
    """
    settings = Settings()
    engine = create_db_engine(settings, echo=False)

    provider = DummyEmbeddingProvider()
    service = CourseEmbeddingService(engine=engine, provider=provider)

    courses = service.load_courses()
    subset = courses[:3]  # keep the test fast

    result = service.ingest(subset)

    with Session(engine) as session:
        rows = session.exec(select(CourseEmbedding)).all()

    assert result["inserted"] + result["updated"] >= 1
    assert len(rows) >= 1
