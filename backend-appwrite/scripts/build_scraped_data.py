import json
import os
import sys

from dotenv import load_dotenv
from openai import OpenAI

TAGS = [
    "AI",
    "Machine Learning",
    "Deep Learning",
    "Neural Networks",
    "Computer Vision",
    "Natural Language Processing",
    "Information Retrieval",
    "Data Science",
    "Data Analysis",
    "Big Data",
    "Data Mining",
    "Databases",
    "Database Systems",
    "Distributed Systems",
    "Operating Systems",
    "Embedded Systems",
    "Cybersecurity",
    "Cryptography",
    "Privacy",
    "Networks",
    "Wireless Networks",
    "Sensor Networks",
    "Cloud Computing",
    "Edge Computing",
    "Internet of Things",
    "Robotics",
    "Autonomous Systems",
    "Software Engineering",
    "Software Architecture",
    "Software Testing",
    "Quality Assurance",
    "Requirements Engineering",
    "Project Management",
    "Agile Methods",
    "DevOps",
    "Web Development",
    "Mobile Computing",
    "Human-Computer Interaction",
    "Data Visualization",
    "Signal Processing",
    "Control Systems",
    "Real-Time Systems",
    "Computer Architecture",
    "Hardware Design",
    "FPGA",
    "VLSI Design",
    "Electronics",
    "Communication Systems",
    "Information Systems",
    "Business Informatics",
    "Digital Transformation",
    "E-Commerce",
    "FinTech",
    "Blockchain",
    "Smart Mobility",
    "Automotive Systems",
    "Safety-Critical Systems",
    "Formal Methods",
    "Algorithms",
    "Optimization",
    "Computational Theory",
    "Graph Theory",
    "Probability",
    "Statistics",
    "Numerical Methods",
    "Simulation",
    "Modeling",
    "Systems Engineering",
    "Research Methods",
    "Case Studies",
    "Innovation Management",
    "Technology Management",
    "Ethics",
    "Responsible AI",
    "Climate Change",
    "Earth Observation",
    "Remote Sensing",
    "Geoinformatics",
    "Bioinformatics",
    "Health Informatics",
    "Digital Health",
    "Educational Technology",
    "Open Source",
    "Software Metrics",
    "Product Design",
    "UX Design",
    "Service Design",
    "Knowledge Management",
    "Data Governance",
    "Security Engineering",
    "Identity Management",
    "Access Control",
    "Network Security",
    "Secure Systems",
    "Applied AI",
    "AI Policy",
    "Computer Graphics",
    "Digital Identity",
    "Software Project",
    "Systems Modeling",
    "Python",
    "Java",
    "C",
    "R",
    "SQL",
    "MATLAB",
    "Haskell",
    "HTML",
]

SCHEMA = {
    "name": "course_enrichment",
    "schema": {
        "type": "object",
        "additionalProperties": False,
        "properties": {
            "course_summary": {"type": "string"},
            "keywords": {
                "type": "array",
                "items": {"type": "string"},
                "minItems": 0,
                "maxItems": 5,
            },
        },
        "required": ["course_summary", "keywords"],
    },
    "strict": True,
}


def load_json(path: str):
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)


def build_prompt(course: dict, tags: list[str]) -> str:
    return (
        "Summarize the course and choose up to 5 tags only from the fixed list.\n\n"
        f"Title: {course.get('title','')}\n"
        f"Learning outcomes: {course.get('learn_outcomes') or course.get('learn_result') or ''}\n"
        f"Learning content: {course.get('learn_content','')}\n\n"
        f"Fixed tags list (choose only from these): {', '.join(tags)}\n\n"
        "Return JSON with fields course_summary (string) and keywords (array)."
    )


def clean_keywords(keywords: list[str], allowed: list[str]) -> list[str]:
    allowed_map = {t.lower(): t for t in allowed}
    out = []
    seen = set()
    for kw in keywords:
        if not isinstance(kw, str):
            continue
        key = kw.strip().lower()
        if not key or key not in allowed_map or key in seen:
            continue
        seen.add(key)
        out.append(allowed_map[key])
        if len(out) >= 5:
            break
    return out


def enrich(client: OpenAI, model: str, course: dict, tags: list[str]) -> dict:
    resp = client.chat.completions.create(
        model=model,
        messages=[{"role": "user", "content": build_prompt(course, tags)}],
        response_format={"type": "json_schema", "json_schema": SCHEMA},
        temperature=0.3,
        max_tokens=300,
    )
    data = json.loads(resp.choices[0].message.content or "{}")
    data["keywords"] = clean_keywords(data.get("keywords", []), tags)
    data["course_summary"] = (data.get("course_summary") or "").strip()
    return data


def main() -> int:
    load_dotenv(os.path.join(os.path.dirname(__file__), "..", ".env"))
    tags = [t.strip() for t in TAGS if str(t).strip()]
    if not tags:
        print("Missing fixed tag list. Fill TAGS in the script.", file=sys.stderr)
        return 2

    input_path = "data/scraped_courses.json"
    output_path = "data/scraped_data.json"
    model = os.getenv("OPENAI_MODEL", "gpt-4o-mini")
    courses = load_json(input_path)
    client = OpenAI()

    out = []
    for idx, course in enumerate(courses):
        title = course.get("title") or "<no title>"
        number = course.get("number")
        print(f"[processing] {idx} number={number} title={title}")
        e = enrich(client, model, course, tags)
        merged = {}
        for k, v in course.items():
            merged[k] = v
            if k == "learn_content":
                merged["course_summary"] = e["course_summary"]
                merged["Keywords"] = e["keywords"]
        if "learn_content" not in course:
            merged["course_summary"] = e["course_summary"]
            merged["Keywords"] = e["keywords"]
        out.append(merged)
        print(f"[done] {idx} keywords={len(merged.get('Keywords', []))}")

    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(out, f, ensure_ascii=True, indent=2)
        f.write("\n")
    print(f"Wrote {len(out)} courses to {output_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
