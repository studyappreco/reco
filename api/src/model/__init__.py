from sqlmodel import SQLModel, Field
from loguru import logger
from .course_embedding import CourseEmbedding 

class User(SQLModel, table=True):
    id: int | None = Field(default=None, primary_key=True)
    name: str
    email: str
