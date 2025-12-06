from sqlmodel import SQLModel, Field
from loguru import logger
from src.model.tables import (
    StudyProgram,
    Module,
    Tag,
    Account,
    TranscriptRecord,
    ModuleTagLink,
    AccountTagLink
)

class User(SQLModel, table=True):
    id: int | None = Field(default=None, primary_key=True)
    name: str
    email: str
