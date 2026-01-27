import argparse
import json
import os
import sys
import time
from typing import Any, Dict, List, Tuple

from dotenv import load_dotenv
from openai import OpenAI
from pymongo import MongoClient


SCHEMA = {
    "name": "course_enrichment",
    "description": "Summarize a course and extract keywords.",
    "schema": {
        "type": "object",
        "additionalProperties": False,
        "properties": {
            "course_summary": {"type": "string"},
            "keyword_tags": {
                "type": "array",
                "items": {"type": "string"},
                "minItems": 1,
                "maxItems": 5,
            },
        },
        "required": ["course_summary", "keyword_tags"],
    },
    "strict": True,
}


def build_prompt(course: Dict[str, Any]) -> str:
    outcomes = course.get("learn_outcomes") or course.get("learn_result") or ""
    content = course.get("learn_content") or ""
    title = course.get("title") or ""
    return (
        "Summarize the course and extract up to 5 concise keyword tags.\n\n"
        f"Title: {title}\n"
        f"Learning outcomes: {outcomes}\n"
        f"Learning content: {content}\n\n"
        "Return JSON with fields course_summary (string) and keyword_tags (array)."
    )


def clean_keywords(keywords: List[str]) -> List[str]:
    seen = set()
    cleaned: List[str] = []
    for kw in keywords:
        if not isinstance(kw, str):
            continue
        k = kw.strip()
        if not k:
            continue
        key = k.lower()
        if key in seen:
            continue
        seen.add(key)
        cleaned.append(k)
        if len(cleaned) >= 5:
            break
    return cleaned


def generate_enrichment(client: OpenAI, model: str, course: Dict[str, Any]) -> Dict[str, Any]:
    response = client.chat.completions.create(
        model=model,
        messages=[{"role": "user", "content": build_prompt(course)}],
        response_format={"type": "json_schema", "json_schema": SCHEMA},
        temperature=0.3,
        max_tokens=300,
    )
    content = response.choices[0].message.content or ""
    data = json.loads(content)
    data["keyword_tags"] = clean_keywords(data.get("keyword_tags", []))
    if not data["keyword_tags"]:
        data["keyword_tags"] = ["course"]
    data["course_summary"] = (data.get("course_summary") or "").strip()
    return data


def load_courses(path: str) -> List[Dict[str, Any]]:
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)


def connect_mongo(uri: str, db_name: str, collection_name: str):
    client = MongoClient(uri)
    return client[db_name][collection_name]


def upsert_courses(
    collection,
    courses: List[Dict[str, Any]],
    client: OpenAI,
    model: str,
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
            enrichment = generate_enrichment(client, model, course)
            doc = dict(course)
            doc["course_summary"] = enrichment["course_summary"]
            doc["keyword_tags"] = enrichment["keyword_tags"]

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


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Enrich courses with AI-generated fields and insert into MongoDB."
    )
    parser.add_argument(
        "--input",
        default="data/scraped_courses.json",
        help="Path to the scraped courses JSON file.",
    )
    parser.add_argument(
        "--mongo-uri",
        default=os.getenv("MONGODB_URI", os.getenv("MONGO_URI", "")),
        help="MongoDB connection string. Defaults to env MONGODB_URI or MONGO_URI.",
    )
    parser.add_argument(
        "--db",
        default=os.getenv("MONGODB_DB", "reco_db"),
        help="MongoDB database name. Defaults to env MONGODB_DB or 'reco_db'.",
    )
    parser.add_argument(
        "--collection",
        default=os.getenv("MONGODB_COLLECTION", "courses_info"),
        help="MongoDB collection name. Defaults to env MONGODB_COLLECTION or 'courses_info'.",
    )
    parser.add_argument(
        "--model",
        default=os.getenv("OPENAI_MODEL", "gpt-4o-mini"),
        help="OpenAI model name. Defaults to env OPENAI_MODEL or gpt-4o-mini.",
    )
    parser.add_argument(
        "--delay",
        type=float,
        default=0.0,
        help="Optional delay in seconds between API calls.",
    )
    parser.add_argument(
        "--limit",
        type=int,
        default=0,
        help="Optional max number of courses to process (0 = all).",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Run generation but do not insert into MongoDB.",
    )
    return parser.parse_args()


def main() -> int:
    env_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".env"))
    load_dotenv(dotenv_path=env_path)
    args = parse_args()
    if not args.mongo_uri and not args.dry_run:
        print("Missing MongoDB URI. Set MONGODB_URI or pass --mongo-uri.", file=sys.stderr)
        return 2
    if not args.db and not args.dry_run:
        print("Missing MongoDB DB name. Set MONGODB_DB or pass --db.", file=sys.stderr)
        return 2

    courses = load_courses(args.input)
    client = OpenAI()

    collection = None
    if not args.dry_run:
        collection = connect_mongo(args.mongo_uri, args.db, args.collection)

    inserted, failed = upsert_courses(
        collection,
        courses,
        client,
        args.model,
        args.delay,
        args.dry_run,
        args.limit,
    )
    print(f"Inserted: {inserted}, Failed: {failed}")
    return 0 if failed == 0 else 1


if __name__ == "__main__":
    raise SystemExit(main())
