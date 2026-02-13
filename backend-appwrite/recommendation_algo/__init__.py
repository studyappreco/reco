"""Recommendation algorithms package."""

from .api import RecommendationRequest, recommend_for_user
from .content_based import Course, Recommendation, recommend_courses

__all__ = [
    "Course",
    "Recommendation",
    "RecommendationRequest",
    "recommend_courses",
    "recommend_for_user",
]
