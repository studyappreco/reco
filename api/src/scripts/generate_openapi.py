"""Helper script to generate a openapi.json file that can be used to generate clients for the backend."""

import json

from src.app import create_app

if __name__ == "__main__":
    with open("openapi.json", "w") as f:
        f.write(json.dumps(create_app().openapi(), indent=4))