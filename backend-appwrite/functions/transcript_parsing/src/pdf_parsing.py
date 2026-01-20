
import pdfplumber
import pandas as pd
import io
from pdfplumber.utils import extract_text, get_bbox_overlap, obj_to_bbox
from baml_client import b
from baml_client.types import DocumentType

import base64
from src.service.exceptions import ImageBasedPDFException, NotTranscriptException

# to disable verbose logs: https://github.com/jsvine/pdfplumber/discussions/529
import logging

logging.getLogger("pdfminer").propagate = False
logging.getLogger("pdfminer").disabled = True

def get_text_content(file_content : bytes):
    with pdfplumber.open(io.BytesIO(file_content)) as pdf:
        all_text = []
        for page in pdf.pages:
            filtered_page = page
            chars = filtered_page.chars
            for table in page.find_tables():
                first_table_char = page.crop(table.bbox).chars[0]
                filtered_page = filtered_page.filter(lambda obj: 
                    get_bbox_overlap(obj_to_bbox(obj), table.bbox) is None
                )
                chars = filtered_page.chars
                df = pd.DataFrame(table.extract())
                logger.info(df)
                df.columns = df.iloc[0]
                markdown = df.drop(0).to_markdown(index=False)
                logger.info(markdown)
                chars.append(first_table_char | {"text": markdown})
            page_text = extract_text(chars, layout=True)
            all_text.append(page_text)
        return "\n".join(all_text)


def is_text_based(file_content : bytes) -> bool:
    with pdfplumber.open(io.BytesIO(file_content)) as pdf:
        text_pages = 0
        image_pages = 0

        for page in pdf.pages:
            text = page.extract_text()
            if text and text.strip():
                text_pages += 1
            if len(page.images) > 0:
                image_pages += 1

    if text_pages > 0 and text_pages >= image_pages:
        return True
    else:
        return False

async def parse_uni_transcript(file_content : bytes):
    #check if it is a textbased pdf
    text_based = is_text_based(file_content=file_content)
    if not text_based:
        raise ImageBasedPDFException("Document uploaded is an image based PDF")
    logger.info(f"PDF is text-based: {text_based}")
    text_content : str = get_text_content(file_content=file_content)
    is_transcript = await b.Is_the_right_content(text_content)
    logger.info(f"is transcript: {is_transcript}")
    if is_transcript == DocumentType.IS_NOT_TRANSCRIPT:
        raise NotTranscriptException("Document uploaded is not a university transcript")
    return await b.Parse_transcript_contents(text_content)