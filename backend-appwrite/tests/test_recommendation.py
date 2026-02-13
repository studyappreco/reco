import importlib.util
import os
import sys
import unittest
from unittest import mock

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
sys.path.insert(0, ROOT)

_CONTENT_BASED_PATH = os.path.join(ROOT, "recommendation_algo", "content_based.py")
_spec = importlib.util.spec_from_file_location("recommendation_algo.content_based", _CONTENT_BASED_PATH)
content_based = importlib.util.module_from_spec(_spec)
sys.modules[_spec.name] = content_based
assert _spec and _spec.loader
_spec.loader.exec_module(content_based)


TRANSCRIPT_SAMPLE = {
    "children": [
        {
            "name": "compulsory_electives",
            "children": [
                {
                    "name": "data_and_software_engineering",
                    "courses": [
                        {
                            "id": "2350790",
                            "name": "Natural Language Processing",
                            "ects": 6,
                            "grade": 2,
                            "examDate": "05.08.2025",
                        }
                    ],
                },
                {
                    "name": "embedded_systems_and_computer_architectures",
                    "courses": [
                        {
                            "id": "2351588",
                            "name": "Algorithms for Distributed Systems",
                            "ects": 6,
                            "grade": 2.3,
                            "examDate": "01.10.2025",
                        }
                    ],
                },
                {"name": "foundations_of_computing", "courses": []},
                {
                    "name": "cognitive_systems",
                    "courses": [
                        {
                            "id": "11125",
                            "name": "Kognitionspsychologie",
                            "ects": 6,
                            "grade": 1.3,
                            "examDate": "14.08.2025",
                        }
                    ],
                },
                {"name": "digital_media_and_human_computer_interaction", "courses": []},
                {"name": "distributed_systems_and_networks", "courses": []},
            ],
        },
        {
            "name": "free_electives",
            "courses": [
                {
                    "id": "6010",
                    "name": "Einführung in die Künstliche Intelligenz",
                    "ects": 6,
                    "grade": 2.3,
                    "examDate": "30.07.2025",
                }
            ],
        },
    ]
}


def _extract_transcript_course_titles(transcript: dict) -> list[str]:
    titles: list[str] = []

    def walk(node):
        if isinstance(node, dict):
            courses = node.get("courses") or []
            for course in courses:
                name = str(course.get("name") or "").strip()
                if name:
                    titles.append(name)
            for child in node.get("children") or []:
                walk(child)
        elif isinstance(node, list):
            for item in node:
                walk(item)

    walk(transcript)
    return titles


def _fake_embed_texts(texts):
    mapping = {
        "ai": [1.0, 0.0],
        "ml": [1.0, 0.0],
        "iot": [0.0, 1.0],
        "python": [0.5, 0.5],
        "natural language processing": [1.0, 0.0],
        "algorithms for distributed systems": [0.2, 0.8],
        "kognitionspsychologie": [0.1, 0.2],
        "einfuhrung in die kunstliche intelligenz": [1.0, 0.0],
    }
    out = []
    for text in texts:
        key = str(text).strip().lower()
        out.append(mapping.get(key, [0.0, 0.0]))
    return out


class _FakeAnnIndex:
    def __init__(self, courses):
        self._courses = list(courses)

    def search(self, query_vector, top_k):
        return self._courses[:top_k]


class RecommendationTestCase(unittest.TestCase):
    def test_recommendations_with_transcript_and_interests(self):
        transcript_titles = _extract_transcript_course_titles(TRANSCRIPT_SAMPLE)
        user_keywords = ["AI", "ML", "IoT", "Python"]

        courses = [
            content_based.Course(
                course_number="CS-420",
                title="Machine Learning",
                embedding=[1.0, 0.0],
                degree_program="Computer Science (Informatik) (M. Sc.)",
                offered_semesters=["SoSe"],
                topics=["AI", "ML"],
            ),
            content_based.Course(
                course_number="CS-430",
                title="IoT Systems",
                embedding=[0.0, 1.0],
                degree_program="Computer Science (Informatik) (M. Sc.)",
                offered_semesters=["WiSe"],
                topics=["IoT"],
            ),
            content_based.Course(
                course_number="CS-999",
                title="Natural Language Processing",
                embedding=[1.0, 0.0],
                degree_program="Computer Science (Informatik) (M. Sc.)",
                offered_semesters=["SoSe"],
                topics=["AI", "NLP"],
            ),
        ]

        with mock.patch.object(content_based, "embed_texts", side_effect=_fake_embed_texts), \
             mock.patch.object(content_based, "embed_courses", side_effect=_fake_embed_texts), \
             mock.patch.object(content_based, "HnswAnnIndex", _FakeAnnIndex):
            results = content_based.recommend_courses(
                courses=courses,
                user_keywords=user_keywords,
                transcript_courses=transcript_titles,
                previously_enrolled_courses=[],
                degree_program="Computer Science (Informatik) (M. Sc.)",
                current_semester="",
                top_n=3,
            )

        titles = [rec.title for rec in results]
        self.assertIn("Machine Learning", titles)
        self.assertIn("IoT Systems", titles)
        self.assertNotIn("Natural Language Processing", titles)


if __name__ == "__main__":
    unittest.main()
