"""Content-based course recommendation algorithm.

Execution order is intentionally aligned with the specification provided by the user.
"""
from __future__ import annotations

from dataclasses import dataclass
import math
import os
from pathlib import Path
from typing import Iterable, List, Sequence

try:
    from dotenv import load_dotenv
except ImportError:  # pragma: no cover - optional for tests
    def load_dotenv(*args, **kwargs):
        return False


BASE_DIR = Path(__file__).resolve().parents[1]
load_dotenv(BASE_DIR / ".env")


# Core data structures
# -------------------------
@dataclass(frozen=True)
class Course:
    """Course record used by the recommendation algorithm."""
    course_number: str  # Unique course/module identifier used in catalogs
    title: str  #course title
    embedding: Sequence[float]  # Vector embedding representing course content
    degree_program: str # ETCS
    offered_semesters: Sequence[str]    # SoSe/WiSe
    topics: Sequence[str]   # Tags or keywords describing the course topics

@dataclass(frozen=True)
class Recommendation:
    """Recommendation output payload for a course."""
    course_number: str
    title: str
    match_percentage: float
    interest_score: float
    semester_bonus: float
    explanation: str


# -------------------------
# ANN (approximate nearest neighbor) index
# -------------------------
class HnswAnnIndex:
    """
    HNSW: Hierarchical navigable small world
    Approximate nearest neighbor search using HNSW."""

    def __init__(
        self,
        courses: Sequence[Course],
        ef_search: int = 50,
        ef_construction: int = 200,
        m: int = 16,
    ):
        self._courses = list(courses)
        try:
            import hnswlib  # type: ignore
            import numpy as np
        except ImportError:
            self._index = None
            self._dim = 0
            return

        if not courses:
            self._index = None
            self._dim = 0
            return

        embeddings = [course.embedding for course in courses if course.embedding]
        if not embeddings:
            raise ValueError("Course embeddings are required to build ANN index.")

        dim = len(embeddings[0])
        for emb in embeddings:
            if len(emb) != dim:
                raise ValueError("All course embeddings must have the same dimension.")

        index = hnswlib.Index(space="cosine", dim=dim)
        index.init_index(
            max_elements=len(courses), ef_construction=ef_construction, M=m
        )
        index.set_ef(ef_search)

        vectors = np.array([course.embedding for course in courses], dtype=np.float32)
        ids = np.arange(len(courses))
        index.add_items(vectors, ids)
        self._index = index
        self._dim = dim

    def search(self, query_vector: Sequence[float], top_k: int) -> List[Course]:
        if self._index is None:
            scored = [
                (cosine_similarity(query_vector, course.embedding), course)
                for course in self._courses
            ]
            scored.sort(key=lambda item: item[0], reverse=True)
            return [course for _, course in scored[:top_k]]
        if len(query_vector) != self._dim:
            raise ValueError("Query vector dimension does not match ANN index.")
        import numpy as np
        query = np.array([query_vector], dtype=np.float32)
        labels, _ = self._index.knn_query(query, k=top_k)
        return [self._courses[idx] for idx in labels[0]]


# -------------------------
# Embeddings
# -------------------------
def embed_texts(texts: Iterable[str]) -> List[List[float]]:
    """Generate embeddings for a list of texts.

    connect this function to the embedding service (e.g., OpenAI embeddings).
    """
    api_key = os.getenv("OPENAI_API_KEY")
    if not api_key:
        raise RuntimeError("OPENAI_API_KEY not found. Check your .env file.")
    from openai import OpenAI
    client = OpenAI()
    response = client.embeddings.create(
        model="text-embedding-3-small",
        input=list(texts),
        dimensions=1536,
    )
    return [item.embedding for item in response.data]


def embed_courses(course_titles: Iterable[str]) -> List[List[float]]:
    """Generate embeddings for course titles or course descriptions.

    connect this function to the embedding service.
    """
    return embed_texts(course_titles)


# -------------------------
# Math utilities
# -------------------------
def cosine_similarity(vec_a: Sequence[float], vec_b: Sequence[float]) -> float:
    """Compute cosine similarity between two equal-length vectors."""
    if len(vec_a) != len(vec_b):
        raise ValueError("Vectors must be the same length for cosine similarity.")
    dot = sum(a * b for a, b in zip(vec_a, vec_b))
    mag_a = math.sqrt(sum(a * a for a in vec_a))
    mag_b = math.sqrt(sum(b * b for b in vec_b))
    if mag_a == 0 or mag_b == 0:
        return 0.0
    return dot / (mag_a * mag_b)


def sigmoid(x: float, steepness: float = 8.0, midpoint: float = 0.5) -> float:
    """Sigmoid with configurable steepness and midpoint."""
    return 1.0 / (1.0 + math.exp(-steepness * (x - midpoint)))


def average_vectors(vectors: Sequence[Sequence[float]]) -> List[float]:
    """Average a list of equal-length vectors."""
    if not vectors:
        return []
    length = len(vectors[0])
    for v in vectors:
        if len(v) != length:
            raise ValueError("All vectors must be the same length to average.")
    summed = [0.0] * length
    for v in vectors:
        for i, value in enumerate(v):
            summed[i] += value
    return [value / len(vectors) for value in summed]


# -------------------------
# Main algorithm
# -------------------------
def build_user_interest_vector(
    keywords: Sequence[str],
    transcript_courses: Sequence[str],
    previously_enrolled_courses: Sequence[str],
) -> List[float]:
    """Build the user interest vector from keywords and course histories."""
    keyword_embeddings = embed_texts(keywords) if keywords else []
    transcript_embeddings = (
        embed_courses(transcript_courses) if transcript_courses else []
    )
    enrolled_embeddings = (
        embed_courses(previously_enrolled_courses)
        if previously_enrolled_courses
        else []
    )

    all_embeddings = keyword_embeddings + transcript_embeddings + enrolled_embeddings
    return average_vectors(all_embeddings)


def calculate_interest_score(user_vector: Sequence[float], course_vector: Sequence[float]) -> float:
    """Convert cosine similarity into a normalized interest score."""
    similarity = cosine_similarity(user_vector, course_vector)
    return sigmoid(similarity, steepness=8.0, midpoint=0.5)


def semester_bonus(course: Course, current_semester: str) -> float:
    """Return the semester bonus for courses offered in the current term."""
    return 0.05 if current_semester in course.offered_semesters else 0.0


def build_explanation(
    course: Course, user_keywords: Sequence[str], transcript_courses: Sequence[str]
) -> str:
    """Generate a one-sentence explanation for a recommendation."""
    keyword_set = {kw.strip().lower() for kw in user_keywords}
    topic_set = {topic.strip().lower() for topic in course.topics}
    matched_topics = keyword_set.intersection(topic_set)

    if matched_topics:
        topics = ", ".join(sorted(matched_topics))
        return f"Matches your interests in {topics}."

    if transcript_courses:
        return "Related to subjects you have already studied."

    return "Aligned with your academic interests based on your profile."


def recommend_courses(
    courses: Sequence[Course],
    user_keywords: Sequence[str],
    transcript_courses: Sequence[str],
    previously_enrolled_courses: Sequence[str],
    degree_program: str,
    current_semester: str,
    top_n: int = 10,
) -> List[Recommendation]:
    """Run the content-based recommendation algorithm and return top matches."""
    # Step 1: Build user interest profile vector.
    user_vector = build_user_interest_vector(
        user_keywords, transcript_courses, previously_enrolled_courses
    )
    if not user_vector:
        return []

    # Step 2: ANN vector search for top 200 candidates.
    ann_index = HnswAnnIndex(courses)
    candidates = ann_index.search(user_vector, top_k=200)

    # Step 3: Interest similarity scoring.
    scored = []
    for course in candidates:
        interest = calculate_interest_score(user_vector, course.embedding)
        scored.append((course, interest))

    # Step 4: Degree compatibility filter.
    scored = [item for item in scored if item[0].degree_program == degree_program]

    # Step 5: Semester availability adjustment.
    adjusted = []
    for course, interest in scored:
        bonus = semester_bonus(course, current_semester)
        final_score = min(interest + bonus, 1.0)
        adjusted.append((course, interest, bonus, final_score))

    # Step 6: Remove courses already in transcript.
    transcript_set = {title.strip().lower() for title in transcript_courses}
    filtered = [
        item
        for item in adjusted
        if item[0].title.strip().lower() not in transcript_set
    ]

    # Step 7: Convert to percentage and rank.
    ranked = sorted(filtered, key=lambda item: item[3], reverse=True)

    recommendations: List[Recommendation] = []
    for course, interest, bonus, final_score in ranked[:top_n]:
        match_percentage = round(final_score * 100.0, 2)
        explanation = build_explanation(course, user_keywords, transcript_courses)
        recommendations.append(
            Recommendation(
                course_number=course.course_number,
                title=course.title,
                match_percentage=match_percentage,
                interest_score=round(interest, 6),
                semester_bonus=round(bonus, 4),
                explanation=explanation,
            )
        )

    return recommendations
