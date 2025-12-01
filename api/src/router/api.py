from fastapi import APIRouter, Depends, UploadFile, File, HTTPException
from src.schemas import Hello_Reco_Response
from baml_client import b
from src.service.pdf_parsing import parse_uni_transcript


router = APIRouter()

@router.get("/hello", response_model=Hello_Reco_Response)
async def hello_reco():
   
   return Hello_Reco_Response(msg = "Hello from reco")


@router.get("/funny_story")
async def funny_story():

   return await b.Funny_story()



@router.post("/upload-pdf")
async def upload_pdf(file: UploadFile):
   if file.content_type != "application/pdf":
      raise HTTPException(status_code=400, detail="Invalid file type. Only PDFs allowed.")

   contents = await file.read()
   return await parse_uni_transcript(contents)

   

    