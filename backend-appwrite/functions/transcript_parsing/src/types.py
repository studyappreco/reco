from pydantic import BaseModel, Field
from typing import Optional, List

class TranscriptRow(BaseModel):
    exam_number: Optional[int] = Field(
        None, 
        description="No. of Exam | Prüfungsnr"
    )
    exam_name: Optional[str] = Field(
        None, 
        description="Name of Exam | Bezeichnung der Leistung"
    )
    term: Optional[str] = Field(
        None, 
        description="Term | Semester; starts with Summer or Winter"
    )
    exam_date: Optional[str] = Field(
        None, 
        description="Date of Exam | Prüf. Datum; The schema is dd.MM.yyyy"
    )
    grade: Optional[float] = Field(
        None, 
        description="Grade | Note"
    )
    ects: Optional[float] = Field(
        None, 
        description="Credits | LP"
    )

class Transcript(BaseModel):
    compulsary_electives: List[TranscriptRow] = Field(
        ..., 
        description="Compulsory Elective Modules"
    )
    free_electives: List[TranscriptRow] = Field(
        ..., 
        description="Elective Modules"
    )