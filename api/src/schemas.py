from pydantic import BaseModel, ConfigDict
from typing import Optional, List, Dict

class Hello_Reco_Response(BaseModel):
    msg : str

# Schema for Admin:

class ModuleBase(BaseModel):
    module_nr: str
    name: Dict[str, str]
    lp_value: int
    module_type: str
    description: Dict[str, str]

    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "module_nr": "40022",
                "name": {"de": "Algorithmen und Datenstrukturen", "en": "Algorithms and Data Structures"},
                "lp_value": 6,
                "module_type": "Vorlesung",
                "description": {"de": "Einführung in Graphen, Sortierverfahren..."},
            }
        }
    )

class ModuleCreate(ModuleBase):
    tags: List[str] = []
    
    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "module_nr": "40022",
                "name": {"de": "Algorithmen und Datenstrukturen"},
                "lp_value": 6,
                "module_type": "Vorlesung",
                "description": {"de": "Beschreibung..."},
                "tags": ["Pflicht", "Informatik"]
            }
        }
    )

class ModuleUpdate(BaseModel):
    name: Optional[Dict[str, str]] = None
    lp_value: Optional[int] = None
    module_type: Optional[str] = None
    description: Optional[Dict[str, str]] = None
    tags: Optional[List[str]] = None

    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "description": {"de": "Neue Beschreibung hier..."},
                "tags": ["Informatik", "Schwer", "Mathe"]
            }
        }
    )

class ModuleRead(ModuleBase):
    id: int
    tags: List[str] = []

    model_config = ConfigDict(from_attributes=True)

class TagCreate(BaseModel):
    name: str


# Schemas for User:

# registration
class StudentCreate(BaseModel):
    email: str
    password: str 
    initial_interests: List[str] = []

# Profile view
class StudentRead(BaseModel):
    id: int
    email: str
    interests: List[str] = []

# Transcript 
class TranscriptRead(BaseModel):
    id: int
    module: ModuleRead
    status: str        # "planned", "passed", "failed", "favorite"
    grade: Optional[float] = None

# Add/update module to plan
class TranscriptCreate(BaseModel):
    module_nr: str
    status: str = "planned" # planned, passed, failed, favorite
    grade: Optional[float] = None

# View of a completed/planned module
class TranscriptRead(BaseModel):
    id: int
    module: ModuleRead
    status: str
    grade: Optional[float] = None

# some statistics TODO add more 
class StudentStats(BaseModel):
    total_lp: int
    average_grade: float
    passed_count: int
    failed_count: int
    planned_count: int