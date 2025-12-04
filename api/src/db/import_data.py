import json
import sys
from pathlib import Path
from sqlmodel import Session, select, create_engine, SQLModel

current_file = Path(__file__).resolve()
project_root = current_file.parent.parent.parent 
sys.path.append(str(project_root))

from src.settings import Settings
from src.model.tables import University, StudyProgram, Module, Tag, ModuleTagLink

DATA_DIR = project_root / "src" / "data"

def get_or_create_tag(session: Session, tag_name: str) -> Tag:
    tag = session.exec(select(Tag).where(Tag.name == tag_name)).first()
    if not tag:
        tag = Tag(name=tag_name)
        session.add(tag)
        session.commit()
        session.refresh(tag)
    return tag

def sync_program_tags(session: Session, tag_name: str, target_module_nrs: list[str]):
    tag = get_or_create_tag(session, tag_name)
    
    existing_links = session.exec(
        select(ModuleTagLink).where(ModuleTagLink.tag_id == tag.id)
    ).all()

    for link in existing_links:
        module = session.get(Module, link.module_id)
        if module and module.module_nr not in target_module_nrs:
            session.delete(link)
    
    session.commit()

    for mod_nr in target_module_nrs:
        module = session.exec(select(Module).where(Module.module_nr == mod_nr)).first()
        if not module:
            print(f"WARNUNG: Modul {mod_nr} (Tag: {tag_name}) nicht gefunden!")
            continue

        link = session.exec(
            select(ModuleTagLink)
            .where(ModuleTagLink.module_id == module.id)
            .where(ModuleTagLink.tag_id == tag.id)
        ).first()

        if not link:
            session.add(ModuleTagLink(module_id=module.id, tag_id=tag.id))
    
    session.commit()

# Adds all modules to the database that are in the given JSON file.
def add_all_modules(session: Session, uni: University, filename: str):
    modules_file = DATA_DIR / filename
    if not modules_file.exists():
        print(f"Datei nicht gefunden: {modules_file}")
        return

    with open(modules_file, "r", encoding="utf-8") as f:
        modules_data = json.load(f)

    print(f"Importiere {len(modules_data)} Module...")
    
    for mod_data in modules_data:
        mod_nr = str(mod_data["module_nr"])
        module = session.exec(
            select(Module)
            .where(Module.module_nr == mod_nr)
            .where(Module.university_id == uni.id)
        ).first()

        name_data = mod_data.get("name", {})
        desc_data = mod_data.get("description", {})
        lp = mod_data.get("lp_value", 0)
        m_type = mod_data.get("module_type", "Vorlesung")

        if not module:
            module = Module(
                university_id=uni.id,
                module_nr=mod_nr,
                name=name_data,
                lp_value=lp,
                module_type=m_type,
                description=desc_data
            )
            session.add(module)
        else:
            module.name = name_data
            module.lp_value = lp
            module.module_type = m_type
            module.description = desc_data
            session.add(module)
        
        session.commit()
        session.refresh(module)

        for t_name in mod_data.get("tags", []):
            tag = get_or_create_tag(session, t_name)
            link = session.exec(
                select(ModuleTagLink)
                .where(ModuleTagLink.module_id == module.id)
                .where(ModuleTagLink.tag_id == tag.id)
            ).first()
            if not link:
                session.add(ModuleTagLink(module_id=module.id, tag_id=tag.id))
        session.commit()

# Adds StudyProgram to the database that are in the given JSON file.
def add_StudyProgram(session: Session, uni: University, filename: str):
    prog_file = DATA_DIR / filename
    if not prog_file.exists():
        return

    with open(prog_file, "r", encoding="utf-8") as f:
        data = json.load(f)

    prog_name = data['program_name']
    prog_degree = data.get('degree')

    print(f"Sync Studiengang: {prog_name} ({prog_degree})")

    program = session.exec(
        select(StudyProgram)
        .where(StudyProgram.name == prog_name)
        .where(StudyProgram.degree == prog_degree)
        .where(StudyProgram.university_id == uni.id)
    ).first()

    if not program:
        program = StudyProgram(
            name=prog_name,
            degree=prog_degree,
            university_id=uni.id,
            requirement_areas=data['requirement_areas']
        )
        session.add(program)
    else:
        program.requirement_areas = data['requirement_areas']
        session.add(program)
    
    session.commit()
    
    mappings = data.get("module_maps", {})
    for tag_name, module_nrs in mappings.items():
        clean_nrs = [str(nr) for nr in module_nrs]
        sync_program_tags(session, tag_name, clean_nrs)
