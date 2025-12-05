from __future__ import annotations
from datetime import datetime
from typing import List, Optional
from sqlalchemy import Column, Float, UniqueConstraint
from sqlalchemy.dialects.postgresql import ARRAY
from sqlmodel import Field, SQLModel


class CourseEmbedding(SQLModel, table=True):
    """
    Stores a single embedding vector for a course along with basic metadata.
    """

    __tablename__ = "course_embeddings"
    __table_args__ = (
        UniqueConstraint("course_number", name="uq_course_embeddings_course_number"),
    )

    id: Optional[int] = Field(default=None, primary_key=True)
    course_number: str = Field(index=True, nullable=False)
    course_name: str = Field(nullable=False)
    description: Optional[str] = Field(default=None, nullable=True)
    embedding: List[float] = Field(sa_column=Column(ARRAY(Float), nullable=False))
    source_language: Optional[str] = Field(default=None, nullable=True)
    created_at: datetime = Field(default_factory=datetime.utcnow, nullable=False)
    updated_at: datetime = Field(default_factory=datetime.utcnow, nullable=False)
