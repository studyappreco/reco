"""API-facing wrapper for course recommendations.

This is a thin integration layer intended for mobile login usage.
"""
from __future__ import annotations

from dataclasses import dataclass
import os
from typing import Any, Iterable, List, Sequence

from pymongo import MongoClient

from .content_based import Course, Recommendation, recommend_courses


@dataclass(frozen=True)
class RecommendationRequest:
    """Request payload for user recommendations."""
    user_id: str
    top_n: int = 3


_TRANSCRIPTS_COLLECTION = "transcripts"
_COURSES_COLLECTION = "courses_info"
_USER_DETAILS_COLLECTION = "user_details"


def _get_db():
    """Open a MongoDB connection using environment configuration."""
    mongo_uri = os.getenv("MONGODB_URI", os.getenv("MONGO_URI", ""))
    if not mongo_uri:
        raise RuntimeError("Missing MongoDB URI. Set MONGODB_URI or MONGO_URI.")
    db_name = os.getenv("MONGODB_DB", "reco_db")
    client = MongoClient(mongo_uri)
    return client[db_name]


def _load_user_keywords(user_id: str) -> List[str]:
    """Load user interests from the user details collection."""
    db = _get_db()
    doc = db[_USER_DETAILS_COLLECTION].find_one({"userID": user_id})
    if not doc:
        return []
    interests = doc.get("interests") or []
    return [str(i) for i in interests if str(i).strip()]


def _load_user_transcript_courses(user_id: str) -> List[str]:
    """Extract transcript course titles for a given user."""
    db = _get_db()
    doc = db[_TRANSCRIPTS_COLLECTION].find_one({"userID": user_id})
    if not doc:
        return []
    transcript = doc.get("transcript") or {}
    return _extract_transcript_course_titles(transcript)


def _load_user_degree_program(user_id: str) -> str:
    """Load and map the user's degree program literal."""
    db = _get_db()
    doc = db[_TRANSCRIPTS_COLLECTION].find_one({"userID": user_id})
    if not doc:
        return ""
    program_literal = str(doc.get("programLiteral") or "").strip()
    return _map_program_literal(program_literal)


def _load_course_catalog() -> Sequence[Course]:
    """Load course catalog from MongoDB and map to Course objects."""
    db = _get_db()
    courses = []
    for doc in db[_COURSES_COLLECTION].find():
        embedding = doc.get("embedding")
        if not embedding:
            continue
        degree_programs = _extract_degree_programs(doc.get("assigned_degrees") or [])
        offered = _normalize_offered_semesters(doc.get("term"))
        topics = _normalize_topics(doc.get("Keywords") or doc.get("keywords") or [])
        course_number = str(doc.get("number") or "").strip()
        title = str(doc.get("title") or "").strip()

        if not course_number or not title:
            continue

        if degree_programs:
            for program in degree_programs:
                courses.append(
                    Course(
                        course_number=course_number,
                        title=title,
                        embedding=embedding,
                        degree_program=program,
                        offered_semesters=offered,
                        topics=topics,
                    )
                )
        else:
            courses.append(
                Course(
                    course_number=course_number,
                    title=title,
                    embedding=embedding,
                    degree_program="",
                    offered_semesters=offered,
                    topics=topics,
                )
            )

    return courses


def _extract_transcript_course_titles(transcript: dict) -> List[str]:
    """Walk transcript tree and collect course titles."""
    titles: List[str] = []

    def walk(node: Any) -> None:
        if isinstance(node, dict):
            courses = node.get("courses") or []
            for course in courses:
                name = str(course.get("name") or "").strip()
                if name:
                    titles.append(name)
            for child in node.get("children") or []:
                walk(child)
        elif isinstance(node, list):
            for item in node:
                walk(item)

    walk(transcript)
    return titles


def _extract_degree_programs(assigned_degrees: Iterable[dict]) -> List[str]:
    """Extract degree program names from assigned degree records."""
    programs = []
    for item in assigned_degrees:
        program = str(item.get("program") or "").strip()
        if program:
            programs.append(program)
    return programs


def _normalize_topics(values: Iterable[Any]) -> List[str]:
    """Normalize topic values to non-empty strings."""
    return [str(v).strip() for v in values if str(v).strip()]


def _normalize_offered_semesters(term_value: Any) -> List[str]:
    """Normalize term values into SoSe/WiSe tokens."""
    term = str(term_value or "").strip()
    if not term:
        return []
    if "SoSe" in term and "WiSe" in term:
        return ["SoSe", "WiSe"]
    if "SoSe" in term:
        return ["SoSe"]
    if "WiSe" in term:
        return ["WiSe"]
    return [term]


def _map_program_literal(program_literal: str) -> str:
    """Map program literals to human-readable degree names."""
    if not program_literal:
        return ""
    mapping = {
        "CS_M": "Computer Science (Informatik) (M. Sc.)",
        "CM_M": "Computer Science (Informatik) (M. Sc.)",
        "CS_B": "Computer Science (Informatik) (B. Sc.)",
    }
    return mapping.get(program_literal, program_literal)


def recommend_for_user(request: RecommendationRequest) -> List[Recommendation]:
    """Main entrypoint for the mobile login recommendation flow."""
    """Main entrypoint for the mobile login recommendation flow."""
    user_id = request.user_id

    keywords = _load_user_keywords(user_id)
    transcript_courses = _load_user_transcript_courses(user_id)
    enrolled_courses = []
    degree_program = _load_user_degree_program(user_id)
    current_semester = ""
    courses = _load_course_catalog()

    return recommend_courses(
        courses=courses,
        user_keywords=keywords,
        transcript_courses=transcript_courses,
        previously_enrolled_courses=enrolled_courses,
        degree_program=degree_program,
        current_semester=current_semester,
        top_n=request.top_n,
    )
