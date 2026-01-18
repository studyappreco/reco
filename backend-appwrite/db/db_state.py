import os
from pymongo import MongoClient
from dotenv import load_dotenv
import json

# Load environment variables from .env file
load_dotenv()

MOCK_TRANSCRIPTS = [
    {
    "user": "695f8904bcac7f16a725",
    "transcript": {
        "compulsary_electives": {
            "Information Systems": [
                {
                    "exam_number": 70348,
                    "exam_name": "Data Science Toolbox",
                    "term": "Winter 2022",
                    "exam_date": "15.02.2023",
                    "grade": 1.7,
                    "ects": 6.0
                },
                {
                    "exam_number": 70414,
                    "exam_name": "Digitale Märkte",
                    "term": "Summer 2023",
                    "exam_date": "20.07.2023",
                    "grade": 2.0,
                    "ects": 6.0
                },
                {
                    "exam_number": 41112,
                    "exam_name": "Data Integration and Large-scale Analysis",
                    "term": "Winter 2023",
                    "exam_date": "10.02.2024",
                    "grade": 1.3,
                    "ects": 9.0
                }
            ],
            "Computer Science": [
                {
                    "exam_number": 70893,
                    "exam_name": "Blockchain Technology",
                    "term": "Summer 24",
                    "exam_date": "15.02.2024",
                    "grade": 1.7,
                    "ects": 6.0
                }
            ]
        },
        "free_electives": [
            {
                "exam_number": 70373,
                "exam_name": "Auctions: Theory and applications",
                "term": "Summer 2022",
                "exam_date": "18.07.2022",
                "grade": 2.3,
                "ects": 6.0
            },
            {
                "exam_number": 70172,
                "exam_name": "Internetwirtschaft",
                "term": "Winter 2022",
                "exam_date": "05.02.2023",
                "grade": 1.9,
                "ects": 6.0
            }
        ]
    }
},
     {"user": "6967699402af64b787c3",
      "transcript": {
        "compulsary_electives": {
            "Information Systems": [
            {
                "exam_number": 70210,
                "exam_name": "Fundamentals of Project Management",
                "term": "Summer 2022",
                "exam_date": "25.07.2022",
                "grade": 2.0,
                "ects": 6.0
            },
            {
                "exam_number": 70459,
                "exam_name": "Experimental Business Research",
                "term": "Winter 2023",
                "exam_date": "12.02.2024",
                "grade": 1.5,
                "ects": 6.0
            }
            ],
            "Computer Science": []
        },
        "free_electives": [
            {
                "exam_number": 70167,
                "exam_name": "Intellectual Property Management",
                "term": "Summer 2023",
                "exam_date": "22.07.2023",
                "grade": 2.7,
                "ects": 6.0
            },
            {
                "exam_number": 70161,
                "exam_name": "Innovation Marketing",
                "term": "Winter 2022",
                "exam_date": "08.02.2023",
                "grade": 1.8,
                "ects": 6.0
            },
            {
                "exam_number": 70120,
                "exam_name": "Econometric Analysis of Longitudinal and Panel Data",
                "term": "Summer 2024",
                "exam_date": "19.07.2024",
                "grade": 2.3,
                "ects": 6.0
            }
        ]
    }
    }
]


CONNECTION_STRING = os.getenv("MONGODB_URI")

client = MongoClient(CONNECTION_STRING)

def load_mock_course_data(path):
    # Load the JSON file
    with open(path, 'r', encoding='utf-8') as file:
        return json.load(file)
        

def create_state():
    reco_DB = client["reco_db"]
    transcript_col = reco_DB["transcripts"]
    count = transcript_col.count_documents({})
    if count == 0:
        for doc in MOCK_TRANSCRIPTS:
            transcript_col.insert_one(doc)
        print("Mock transcripts inserted")
    else:
        print("mock transcript already inside")

    course_col = reco_DB["courses"]
    course_count = course_col.count_documents({})
    if course_count == 0:
        courses = load_mock_course_data("./data/course_contents_mock.json")
        course_col = reco_DB["courses"]
        for course in courses:
            course_col.insert_one({**course, "ects": 6})
        print("all courses inserted")
    else:
        print("mock courses already in the database")


if __name__ == "__main__":
    create_state()