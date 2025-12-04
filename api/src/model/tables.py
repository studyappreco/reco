from datetime import datetime, timezone
from decimal import Decimal
from typing import Optional, List, Dict

# for being able to use JSONB
from sqlalchemy.dialects.postgresql import JSONB 

from sqlmodel import SQLModel, Field, Relationship

# I have created three tables that are not included in the ER diagram:
# extra table needed for later (Future Work)
class ModuleTagLink(SQLModel, table=True):
    module_id: int | None = Field(default=None, foreign_key="module.id", primary_key=True)
    tag_id: int | None = Field(default=None, foreign_key="tag.id", primary_key=True)

# extra table needed for Account interests
class AccountTagLink(SQLModel, table=True):
    account_id: int | None = Field(default=None, foreign_key="account.id", primary_key=True)
    tag_id: int | None = Field(default=None, foreign_key="tag.id", primary_key=True)

# extra table needed for later (Future Work)
class Tag(SQLModel, table=True):
    id: int | None = Field(default=None, primary_key=True)
    name: str = Field(unique=True) 
    modules: list["Module"] = Relationship(back_populates="tags", link_model=ModuleTagLink)
    interested_users: list["Account"] = Relationship(back_populates="interests", link_model=AccountTagLink)


# Academic Structure (The Static Data):

class University(SQLModel, table=True):
    id: int | None = Field(default=None, primary_key=True)
    name: str = Field(unique=True, index=True)

    programs: list["StudyProgram"] = Relationship(back_populates="university")
    modules: list["Module"] = Relationship(back_populates="university")


class StudyProgram(SQLModel, table=True):
    id: int | None = Field(default=None, primary_key=True)
    university_id: int = Field(foreign_key="university.id", ondelete="CASCADE")
    name: str
    degree: str | None = None
    
    requirement_areas: dict = Field(sa_type=JSONB)

    university: University = Relationship(back_populates="programs")
    enrollments: list["Enrollment"] = Relationship(back_populates="program")

class Module(SQLModel, table=True):
    id: int | None = Field(default=None, primary_key=True)
    university_id: int = Field(foreign_key="university.id", ondelete="CASCADE")
    module_nr: str  # instead of int => str, because it may be different at other universities
    name: dict = Field(sa_type=JSONB)
    
    lp_value: int
    module_type: str
    description: dict = Field(sa_type=JSONB)
    tags: list[Tag] = Relationship(back_populates="modules", link_model=ModuleTagLink)

    # needed later (Future Work)
    average_rating: float = Field(default=0.0)
    review_count: int = Field(default=0)

    university: University = Relationship(back_populates="modules")
    transcript_records: list["TranscriptRecord"] = Relationship(back_populates="module")
    reviews: list["ModuleReview"] = Relationship(back_populates="module")



# User & Enrollment (The Connection):

class Account(SQLModel, table=True):
    id: int | None = Field(default=None, primary_key=True)
    email: str = Field(unique=True, index=True)
    
    password_hash: str
    
    interests: list[Tag] = Relationship(back_populates="interested_users", link_model=AccountTagLink)

    enrollments: list["Enrollment"] = Relationship(back_populates="account")


class Enrollment(SQLModel, table=True):
    id: int | None = Field(default=None, primary_key=True)
    account_id: int = Field(foreign_key="account.id", ondelete="CASCADE")
    study_program_id: int = Field(foreign_key="studyprogram.id", ondelete="CASCADE")
    
    account: Account = Relationship(back_populates="enrollments")
    program: StudyProgram = Relationship(back_populates="enrollments")
    transcript_records: list["TranscriptRecord"] = Relationship(back_populates="enrollment")


# Progress & Feedback (The Dynamic Data):

class TranscriptRecord(SQLModel, table=True):
    id: int | None = Field(default=None, primary_key=True)
    enrollment_id: int = Field(foreign_key="enrollment.id", ondelete="CASCADE")
    module_id: int = Field(foreign_key="module.id", ondelete="CASCADE")
    
    grade: Decimal | None = Field(default=None, max_digits=3, decimal_places=2)
    status: str = Field(default="planned")
    
    requirement_area_key: str | None = None 

    enrollment: Enrollment = Relationship(back_populates="transcript_records")
    module: Module = Relationship(back_populates="transcript_records")
    review: Optional["ModuleReview"] = Relationship(back_populates="transcript_record")


# Future Work
class ModuleReview(SQLModel, table=True):
    id: int | None = Field(default=None, primary_key=True)
    transcript_record_id: int = Field(foreign_key="transcriptrecord.id", ondelete="CASCADE", unique=True)
    module_id: int = Field(foreign_key="module.id", ondelete="CASCADE")
    
    rating_stars: int
    comment_text: str | None = None
    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))

    transcript_record: TranscriptRecord = Relationship(back_populates="review")
    module: Module = Relationship(back_populates="reviews")