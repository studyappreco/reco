import asyncio

from pydantic import BaseModel
from enum import IntEnum
from ollama import AsyncClient

class EnglishResult(BaseModel):
    res: bool

schema = {
    "type": "object",
    "properties": {
        "res": {"type": "boolean"}
    },
    "required": ["res"]
}

async def main():
    client = AsyncClient(
        host='http://localhost:11434',
        headers={}
    )
    response = await client.chat(
            model="llama3.2:latest",
            messages=[
            {"role": "system", "content": "Detect if the system is english"},
            {"role": "user", "content": "Hey my name is Joris."}
        ],
        format=schema
    )

    result = EnglishResult.model_validate_json(response.message.content)
    print(result.res)  

if __name__ == '__main__':
  asyncio.run(main())