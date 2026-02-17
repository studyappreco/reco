"""Upload courses from JSON to MongoDB."""
import json
import os
import sys
from pathlib import Path

from dotenv import load_dotenv
from pymongo import MongoClient
from scripts.data_pipeline import OUTPUT_PATH, load_json

FIELD_DEFAULTS = {
    "number": 0,
    "version": 0,
    "title" : "",
    "url": "",
    "credits": "",
    "exam_type": "",
    "language": "",
    "responsible": "",
    "term": "",
    "learn_outcomes": "",
    "learn_content": "",
    "course_summary": "",
    "keywords": [],
    "embedding": [],
    "paths": {},
}




def ensure_fields(course: dict) -> dict:
    """Return course with all required fields, using defaults for missing ones."""
    return {field: course.get(field, default) for field, default in FIELD_DEFAULTS.items()}


def upload_courses(collection, courses: list[dict]) -> int:
    """Insert courses to MongoDB. Returns success count."""
    for idx, course in enumerate(courses):
        doc = ensure_fields(course)
        collection.insert_one(doc)
        print(f"[{idx}] Inserted: {doc['number']} v{doc['version']}")
    return len(courses)


def main():
    load_dotenv()

    uri = os.getenv("MONGODB_URI")
    db_name = os.getenv("MONGO_DB", "reco_db")
    collection_name = os.getenv("MONGO_COLLECTION", "courses_info")

    if not uri:
        print("Error: MONGO_URI not set", file=sys.stderr)
        sys.exit(1)

    courses = load_json(OUTPUT_PATH)

    client = MongoClient(uri)
    collection = client[db_name][collection_name]

    count = upload_courses(collection, courses)
    print(f"\nDone: {count} courses uploaded")


if __name__ == "__main__":
    main()
