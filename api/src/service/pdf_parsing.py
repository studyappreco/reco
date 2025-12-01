
import pdfplumber
import pandas as pd
import io
from pdfplumber.utils import extract_text, get_bbox_overlap, obj_to_bbox
from baml_client import b
from loguru import logger
import base64


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


async def parse_uni_transcript(file_content : bytes):
    text_content : str = get_text_content(file_content=file_content)
    #is_transcript = await b.Is_the_right_content(text_content)
    #logger.info(f"the result {is_transcript}")
    #if(not is_transcript):
    #    raise Exception("Document uploaded is not a university transcript")
    rows = await b.Parse_transcript_contents(text_content)
    return rows
    

