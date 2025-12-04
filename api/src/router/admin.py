from fastapi import APIRouter, Depends, HTTPException, Body, Query, Security, status
from fastapi.security import APIKeyHeader
from sqlmodel import Session, select, func
from sqlalchemy import String
from sqlalchemy.dialects.postgresql import JSONB

from src.database import get_db_session
from src.model.tables import Module, Tag, ModuleTagLink, University, StudyProgram, Account, TranscriptRecord, Enrollment
from src.schemas import ModuleCreate, ModuleUpdate, ModuleRead, TagCreate

from src.db.import_data import add_all_modules, add_StudyProgram, DATA_DIR


router = APIRouter(prefix="/admin", tags=["Admin (Still in progress missing and non-functional parts included)"])



def get_or_create_tag(session: Session, tag_name: str) -> Tag:
    tag = session.exec(select(Tag).where(Tag.name == tag_name)).first()
    if not tag:
        tag = Tag(name=tag_name)
        session.add(tag)
        session.commit()
        session.refresh(tag)
    return tag

def get_or_create_university(session: Session, uni_name: str) -> University:
    uni = session.exec(select(University).where(University.name == uni_name)).first()
    if not uni:
        uni = University(name=uni_name)
        session.add(uni)
        session.commit()
        session.refresh(uni)
    return uni



# for Importing static data from json to DB
@router.post("/import/modules")
async def import_module_catalog(
    university_name: str = Query(..., description="Name of the university"),
    filename: str = Body("modules_tu.json", embed=True),
    session: Session = Depends(get_db_session)
):
    uni = get_or_create_university(session, university_name)
    
    # TODO future work: Request the file directly instead of the file path
    file_path = DATA_DIR / filename
    if not file_path.exists():
        raise HTTPException(404, f"File '{filename}' not found")

    try:
        add_all_modules(session, uni, filename)
        return {"status": "success", "university": uni.name}
    except Exception as e:
        raise HTTPException(500, str(e))


@router.post("/import/degree-program")
async def import_degree_program(
    university_name: str = Query(..., description="Name of the university"),
    filename: str = Body("informatik_BA.json", embed=True),
    session: Session = Depends(get_db_session)
):
    uni = get_or_create_university(session, university_name)
    file_path = DATA_DIR / filename

    # TODO future work: Request the file directly instead of the file path
    if not file_path.exists():
        raise HTTPException(404, f"File '{filename}' not found")

    try:
        add_StudyProgram(session, uni, filename)
        return {"status": "success", "university": uni.name}
    except Exception as e:
        raise HTTPException(500, str(e))



@router.get("/overview")
async def get_database_overview(session: Session = Depends(get_db_session)):
    return {
        "modules": session.exec(select(func.count(Module.id))).one(),
        "tags": session.exec(select(func.count(Tag.id))).one(),
        "universities": session.exec(select(func.count(University.id))).one(),
        "study_programs": session.exec(select(func.count(StudyProgram.id))).one(),
        "students": session.exec(select(func.count(Account.id))).one(),
        "enrollments": session.exec(select(func.count(Enrollment.id))).one(),
        "transcript_records": session.exec(select(func.count(TranscriptRecord.id))).one(),
    }

# Tag management
@router.get("/tags")
async def list_tags(session: Session = Depends(get_db_session)):
    tags = session.exec(select(Tag)).all()
    return [{"id": t.id, "name": t.name} for t in tags]


@router.post("/tags", response_model=dict)
async def create_tag(tag: TagCreate, session: Session = Depends(get_db_session)):
    existing = session.exec(select(Tag).where(Tag.name == tag.name)).first()
    if existing:
        raise HTTPException(400, "Tag already exists")

    t = Tag(name=tag.name)
    session.add(t)
    session.commit()
    return {"status": "created", "tag_id": t.id}


@router.delete("/tags/{tag_id}")
async def delete_tag(tag_id: int, session: Session = Depends(get_db_session)):
    tag = session.get(Tag, tag_id)
    if not tag:
        raise HTTPException(404, "Tag not found")

    session.delete(tag)
    session.commit()
    return {"status": "deleted"}


# TODO Module management: (some changes required)
@router.post("/modules", response_model=ModuleRead)
async def create_module(
    module_in: ModuleCreate, 
    university_name: str = Query(..., description="Name of the university"),
    session: Session = Depends(get_db_session)
):
    if session.exec(select(Module).where(Module.module_nr == module_in.module_nr)).first():
        raise HTTPException(400, "Module number already exists")

    uni = session.exec(select(University).where(University.name == university_name)).first()
    if not uni:
        # If university doesn't exist, then create it
        uni = get_or_create_university(session, university_name)

    data = module_in.model_dump(exclude={"tags"})
    db_module = Module(**data, university_id=uni.id)
    
    session.add(db_module)
    session.commit()
    session.refresh(db_module)

    if module_in.tags:
        for tag_name in module_in.tags:
            tag = get_or_create_tag(session, tag_name)
            session.add(ModuleTagLink(module_id=db_module.id, tag_id=tag.id))

    session.commit()
    session.refresh(db_module)

    return ModuleRead(**db_module.model_dump(), tags=[t.name for t in db_module.tags])


@router.get("/modules/search/number")
async def search_modules_by_number(
    query: str = Query(..., description="Search for exact or partial module number"),
    session: Session = Depends(get_db_session)
):
    rslt = select(Module).where(Module.module_nr.ilike(f"%{query}%"))
    results = session.exec(rslt).all()
    return [
        {
            "module_nr": m.module_nr, 
            "name": m.name, 
            "lp": m.lp_value, 
            "university": m.university.name if m.university else "Unknown",
            "tags": [t.name for t in m.tags]
        }
        for m in results
    ]


@router.get("/modules/search/name")
async def search_modules_by_name(
    query: str = Query(..., description="Search inside module name (German/English)"),
    session: Session = Depends(get_db_session)
):
    stmt = select(Module).where(func.cast(Module.name, String).ilike(f"%{query}%"))
    results = session.exec(stmt).all()
    return [
        {
            "module_nr": m.module_nr, 
            "name": m.name, 
            "lp": m.lp_value, 
            "university": m.university.name if m.university else "Unknown",
            "tags": [t.name for t in m.tags]
        }
        for m in results
    ]


@router.patch("/modules/{module_nr}", response_model=ModuleRead)
async def update_module(module_nr: str, update: ModuleUpdate, session: Session = Depends(get_db_session)):
    module = session.exec(select(Module).where(Module.module_nr == module_nr)).first()
    if not module:
        raise HTTPException(404, "Module not found")

    data = update.model_dump(exclude_unset=True, exclude={"tags"})
    for k, v in data.items():
        setattr(module, k, v)

    if update.tags is not None:
        session.exec(select(ModuleTagLink).where(ModuleTagLink.module_id == module.id)).delete()
        for tag_name in update.tags:
            tag = get_or_create_tag(session, tag_name)
            session.add(ModuleTagLink(module_id=module.id, tag_id=tag.id))

    session.commit()
    session.refresh(module)

    return ModuleRead(**module.model_dump(), tags=[t.name for t in module.tags])


@router.delete("/modules/{module_nr}")
async def delete_module(module_nr: str, session: Session = Depends(get_db_session)):
    module = session.exec(select(Module).where(Module.module_nr == module_nr)).first()
    if not module:
        raise HTTPException(404, "Module not found")

    session.delete(module)
    session.commit()
    return {"status": "deleted"}


# TODO User management
@router.get("/users")
async def list_users(session: Session = Depends(get_db_session)):
    users = session.exec(select(Account)).all()
    return [{"id": u.id, "email": u.email, "interests": [t.name for t in u.interests]} for u in users]


@router.delete("/users/{user_id}")
async def delete_user(user_id: int, session: Session = Depends(get_db_session)):
    user = session.get(Account, user_id)
    if not user:
        raise HTTPException(404, "User not found")

    session.delete(user)
    session.commit()

    return {"status": "deleted"}


# TODO Enrollment management
@router.get("/enrollments")
async def list_enrollments(session: Session = Depends(get_db_session)):
    arr = session.exec(select(Enrollment)).all()
    return [
        {
            "id": e.id,
            "user": e.account.email,
            "program": e.program.name,
            "university": e.program.university.name if e.program.university else "?",
            "records": len(e.transcript_records)
        }
        for e in arr
    ]