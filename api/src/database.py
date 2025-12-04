from sqlmodel import SQLModel, Session, create_engine
from src.settings import Settings
from loguru import logger

settings = Settings()

database_url = settings.database_url()
engine = create_engine(database_url, echo=False, pool_size=15, max_overflow=15)

def init_db():
    logger.info(f"Connecting to database: {database_url}")
    SQLModel.metadata.create_all(engine)
    logger.info("Database tables verified/created")
    return engine

def get_db_session():
    with Session(engine) as session:
        yield session