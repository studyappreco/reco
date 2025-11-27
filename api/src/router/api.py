from fastapi import APIRouter, Depends
from src.schemas import Hello_Reco_Response
from baml_client import b


router = APIRouter()

@router.get("/hello", response_model=Hello_Reco_Response)
async def hello_reco():
   
   return Hello_Reco_Response(msg = "Hello from reco")


@router.get("/funny_story")
async def funny_story():

   return await b.Funny_story()
  

    