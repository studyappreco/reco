from synth_data import get_modules_name_tuples
import json
import time
import requests
from bs4 import BeautifulSoup
from typing import Optional, Dict
from pandas import pd

url = "https://moseskonto.tu-berlin.de/moses/modultransfersystem/bolognamodule/beschreibung/anzeigen.html?number={}&version=1"

def __load_course_data( path : str) -> None:
    data = pd.read_csv(path)
    return data[["Fach", "LP", "#M"]]

business_courses = __load_course_data("./src/data/wiwi_courses.csv")
winf_courses = __load_course_data("./src/data/winf_courses.csv")
inf_courses = __load_course_data("./src/data/inf_courses.csv")


HEADERS = {"User-Agent": "Mozilla/5.0 (compatible; simple-scraper/1.0)"}

def fetch_html(number: int, timeout: int = 10) -> Optional[str]:
    """
    Fetch the HTML for the given module number. Returns the page HTML or None on error.
    """
    try:
        resp = requests.get(url.format(number), headers=HEADERS, timeout=timeout)
        resp.raise_for_status()
        return resp.text
    except requests.RequestException:
        return None


def scrape_module(number: int, name : str) -> Optional[Dict[str, Optional[str]]]:
    """
    Fetch and parse a module page. Returns a small dict with extracted fields:
    - number
    - title (page <title> or first <h1>)
    - first_paragraph (first <p> found)
    Returns None if the page could not be fetched.
    """
    html = fetch_html(number)
    if html is None:
        return None
    soup = BeautifulSoup(html, "html.parser")

    # 1. Find the <h3> by string
    lernergebnisse_text = None
    try: 
        h3_tag = soup.find("h3", string="Lernergebnisse")
        parent_div = h3_tag.parent
        next_div = parent_div.find_next_sibling("div")
        lernergebnisse_text = next_div.find("span").get_text(strip=True)
    except Exception as e:
        pass
    lehrinhalte_text = None
    try: 
        h3_tag = soup.find("h3", string="Lehrinhalte")
        parent_div = h3_tag.parent
        next_div = parent_div.find_next_sibling("div")
        lehrinhalte_text = next_div.find("span").get_text(strip=True)
    except Exception as e:
        pass
    
    return {
        "number": number,
        "title": name,
        "learn_content": lehrinhalte_text,
        "learn_result" : lernergebnisse_text
    }



if __name__ == "__main__":
    all_modules = []
    course_tuples = get_modules_name_tuples()
    for tup in course_tuples:
        result = scrape_module(tup[0], tup[1])
        if result:
            all_modules.append(result)
        else:
            print(f"Failed to fetch module {tup[0]}")
        time.sleep(1)
    
    with open("./src/data/course_contents.json", "w") as f:
            json.dump(all_modules, f, indent=4)




