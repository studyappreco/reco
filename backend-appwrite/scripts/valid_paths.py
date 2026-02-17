"""Extract valid paths from course assigned_degrees based on program type."""

from pydantic import BaseModel, Field
from pydantic_ai import Agent
from typing import List


# --- Program Path Prompts ---

_CS_MASTER_PROMPT = """\
Overall structure of the Computer Science (CS) Masters Degree with English | German names is hierarchical:
    - two main categories: "Compulsory Electives" | "Wahlpflicht" and "Free Electives" | "Wahlbereich"
    - "Compulsory Electives" can be further subdivided into:
        - "Data and Software Engineering" | "Data and Software Engineering"
        - "Embedded Systems and Computer Architectures" | "Eingebettete Systeme und Rechnerarchitekturen"
        - "Foundations of Computing" | "Grundlagen der Informatik"
        - "Cognitive Systems" | "Kognitive Systeme"
        - "Digital Media and Human-Computer Interaction" | "Medientechnik und Mensch-Maschine-Interaktion"
        - "Distributed Systems and Networks" | "Verteilte Systeme und Netze"

For the output on how to call the categories:
  - "Data and Software Engineering" => "data_and_software_engineering"
  - "Embedded Systems and Computer Architectures" => "embedded_systems_and_computer_architectures"
  - "Foundations of Computing" => "foundations_of_computing"
  - "Cognitive Systems" => "cognitive_systems"
  - "Digital Media and Human-Computer Interaction" => "digital_media_and_human_computer_interaction"
  - "Distributed Systems and Networks" => "distributed_systems_and_networks"
  - "Compulsory Electives" => "compulsory_electives"
  - "Free Electives" => "free_electives"

Example how to solve this task:

Input:
    [
            [
                "Wahlpflicht Studiengebiete Fak. IV↳ Verteilte Systeme und Netze / Distributed Systems and Networks",
                "Wahlpflicht Studiengebiete Fak. IV"
              ],
              [
                "Wahlpflicht Studiengebiete Fak. IV↳ Grundlagen der Informatik / Foundations of Computing",
                "Wahlpflicht Studiengebiete Fak. IV"
              ],
              [
                "Studiengebiete↳ Verteilte Systeme und Netze / Distributed Systems and Networks",
                "Studiengebiete"
              ],
              [
                "Studiengebiete↳ Grundlagen der Informatik / Foundations of Computing",
                "Studiengebiete"
              ]
            ]

Output:
[["compulsory_electives", "distributed_systems_and_networks"], ["compulsory_electives", "foundations_of_computing"]]

Further explanation:
The importance here is that the names for the categories are from the mapping with the underscore.
As you can see in the example the last two entries could be discarded due to the fact that they have been already included in the path.
Entire paths is what is important here.
You can see entries like arrows to see where category stop and start.
"""

_ISM_PROMPT = """\
Overall structure of the Information Systems Management (ISM) Masters Degree with English | German names is hierarchical:
    - two main categories: "Compulsory Electives" | "Wahlpflicht" and "Free Electives" | "Wahlbereich"
    - "Compulsory Electives" can be further subdivided into "Information Systems" | "Informationssysteme", "Computer Science" | "Informatik" and "Business and Economics"
    - "Computer Science" can be further subdivided into "Distributed Systems and Networks" and "Data and Software Engineering"

For the output on how to call the TranscriptNodes per category:
  - "Information Systems" => "information_systems"
  - "Computer Science" => "computer_science"
  - "Business and Economics" => "business_and_economics"
  - "Compulsory Electives" => "compulsory_electives"
  - "Free Electives" => "free_electives"
  - "Distributed Systems and Networks" => "distributed_systems_and_networks"
  - "Data and Software Engineering" => "data_and_software_engineering"

Example how to solve this task:
Input:
        [
              [
                "Wahlpflichtbereich↳ Fachstudium Informatik↳ Verteilte Systeme und Netze / Distributed Systems and Networks",
                "Wahlpflichtbereich",
                "↳ Fachstudium Informatik"
              ]
            ]

Output:
    [["compulsory_electives", "computer_science", "distributed_systems_and_networks"]]

Further explanation:
The importance here is that the names for the categories are from the mapping with the underscore.
The important information is the path where this particular course can belong in the overall program structure.
The second entry could be discarded since the information is already contained in path.
You can see entries like arrows to see where category stop and start.
"""

_CS_BACHELOR_PROMPT = """\
Overall structure of the Computer Science (CS) Bachelors Degree with English | German names is hierarchical:
  - three main categories: "Compulsory Modules" | "Pflichtbereich", "Compulsory Electives" | "Wahlpflichtbereich" and "Free Electives" | "Wahlbereich"
  - "Compulsory Modules"
      - can have courses directly and are not further subdivided
  - "Compulsory Electives" can be further subdivided into:
      - "Technical Computer Science" | "Technische Informatik"
      - "Programming Practical" | "Programmierpraktikum"
      - "Theoretical Computer Science" | "Theoretische Informatik"
      - "Computer Science Catalog" | "Katalog Informatik"
  - "Free Electives"
      - can have courses directly and are not further subdivided

For the output on how to call the TranscriptNodes per category:
  - "Compulsory Modules" => "compulsory_modules"
  - "Compulsory Electives" => "compulsory_electives"
  - "Free Electives" => "free_electives"
  - "Technical Computer Science" => "technical_computer_science"
  - "Programming Practical" => "programming_practical"
  - "Theoretical Computer Science" => "theoretical_computer_science"
  - "Computer Science Catalog" => "computer_science_catalog"

Example how to solve this task:
Input:
    [
              [
                "Wahlpflichtbereich↳ Wahlpflichtbereich Katalog Informatik",
                "Wahlpflichtbereich"
              ]
    ]

Output:
[["compulsory_electives", "computer_science_catalog"]]

Further explanation:
The importance here is that the names for the categories are from the mapping with the underscore.
The important information is the path where this particular course can belong in the overall program structure.
The second entry could be discarded since the information is already contained in path.
You can see entries like arrows to see where category stop and start.
"""

# --- Program Prompts Mapping ---

PROGRAM_PROMPTS: dict[str, str] = {
    "CS_M": _CS_MASTER_PROMPT,
    "CS_B": _CS_BACHELOR_PROMPT,
    "ISM": _ISM_PROMPT,
}


# --- Pydantic Models ---

class ValidPaths(BaseModel):
    """Structured output for valid paths."""
    paths: list[list[str]] = Field(
        description="List of valid paths, each path is a list of category identifiers"
    )


# --- Program Detection ---
DETECTION_RULES: list[tuple[tuple[str, ...], str, str | None]] = [
    (("computer science", "m. sc."), "CS_M", None),
    (("informatik", "m. sc."), "CS_M", "wirtschaft"),
    (("informatik", "b. sc."), "CS_B", "wirtschaft"),
    (("information systems management",), "ISM", None),
    (("wirtschaftsinformatik",), "ISM", None),
]


def detect_program_type(program_name: str) -> str:
    """Detect the program type from the program name."""
    program_lower = program_name.lower()

    for required, program_type, excluded in DETECTION_RULES:
        if all(pat in program_lower for pat in required):
            if excluded is None or excluded not in program_lower:
                return program_type

    return "unknown"


def get_prompt_for_program(program_type: str) -> str | None:
    """Get the appropriate prompt for a program type."""
    return PROGRAM_PROMPTS.get(program_type)


# --- Extraction Functions ---

async def extract_valid_paths_for_program(
    agent: Agent,
    categories: list[list[str]],
    program_type: str,
) -> ValidPaths | None:
    """
    Extract valid paths for a specific program type.

    Args:
        agent: The pydantic_ai Agent to use
        categories: The categories list from assigned_degrees
        program_type: One of the supported program types (CS_M, CS_B, ISM)

    Returns:
        ValidPaths or None if program type is unsupported
    """
    prompt_context = get_prompt_for_program(program_type)
    if prompt_context is None:
        return None

    if not categories:
        return ValidPaths(paths=[])

    user_prompt = f"""\
{prompt_context}

Now process this input and return the valid paths:

Input:
{categories}

Return the paths as a structured list of lists.
"""
    result = await agent.run(user_prompt)
    return result.output


async def extract_valid_paths(
    agent: Agent,
    course: dict,
) -> dict[str, ValidPaths]:
    """
    Extract valid paths for each supported program in the course's assigned_degrees.

    Returns a dict mapping program_type -> ValidPaths
    """
    assigned_degrees = course.get("assigned_degrees", [])
    if not assigned_degrees:
        return {}

    results: dict[str, ValidPaths] = {}

    for degree in assigned_degrees:
        program_name = degree.get("program", "")
        program_type = detect_program_type(program_name)
        if program_type not in PROGRAM_PROMPTS or program_type in results:
            continue

        all_categories = [
            cat
            for stupo in degree.get("stupos", [])
            for cat in stupo.get("categories", [])
        ]

        result = await extract_valid_paths_for_program(agent, all_categories, program_type)
        if result is not None:
            results[program_type] = result

    return results

async def extract_all_valid_paths(courses: List[dict], agent: Agent) -> None:
    for course in courses:
        res = await extract_valid_paths(agent=agent, course=course)
        course["paths"] = {k: v.model_dump() for k, v in res.items()}

