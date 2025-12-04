from fastapi import APIRouter, Depends, HTTPException, Query
from sqlmodel import Session, select, col
from typing import List, Optional

from src.database import get_db_session
from src.model.tables import Account, Tag, Module, TranscriptRecord, Enrollment, StudyProgram, AccountTagLink, ModuleTagLink, University
from src.schemas import StudentCreate, StudentRead, TranscriptCreate, TranscriptRead, StudentStats, ModuleRead

router = APIRouter(prefix="/students", tags=["Student (Still in progress missing and non-functional parts included)"])

def get_student_or_404(session: Session, student_id: int) -> Account:
    student = session.get(Account, student_id)
    if not student:
        raise HTTPException(404, "Student not found")
    return student

def get_or_create_tag(session: Session, tag_name: str) -> Tag:
    tag = session.exec(select(Tag).where(Tag.name == tag_name)).first()
    if not tag:
        tag = Tag(name=tag_name)
        session.add(tag)
        session.commit()
        session.refresh(tag)
    return tag

# Account

@router.post("/register", response_model=StudentRead)
async def register_student(student_in: StudentCreate, session: Session = Depends(get_db_session)):
    existing = session.exec(select(Account).where(Account.email == student_in.email)).first()
    if existing:
        raise HTTPException(400, "Email already registered")

    new_student = Account(email=student_in.email, password_hash=student_in.password)
    session.add(new_student)
    session.commit()
    session.refresh(new_student)

    for tag_name in student_in.initial_interests:
        tag = get_or_create_tag(session, tag_name)
        session.add(AccountTagLink(account_id=new_student.id, tag_id=tag.id))
    
    session.commit()
    session.refresh(new_student)

    return StudentRead(
        id=new_student.id, 
        email=new_student.email, 
        interests=[t.name for t in new_student.interests]
    )

@router.get("/{student_id}", response_model=StudentRead)
async def get_student_profile(student_id: int, session: Session = Depends(get_db_session)):
    student = get_student_or_404(session, student_id)
    return StudentRead(
        id=student.id, 
        email=student.email, 
        interests=[t.name for t in student.interests]
    )

@router.put("/{student_id}/interests", response_model=StudentRead)
async def update_interests(
    student_id: int,
    tags: List[str],
    session: Session = Depends(get_db_session)
):
    student = get_student_or_404(session, student_id)

    old_interests = session.exec(
        select(AccountTagLink).where(AccountTagLink.account_id == student.id)
    ).all()

    for link in old_interests:
        session.delete(link)

    for tag_name in tags:
        tag = get_or_create_tag(session, tag_name)
        new_link = AccountTagLink(account_id=student.id, tag_id=tag.id)
        session.add(new_link)

    session.commit()
    session.refresh(student)

    return StudentRead(
        id=student.id,
        email=student.email,
        interests=[t.name for t in student.interests]
    )


# Enrollment

@router.post("/{student_id}/enroll")
def enroll_in_program(
    student_id: int, 
    program_name: str = Query(..., description="Name of the study program"),
    university_name: str = Query(..., description="Name of the university"),
    session: Session = Depends(get_db_session)
):
    student = get_student_or_404(session, student_id)
    
    program = session.exec(
        select(StudyProgram)
        .join(University)
        .where(StudyProgram.name == program_name)
        .where(University.name == university_name)
    ).first()

    if not program:
        raise HTTPException(404, f"Program '{program_name}' at '{university_name}' not found")

    existing = session.exec(
        select(Enrollment)
        .where(Enrollment.account_id == student.id)
        .where(Enrollment.study_program_id == program.id)
    ).first()
    
    if existing:
        return {
            "status": "already enrolled", 
            "enrollment_id": existing.id, 
            "program_id": program.id
        }

    enrollment = Enrollment(account_id=student.id, study_program_id=program.id)
    session.add(enrollment)
    session.commit()
    session.refresh(enrollment)
    
    return {
        "status": "success", 
        "enrollment_id": enrollment.id, 
        "program_id": program.id
    }

# Module planing

@router.get("/{student_id}/modules", response_model=List[TranscriptRead])
async def get_student_modules(
    student_id: int, 
    program_id: int = Query(..., description="ID of the study program"),
    status: Optional[str] = Query(None, description="Filter: 'planned', 'passed', 'failed', 'favorite'"),
    session: Session = Depends(get_db_session)
):
    student = get_student_or_404(session, student_id)
    
    enrollment = session.exec(
        select(Enrollment)
        .where(Enrollment.account_id == student.id)
        .where(Enrollment.study_program_id == program_id)
    ).first()

    if not enrollment:
        raise HTTPException(404, "Student is not enrolled in this program")

    query = select(TranscriptRecord).where(TranscriptRecord.enrollment_id == enrollment.id)
    
    if status:
        query = query.where(TranscriptRecord.status == status)
        
    records = session.exec(query).all()
    
    results = []
    for r in records:
        mod = r.module
        mod_read = ModuleRead(**mod.model_dump(), tags=[t.name for t in mod.tags])
        results.append(TranscriptRead(id=r.id, status=r.status, grade=r.grade, module=mod_read))
        
    return results

@router.post("/{student_id}/modules", response_model=TranscriptRead)
async def add_or_update_module_status(
    student_id: int, 
    transcript_in: TranscriptCreate, 
    program_id: int = Query(..., description="ID of the study program"),
    session: Session = Depends(get_db_session)
):
    student = get_student_or_404(session, student_id)
    
    enrollment = session.exec(
        select(Enrollment)
        .where(Enrollment.account_id == student.id)
        .where(Enrollment.study_program_id == program_id)
    ).first()

    if not enrollment:
        raise HTTPException(404, "Student is not enrolled in this program")

    module = session.exec(select(Module).where(Module.module_nr == transcript_in.module_nr)).first()
    if not module:
        raise HTTPException(404, "Module not found")

    record = session.exec(
        select(TranscriptRecord)
        .where(TranscriptRecord.enrollment_id == enrollment.id)
        .where(TranscriptRecord.module_id == module.id)
    ).first()

    if record:
        record.status = transcript_in.status
        record.grade = transcript_in.grade
        session.add(record)
    else:
        record = TranscriptRecord(
            enrollment_id=enrollment.id,
            module_id=module.id,
            status=transcript_in.status,
            grade=transcript_in.grade
        )
        session.add(record)
    
    session.commit()
    session.refresh(record)

    module_read = ModuleRead(**module.model_dump(), tags=[t.name for t in module.tags])
    return TranscriptRead(
        id=record.id,
        status=record.status,
        grade=record.grade,
        module=module_read
    )


# statistics & recommendations

@router.get("/{student_id}/stats", response_model=StudentStats)
async def get_student_stats(
    student_id: int, 
    program_id: int = Query(..., description="Calculate stats for specific program"),
    session: Session = Depends(get_db_session)
):
    student = get_student_or_404(session, student_id)
    
    enrollment = session.exec(
        select(Enrollment)
        .where(Enrollment.account_id == student.id)
        .where(Enrollment.study_program_id == program_id)
    ).first()

    if not enrollment:
        raise HTTPException(404, "Student is not enrolled in this program")

    records = session.exec(
        select(TranscriptRecord).where(TranscriptRecord.enrollment_id == enrollment.id)
    ).all()

    total_lp = 0
    grade_sum = 0.0
    graded_count = 0
    passed, failed, planned = 0, 0, 0

    for r in records:
        if r.status == "passed":
            passed += 1
            if r.module:
                total_lp += r.module.lp_value
            if r.grade and r.grade > 0:
                grade_sum += float(r.grade)
                graded_count += 1
        elif r.status == "failed":
            failed += 1
        elif r.status == "planned":
            planned += 1

    avg = (grade_sum / graded_count) if graded_count > 0 else 0.0

    return StudentStats(
        total_lp=total_lp,
        average_grade=round(avg, 2),
        passed_count=passed,
        failed_count=failed,
        planned_count=planned
    )

@router.get("/{student_id}/recommendations", response_model=List[ModuleRead])
async def get_recommendations(
    student_id: int, 
    program_id: int = Query(..., description="ID of the study program"),
    tags: Optional[List[str]] = Query(None, description="Filter by tags"),
    session: Session = Depends(get_db_session)
):
    student = get_student_or_404(session, student_id)
    
    enrollment = session.exec(
        select(Enrollment)
        .where(Enrollment.account_id == student.id)
        .where(Enrollment.study_program_id == program_id)
    ).first()

    if not enrollment:
        raise HTTPException(404, "Student is not enrolled in this program")

    target_tag_ids = []
    if tags:
        target_tags = session.exec(select(Tag).where(Tag.name.in_(tags))).all()
        target_tag_ids = [t.id for t in target_tags]
        if not target_tag_ids:
            return [] 
    else:
        # Fallback auf Interessen
        if not student.interests:
            return []
        target_tag_ids = [t.id for t in student.interests]

    query = (
        select(Module)
        .join(ModuleTagLink)
        .where(ModuleTagLink.tag_id.in_(target_tag_ids))
        .distinct()
    )
    
    # Only modules from the relevant university
    if enrollment.program and enrollment.program.university_id:
        query = query.where(Module.university_id == enrollment.program.university_id)

    # Exclude modules already taken 
    taken_modules = (
        select(TranscriptRecord.module_id)
        .join(Enrollment)
        .where(Enrollment.account_id == student.id)
        .where(col(TranscriptRecord.status).in_(["passed", "planned"]))
    )
    query = query.where(col(Module.id).notin_(taken_modules))

    # TODO Now analyze the modules using our recommendation systems and then output the data


    # TODO Limiting ?
    recos = session.exec(query.limit(30)).all()
    
    return [ModuleRead(**m.model_dump(), tags=[t.name for t in m.tags]) for m in recos]