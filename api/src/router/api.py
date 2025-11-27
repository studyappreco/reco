from fastapi import APIRouter, Depends
from src.schemas import Hello_Reco_Response


router = APIRouter()

@router.get("/hello", response_model=Hello_Reco_Response)
async def hello_reco():
   
   return Hello_Reco_Response(msg = "Hello from reco")
  

    