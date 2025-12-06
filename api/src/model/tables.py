from decimal import Decimal
from typing import Optional, List, Dict
from sqlalchemy.dialects.postgresql import JSONB
from sqlmodel import SQLModel, Field, Relationship

class ModuleTagLink(SQLModel, table=True):
    module_id: int | None = Field(default=None, foreign_key="module.id", primary_key=True)
    tag_id: int | None = Field(default=None, foreign_key="tag.id", primary_key=True)

# for Account interests
class AccountTagLink(SQLModel, table=True):
    account_id: int | None = Field(default=None, foreign_key="account.id", primary_key=True)
    tag_id: int | None = Field(default=None, foreign_key="tag.id", primary_key=True)

class Tag(SQLModel, table=True):
    id: int | None = Field(default=None, primary_key=True)
    name: str = Field(unique=True)
    
    modules: list["Module"] = Relationship(back_populates="tags", link_model=ModuleTagLink)
    interested_users: list["Account"] = Relationship(back_populates="interests", link_model=AccountTagLink)


class StudyProgram(SQLModel, table=True):
    id: int | None = Field(default=None, primary_key=True)
    university_name: str
    name: str
    degree: str | None = None # Bachelor / Master
    requirement_areas: dict = Field(sa_type=JSONB)

class Module(SQLModel, table=True):
    id: int | None = Field(default=None, primary_key=True)
    university_name: str
    module_nr: str
    name: dict = Field(sa_type=JSONB)
    lp_value: int
    module_type: str
    description: dict = Field(sa_type=JSONB)

    tags: list[Tag] = Relationship(back_populates="modules", link_model=ModuleTagLink)
    transcript_records: list["TranscriptRecord"] = Relationship(back_populates="module")

class Account(SQLModel, table=True):
    id: int | None = Field(default=None, primary_key=True)
    email: str = Field(unique=True, index=True)
    password_hash: str
    university_name: str
    study_program_name: str

    interests: list[Tag] = Relationship(back_populates="interested_users", link_model=AccountTagLink)
    transcript_records: list["TranscriptRecord"] = Relationship(back_populates="account")

class TranscriptRecord(SQLModel, table=True):
    id: int | None = Field(default=None, primary_key=True)
    account_id: int = Field(foreign_key="account.id", ondelete="CASCADE")
    module_id: int = Field(foreign_key="module.id", ondelete="CASCADE")
    grade: Decimal | None = Field(default=None, max_digits=3, decimal_places=2)
    status: str = Field(default="planned")
    requirement_area_key: str | None = None

    account: Account = Relationship(back_populates="transcript_records")
    module: Module = Relationship(back_populates="transcript_records")