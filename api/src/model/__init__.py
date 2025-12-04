from sqlmodel import SQLModel, Field
from loguru import logger
from src.model.tables import (
    University,
    StudyProgram,
    Module,
    Tag,
    Account,
    Enrollment,
    TranscriptRecord,
    ModuleReview,
    ModuleTagLink,
    AccountTagLink
)

''' old code TODO delete it after testing
class User(SQLModel, table=True):
    id: int | None = Field(default=None, primary_key=True)
    name: str
    email: str
'''