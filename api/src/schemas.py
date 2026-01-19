from pydantic import BaseModel, ConfigDict
# for the API schemas

class Hello_Reco_Response(BaseModel):
    msg : str


class UserCreate(BaseModel):
    name: str
    email: str
    password: str


class UserOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    name: str
    email: str


class Token(BaseModel):
    access_token: str
    token_type: str
