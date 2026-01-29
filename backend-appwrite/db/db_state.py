import os
from pymongo import MongoClient
from dotenv import load_dotenv
import json

# Load environment variables from .env file
load_dotenv()

user_transcript_1 = user_transcript_1 = {
    "userID": "6967699402af64b787c3",
    "programLiteral": "CS_B",
    "transcript": {
        "children": [
            {
                "name": "compulsory_modules",
                "courses": [],
                "children": [
                    {
                        "name": "foundations_of_scientific_work",
                        "courses": [
                            {
                                "id": "6435",
                                "name": "Informatik Propädeutikum",
                                "ects": 3,
                                "grade": 2.7,
                                "examDate": "31.01.2024"
                            }
                        ],
                        "children": []
                    },
                    {
                        "name": "technical_foundations",
                        "courses": [
                            {
                                "id": "3305",
                                "name": "Systemprogrammierung",
                                "ects": 6,
                                "grade": 2,
                                "examDate": "31.07.2024"
                            },
                            {
                                "id": "14610",
                                "name": "Rechnerorganisation",
                                "ects": 6,
                                "grade": 3,
                                "examDate": "01.03.2024"
                            }
                        ],
                        "children": []
                    },
                    {
                        "name": "methodical_practical_foundations",
                        "courses": [
                            {
                                "id": "6135",
                                "name": "Einführung in die Programmierung",
                                "ects": 6,
                                "grade": 2.3,
                                "examDate": "04.03.2024"
                            },
                            {
                                "id": "6145",
                                "name": "Algorithmen und Datenstrukturen",
                                "ects": 6,
                                "grade": 1.7,
                                "examDate": "26.07.2024"
                            },
                            {
                                "id": "6445",
                                "name": "Informationssysteme und Datenanalyse",
                                "ects": 6,
                                "grade": 1.7,
                                "examDate": "02.08.2024"
                            },
                            {
                                "id": "6455",
                                "name": "Wissenschaftliches Rechnen",
                                "ects": 6,
                                "grade": 3,
                                "examDate": "28.02.2025"
                            }
                        ],
                        "children": []
                    },
                    {
                        "name": "theoretical_foundations",
                        "courses": [
                            {
                                "id": "3335",
                                "name": "Berechenbarkeit und Komplexität",
                                "ects": 6,
                                "grade": 1,
                                "examDate": "18.02.2025"
                            },
                            {
                                "id": "6465",
                                "name": "Formale Sprachen und Automaten",
                                "ects": 6,
                                "grade": 2.7,
                                "examDate": "22.07.2024"
                            },
                            {
                                "id": "6475",
                                "name": "Logik",
                                "ects": 6,
                                "grade": 3,
                                "examDate": "28.03.2025"
                            }
                        ],
                        "children": []
                    },
                    {
                        "name": "foundations_of_mathematics",
                        "courses": [
                            {
                                "id": "6485",
                                "name": "Diskrete Strukturen",
                                "ects": 6,
                                "grade": 2.7,
                                "examDate": "29.07.2024"
                            },
                            {
                                "id": "6565",
                                "name": "Stochastik für Informatik",
                                "ects": 9,
                                "grade": 2.3,
                                "examDate": "28.07.2025"
                            },
                            {
                                "id": "71117",
                                "name": "Analysis I und Lineare Algebra für Ingenieurwissenschaften",
                                "ects": 12,
                                "grade": 3,
                                "examDate": "21.02.2024"
                            }
                        ],
                        "children": []
                    },
                    {
                        "name": "societal_relevance",
                        "courses": [],
                        "children": []
                    }
                ]
            },
            {
                "name": "compulsory_electives",
                "courses": [],
                "children": [
                    {
                        "name": "technical_computer_science",
                        "courses": [
                            {
                                "id": "60165",
                                "name": "Verteilte Systeme",
                                "ects": 6,
                                "grade": 2,
                                "examDate": "06.08.2025"
                            }
                        ],
                        "children": []
                    },
                    {
                        "name": "programming_practical",
                        "courses": [],
                        "children": []
                    },
                    {
                        "name": "theoretical_computer_science",
                        "courses": [
                            {
                                "id": "2348908",
                                "name": "Algorithmentheorie (ehemals Grundlagen der Algorithmik)",
                                "ects": 6,
                                "grade": 3,
                                "examDate": "29.07.2025"
                            }
                        ],
                        "children": []
                    },
                    {
                        "name": "computer_science_catalog",
                        "courses": [],
                        "children": []
                    }
                ]
            }
        ]
    }
}


user_transcript_2 = {
    "userID": "696fc7786cc80f940621",
    "programLiteral": "CS_M",
    "transcript": {
        "children": [
            {
                "name": "compulsory_electives",
                "courses": None,
                "children": [
                    {
                        "name": "data_and_software_engineering",
                        "courses": [
                            {
                                "id": "2350790",
                                "name": "Natural Language Processing",
                                "ects": 6,
                                "grade": 2,
                                "examDate": "05.08.2025"
                            }
                        ],
                        "children": None
                    },
                    {
                        "name": "embedded_systems_and_computer_architectures",
                        "courses": [
                            {
                                "id": "2351588",
                                "name": "Algorithms for Distributed Systems",
                                "ects": 6,
                                "grade": 2.3,
                                "examDate": "01.10.2025"
                            }
                        ],
                        "children": None
                    },
                    {
                        "name": "foundations_of_computing",
                        "courses": [],
                        "children": None
                    },
                    {
                        "name": "cognitive_systems",
                        "courses": [
                            {
                                "id": "11125",
                                "name": "Kognitionspsychologie",
                                "ects": 6,
                                "grade": 1.3,
                                "examDate": "14.08.2025"
                            }
                        ],
                        "children": None
                    },
                    {
                        "name": "digital_media_and_human_computer_interaction",
                        "courses": [],
                        "children": None
                    },
                    {
                        "name": "distributed_systems_and_networks",
                        "courses": [],
                        "children": None
                    }
                ]
            },
            {
                "name": "free_electives",
                "courses": [
                    {
                        "id": "6010",
                        "name": "Einführung in die Künstliche Intelligenz",
                        "ects": 6,
                        "grade": 2.3,
                        "examDate": "30.07.2025"
                    }
                ],
                "children": None
            }
        ]
    }
}

user_transcript_3 = {
    "userID": "695f8904bcac7f16a725",
    "programLiteral": "ISM",
    "transcript": {
        "children": [
            {
                "name": "compulsory_electives",
                "courses": [],
                "children": [
                    {
                        "name": "information_systems",
                        "courses": [
                            {
                                "id": "2345252",
                                "name": "Machine Intelligence I / Neural Information Processing I",
                                "ects": 6,
                                "grade": 3.7,
                                "examDate": "20.02.2025"
                            },
                            {
                                "id": "2346012",
                                "name": "DBT: Database Technology",
                                "ects": 6,
                                "grade": 2.3,
                                "examDate": "17.02.2025"
                            },
                            {
                                "id": "2348177",
                                "name": "Data Science Toolbox",
                                "ects": 6,
                                "grade": 2,
                                "examDate": "01.10.2025"
                            },
                            {
                                "id": "2350347",
                                "name": "Cloud Native Architecture and Engineering",
                                "ects": 6,
                                "grade": 1.3,
                                "examDate": "17.07.2025"
                            },
                            {
                                "id": "2350701",
                                "name": "Social and Economic Network Analysis",
                                "ects": 6,
                                "grade": 1.7,
                                "examDate": "08.10.2025"
                            },
                            {
                                "id": "2351861",
                                "name": "Advanced Cloud Prototyping",
                                "ects": 12,
                                "grade": 1.3,
                                "examDate": "15.03.2025"
                            }
                        ],
                        "children": None
                    },
                    {
                        "name": "computer_science",
                        "courses": [],
                        "children": [
                            {
                                "name": "Distributed Systems and Networks",
                                "courses": [
                                    {
                                        "id": "2351859",
                                        "name": "Blockchain Technology and Decentralized Applications",
                                        "ects": 6,
                                        "grade": 2,
                                        "examDate": "29.08.2025"
                                    }
                                ],
                                "children": None
                            },
                            {
                                "name": "Data and Software Engineering",
                                "courses": [],
                                "children": None
                            }
                        ]
                    },
                    {
                        "name": "business_and_economics",
                        "courses": [],
                        "children": None
                    }
                ]
            },
            {
                "name": "free_electives",
                "courses": [
                    {
                        "id": "",
                        "name": "Computational modeling - A practical course",
                        "ects": 3,
                        "grade": 0,
                        "examDate": "11.04.2025"
                    }
                ],
                "children": None
            }
        ]
    }
}

# Transcripts to insert
MOCK_TRANSCRIPTS = [user_transcript_1, user_transcript_2,  user_transcript_3]


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