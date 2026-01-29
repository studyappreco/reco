from dotenv import load_dotenv
import os
import json
from tqdm import tqdm
from openai import OpenAI

load_dotenv(r"C:\Users\zohre\develop\reco\backend-appwrite\.env")

if not os.getenv("OPENAI_API_KEY"):
    raise RuntimeError("OPENAI_API_KEY not found. Check your .env file.")

PATH = "data/scraped_data.json"

client = OpenAI()  # reads OPENAI_API_KEY from environment

with open(PATH, "r", encoding="utf-8") as f:
    courses = json.load(f)

for course in tqdm(courses, desc="Embedding courses"):
    parts = [
        course.get("title", ""),
        course.get("learn_outcomes", ""),
        course.get("learn_content", "")
    ]
    text = " ".join(p for p in parts if p).strip()

    if not text:
        course["embedding"] = None
        continue

    response = client.embeddings.create(
        model="text-embedding-3-small",
        input=text,
        dimensions=1536
    )

    course["embedding"] = response.data[0].embedding

with open(PATH, "w", encoding="utf-8") as f:
    json.dump(courses, f, ensure_ascii=False, indent=2)

print("scraped_data.json updated with embeddings")
