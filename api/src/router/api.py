from fastapi import APIRouter, Depends, UploadFile, File, HTTPException
from src.schemas import Hello_Reco_Response
from baml_client import b
from src.service.pdf_parsing import parse_uni_transcript
from src.service.exceptions import ImageBasedPDFException, NotTranscriptException
from loguru import logger


router = APIRouter()

@router.get("/hello", response_model=Hello_Reco_Response)
async def hello_reco():
   
   return Hello_Reco_Response(msg = "Hello from reco")


@router.post("/upload-pdf")
async def upload_pdf(file: UploadFile):
    if file.content_type != "application/pdf":
        raise HTTPException(status_code=400, detail="Invalid file type")
    
    try:
        contents = await file.read()
        return await parse_uni_transcript(contents)
    except ImageBasedPDFException as e:
        logger.warning(f"Image-based PDF uploaded: {str(e)}")
        raise HTTPException(status_code=400, detail="Please upload a text-based PDF")
    except NotTranscriptException as e:
        logger.warning(f"Non-transcript document: {str(e)}")
        raise HTTPException(status_code=400, detail="Document is not a valid university transcript")
    except Exception as e:
        logger.exception(f"Unexpected error during PDF parsing: {str(e)}")
        raise HTTPException(status_code=500, detail="Error processing PDF")

   

    