"""Course embedding functions using pydantic_ai."""
from pydantic_ai import Embedder
from tqdm import tqdm


def build_embedding_text(course: dict) -> str:
    """Build text to embed from course fields."""
    parts = [
        course.get("title", ""),
        course.get("learn_outcomes", ""),
        course.get("learn_content", ""),
    ]
    return " ".join(p for p in parts if p).strip()


async def embed_courses(embedder: Embedder, courses: list[dict]) -> None:
    """Add embeddings to courses in-place."""
    for course in tqdm(courses, desc="Embedding courses"):
        text = build_embedding_text(course)

        if not text:
            course["embedding"] = None
            continue

        result = await embedder.embed_query(text)
        course["embedding"] = result.embeddings[0]
