from sqlmodel import SQLModel, Field
from typing import Optional, List
from datetime import datetime

Class CourseEmbedding(SQLModel, table=True):
    __tablename__ = "course_embeddings"
    id: Optional[int] = Field(default=None, primary_key=True)
    course_id: int = Field(foreign_key="courses.id", nullable=False)
    course_name: str = Field(nullable=False)
    embedding_vector: List[float] = Field(sa_column_kwargs={"type_": "FLOAT[]"}, nullable=False)
    description: Optional[str] = Field(default=None, nullable=True)
    created_at: datetime = Field(default_factory=datetime.utcnow, nullable=False)
