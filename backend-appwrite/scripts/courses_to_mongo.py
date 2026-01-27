import json
import os
import sys
import time
from typing import Any, Dict, List, Tuple

from dotenv import load_dotenv
from pymongo import MongoClient


def load_courses(path: str) -> List[Dict[str, Any]]:
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)


def connect_mongo(uri: str, db_name: str, collection_name: str):
    client = MongoClient(uri)
    return client[db_name][collection_name]


def upsert_courses(
    collection,
    courses: List[Dict[str, Any]],
    delay_s: float,
    dry_run: bool,
    limit: int,
) -> Tuple[int, int]:
    inserted = 0
    failed = 0
    for idx, course in enumerate(courses):
        if limit and idx >= limit:
            break
        try:
            doc = dict(course)
            if not dry_run:
                collection.insert_one(doc)
                title = doc.get("title") or "<no title>"
                number = doc.get("number")
                version = doc.get("version")
                print(f"[inserted] {idx} number={number} version={version} title={title}")
            inserted += 1
        except Exception as exc:
            failed += 1
            print(f"[warn] failed course at index {idx}: {exc}", file=sys.stderr)

        if delay_s:
            time.sleep(delay_s)
    return inserted, failed


def main() -> int:
    env_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".env"))
    load_dotenv(dotenv_path=env_path)
    input_path = "data/scraped_data.json"
    mongo_uri = os.getenv("MONGODB_URI", os.getenv("MONGO_URI", ""))
    db_name = os.getenv("MONGODB_DB", "reco_db")
    collection_name = os.getenv("MONGODB_COLLECTION", "courses_info")
    delay_s = 0.0
    limit = 0
    dry_run = False

    if not mongo_uri and not dry_run:
        print("Missing MongoDB URI. Set MONGODB_URI or MONGO_URI.", file=sys.stderr)
        return 2
    if not db_name and not dry_run:
        print("Missing MongoDB DB name. Set MONGODB_DB.", file=sys.stderr)
        return 2

    courses = load_courses(input_path)
    collection = None
    if not dry_run:
        collection = connect_mongo(mongo_uri, db_name, collection_name)

    inserted, failed = upsert_courses(
        collection,
        courses,
        delay_s,
        dry_run,
        limit,
    )
    print(f"Inserted: {inserted}, Failed: {failed}")
    return 0 if failed == 0 else 1


if __name__ == "__main__":
    raise SystemExit(main())
