from fastapi import Request
from sqlmodel import Session


def get_session(request: Request):
    engine = request.app.state.engine
    if engine is None:
        raise RuntimeError("Database engine is not initialized")
    with Session(engine) as session:
        yield session
