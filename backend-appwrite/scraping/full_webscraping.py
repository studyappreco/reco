"""
Moses Course Module Web Scraper
"""

import json
import logging
import re
import time
from dataclasses import dataclass, asdict
from typing import Optional

import pandas as pd
import requests
from bs4 import BeautifulSoup

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)

URL_TEMPLATE = "https://moseskonto.tu-berlin.de/moses/modultransfersystem/bolognamodule/beschreibung/anzeigen.html?nummer={number}&version={version}"

HEADERS = {"User-Agent": "Mozilla/5.0 (compatible; TUBerlin-Course-Scraper/1.0)"}


@dataclass
class CourseData:
    """Data structure for scraped course information."""
    number: int
    version: int
    url: str # direct link
    title: Optional[str]
    credits: Optional[str]
    exam_type: Optional[str]
    language: Optional[str]
    responsible: Optional[str]
    term: Optional[str]  # SoSe, WiSe, or SoSe/WiSe
    learn_outcomes: Optional[str]
    learn_content: Optional[str]
    assigned_degrees: list[dict]


class MosesScraper:
    """Scraper for TU Berlin Moses course module pages."""

    def __init__(self, delay: float = 0.2, max_version: int = 20):
        """
        Initialize the scraper.

        Args:
            delay: Seconds to wait between requests (rate limiting)
            max_version: Maximum version number to check when finding latest
        """
        self.delay = delay
        self.max_version = max_version
        self.session = requests.Session()
        self.session.headers.update(HEADERS)
        self.failed_modules: list[int] = []

    def _wait(self) -> None:
        """Wait between requests to respect rate limits."""
        time.sleep(self.delay)

    def fetch_html(self, number: int, version: int, timeout: int = 10) -> Optional[str]:
        """
        Fetch the HTML for a specific module number and version.

        Args:
            number: Module number
            version: Version number
            timeout: Request timeout in seconds

        Returns:
            HTML content or None on error
        """
        url = URL_TEMPLATE.format(number=number, version=version)
        try:
            resp = self.session.get(url, timeout=timeout)
            resp.raise_for_status()
            return resp.text
        except requests.RequestException as e:
            logger.warning(f"Failed to fetch module {number} v{version}: {e}")
            return None

    def is_not_found(self, html: str) -> bool:
        """
        Check if the HTML indicates the module/version was not found.

        The Moses website returns valid HTML even for non-existent versions,
        but the content sections will be missing or show error messages.

        Args:
            html: HTML content to check

        Returns:
            True if module not found, False if valid content exists
        """
        soup = BeautifulSoup(html, "html.parser")

        # Check if the page has the main content sections
        h3_lernergebnisse = soup.find("h3", string="Lernergebnisse")
        h3_lehrinhalte = soup.find("h3", string="Lehrinhalte")

        # If both main content sections are missing, consider it not found
        if h3_lernergebnisse is None and h3_lehrinhalte is None:
            return True

        # Check for error page indicators
        title = soup.find("title")
        if title and "Fehler" in title.get_text():
            return True

        return False

    def _find_current_version_from_alert(self, html: str) -> Optional[int]:
        """
        Check if HTML contains an alert warning about outdated module version.

        When viewing an outdated module version, Moses shows an alert with text like
        "This module description does not apply to the current semester" and a link
        to the current version. This method extracts the version number from that link.

        Note: Does NOT match language-related alerts (about missing translations).

        Args:
            html: HTML content to check

        Returns:
            The current version number if found, None otherwise
        """
        soup = BeautifulSoup(html, "html.parser")
        alert = soup.find("div", class_="alert-warning")
        if not alert:
            return None

        # Check if this is an outdated version alert (not a language alert)
        alert_text = alert.get_text()
        if "does not apply to the current semester" not in alert_text and \
           "gilt nicht für das aktuelle Semester" not in alert_text:
            return None

        # Find link with version parameter
        link = alert.find("a", href=lambda h: h and "version=" in str(h))
        if not link:
            return None

        href = link.get("href", "")
        # Extract version from: ...?nummer=40037&version=10
        match = re.search(r'version=(\d+)', href)
        if match:
            return int(match.group(1))
        return None

    def find_latest_version(self, module_number: int) -> Optional[int]:
        """
        Find the latest valid version of a module.

        First fetches version 1 and checks for an alert warning that links to
        the current version. If found, uses that version directly. Otherwise,
        falls back to iterating through versions.

        Args:
            module_number: The module number to check

        Returns:
            The latest valid version number, or None if no valid version exists
        """
        # First, try fetching version 1 to check for redirect alert
        html = self.fetch_html(module_number, 1)
        if html is None:
            logger.warning(f"Module {module_number}: failed to fetch version 1")
            return None

        # Check if there's an alert pointing to current version
        current_version = self._find_current_version_from_alert(html)
        if current_version:
            logger.info(f"Module {module_number}: found current version {current_version} from alert")
            return current_version

        # If version 1 is not found, module doesn't exist
        if self.is_not_found(html):
            logger.warning(f"Module {module_number}: no valid version found")
            return None

        # Version 1 is valid and no alert - iterate to find latest (fallback)
        latest_valid = 1
        for version in range(2, self.max_version + 1):
            self._wait()
            html = self.fetch_html(module_number, version)

            if html is None or self.is_not_found(html):
                break

            # Check for alert in each version
            current = self._find_current_version_from_alert(html)
            if current:
                logger.info(f"Module {module_number}: found current version {current} from alert")
                return current

            latest_valid = version
            logger.debug(f"Module {module_number}: version {version} is valid")

        logger.info(f"Module {module_number}: latest version is {latest_valid}")
        return latest_valid

    def _extract_text_after_label(self, soup: BeautifulSoup, label_text: str) -> Optional[str]:
        """
        Extract text from the span following a label element.

        Args:
            soup: BeautifulSoup object
            label_text: The label text to search for

        Returns:
            Extracted text or None
        """
        label = soup.find("label", string=label_text)
        if not label:
            return None

        parent = label.parent
        if not parent:
            return None

        # Find the span with large font size (contains the value)
        span = parent.find("span", style=lambda s: s and "font-size" in s)
        if span:
            return span.get_text(strip=True)

        # Fallback: get text after <br>
        br = parent.find("br")
        if br and br.next_sibling:
            text = br.next_sibling
            if hasattr(text, "get_text"):
                return text.get_text(strip=True)
            return str(text).strip()

        return None

    def _extract_section_content(self, soup: BeautifulSoup, h3_text: str) -> Optional[str]:
        """
        Extract content from a section identified by its h3 header.

        Args:
            soup: BeautifulSoup object
            h3_text: The h3 header text to search for

        Returns:
            Section content text or None
        """
        h3_tag = soup.find("h3", string=h3_text)
        if not h3_tag:
            return None

        parent_div = h3_tag.parent
        if not parent_div:
            return None

        next_div = parent_div.find_next_sibling("div")
        if not next_div:
            return None

        span = next_div.find("span", class_="preformatedTextarea")
        if span:
            return span.get_text(strip=True)

        # Fallback to any span
        span = next_div.find("span")
        if span:
            return span.get_text(strip=True)

        return None

    def _extract_term(self, soup: BeautifulSoup) -> Optional[str]:
        """
        Extract the term (Turnus) when the course is offered.

        Looks in the Modulbestandteile table for the Turnus column.

        Args:
            soup: BeautifulSoup object

        Returns:
            Term string (e.g., "SoSe", "WiSe", or "SoSe/WiSe") or None
        """
        # Find the Modulbestandteile section
        bestandteile = soup.find("span", id=lambda x: x and "BoxBestandteile" in str(x))
        if not bestandteile:
            return None

        # Find table header for "Turnus"
        th = bestandteile.find("th", string=lambda s: s and "Turnus" in str(s))
        if not th:
            return None

        # Get column index
        header_row = th.find_parent("tr")
        if not header_row:
            return None
        headers = header_row.find_all("th")
        try:
            turnus_idx = list(headers).index(th)
        except ValueError:
            return None

        # Get values from data rows
        tbody = bestandteile.find("tbody")
        if not tbody:
            return None

        terms = set()
        for row in tbody.find_all("tr"):
            cells = row.find_all("td")
            if len(cells) > turnus_idx:
                term_cell = cells[turnus_idx]
                span = term_cell.find("span")
                if span:
                    term_text = span.get_text(strip=True)
                    if term_text:
                        terms.add(term_text)

        if not terms:
            return None
        return "/".join(sorted(terms))


    def parse_expanded_degrees(self, html: str) -> list[dict]:
        """
        Parse the expanded degree table with detailed category information.

        The expanded table has a hierarchical structure:
        - Program header rows (with link to studiengang)
        - StuPO detail rows (with ↳ prefix) containing category information

        Args:
            html: HTML content of the expanded BoxVerwendbarkeit section

        Returns:
            List of degree dictionaries with program, stupos, and categories
        """
        soup = BeautifulSoup(html, "html.parser")
        tbody = soup.find("tbody")
        if not tbody:
            return []

        rows = tbody.find_all("tr")
        degrees = []
        current_program = None

        for row in rows:
            cells = row.find_all("td")
            if len(cells) < 2:
                continue

            program_cell = cells[1]

            # Check if this is a program header row (has link to studiengang)
            link = program_cell.find("a", href=lambda h: h and "studiengang=" in str(h))

            if link:
                # This is a program header row - create new program entry
                # Extract program_id from URL query string
                href = link.get("href", "")
                program_id = None
                match = re.search(r'studiengang=(\d+)', href)
                if match:
                    program_id = int(match.group(1))

                current_program = {
                    "program": link.get_text(strip=True),
                    "program_id": program_id,
                    "stupos": []
                }
                degrees.append(current_program)

            elif "↳" in program_cell.get_text():
                # This could be a StuPO detail row or a category row
                stupo_text = program_cell.get_text(strip=True)
                stupo_name = stupo_text.lstrip("↳").strip()

                # Extract first and last semester
                first_semester = cells[2].get_text(strip=True) if len(cells) > 2 else None
                last_semester = cells[3].get_text(strip=True) if len(cells) > 3 else None

                # Only treat as StuPO row if it has "StuPO" in the name
                # Other rows with ↳ are category detail rows, skip them
                if "StuPO" not in stupo_name:
                    continue

                # Extract categories from nested tables in semester columns (index 4+)
                categories = []
                for cell in cells[4:]:
                    for table in cell.find_all("table"):
                        path = []
                        # Get all text from <small> tags (hierarchy levels)
                        for small in table.find_all("small"):
                            text = small.get_text(strip=True)
                            if text:
                                path.append(text)

                        # Get the final category text (may not be in <small>)
                        td_elements = table.find_all("td")
                        if td_elements:
                            last_td = td_elements[-1]
                            # Get direct text children that aren't in <small>
                            for child in last_td.children:
                                if isinstance(child, str):
                                    text = child.strip()
                                    if text and text not in path:
                                        path.append(text)

                        if path:
                            categories.append(path)

                if current_program is not None:
                    current_program["stupos"].append({
                        "name": stupo_name,
                        "first_semester": first_semester,
                        "last_semester": last_semester,
                        "categories": categories
                    })

        return degrees

    def _parse_basic_degrees(self, soup: BeautifulSoup) -> list[dict]:
        """
        Parse basic degree information from the collapsed table view.

        Extracts program name, URL, counts, and semester range.
        Note: Detailed category information requires JavaScript execution
        which is not available in this basic scraper.

        Args:
            soup: BeautifulSoup object

        Returns:
            List of dictionaries with degree program information
        """
        box = soup.find("span", id=lambda x: x and "BoxVerwendbarkeit" in str(x))
        if not box:
            return []

        table = box.find("table")
        if not table:
            return []

        tbody = table.find("tbody")
        if not tbody:
            return []

        rows = tbody.find_all("tr")
        degrees = []

        for row in rows:
            cells = row.find_all("td")

            # Skip empty message rows
            if len(cells) == 1 and "keinem Studiengang" in cells[0].get_text():
                continue

            # Collapsed table structure:
            # Cell 0: expand button
            # Cell 1: program name (with link)
            # Cell 2: number of StuPOs
            # Cell 3: number of usages (categories)
            # Cell 4: first semester
            # Cell 5: last semester
            if len(cells) >= 6:
                link = cells[1].find("a", href=lambda h: h and "studiengang=" in str(h))
                if link:
                    # Extract program_id from URL query string
                    href = link.get("href", "")
                    program_id = None
                    match = re.search(r'studiengang=(\d+)', href)
                    if match:
                        program_id = int(match.group(1))

                    degrees.append({
                        "program": link.get_text(strip=True),
                        "program_id": program_id,
                        "stupo_count": cells[2].get_text(strip=True),
                        "usage_count": cells[3].get_text(strip=True),
                        "first_semester": cells[4].get_text(strip=True),
                        "last_semester": cells[5].get_text(strip=True),
                    })

        return degrees

    def parse_assigned_degrees(self, soup: BeautifulSoup) -> list[dict]:
        """
        Extract assigned degrees from the page.

        Note: The Moses website uses PrimeFaces/JSF which maintains server-side
        component state. AJAX requests to expand the degree table require full
        browser JavaScript execution to work properly. This implementation uses
        basic parsing which extracts summary data (program name, counts, semester range)
        but cannot get detailed category information.

        For full category expansion, use fetch_expanded_with_selenium() instead.

        Args:
            soup: BeautifulSoup object of initial page

        Returns:
            List of dictionaries with degree program information
        """
        return self._parse_basic_degrees(soup)

    def fetch_expanded_with_selenium(self, number: int, version: int) -> list[dict]:
        """
        Use Selenium to fetch expanded degree table with full category information.

        This method uses a headless browser to properly execute JavaScript and
        trigger the AJAX expansion that PrimeFaces requires.

        Requires: selenium package (install with: uv add selenium)

        Args:
            number: Module number
            version: Module version

        Returns:
            List of dictionaries with full degree and category information
        """
        try:
            from selenium import webdriver
            from selenium.webdriver.common.by import By
            from selenium.webdriver.support.ui import WebDriverWait
            from selenium.webdriver.support import expected_conditions as EC
            from selenium.common.exceptions import TimeoutException
        except ImportError:
            logger.warning("Selenium not installed. Run: uv add selenium")
            return []

        url = URL_TEMPLATE.format(number=number, version=version)

        options = webdriver.ChromeOptions()
        options.add_argument("--headless")
        options.add_argument("--no-sandbox")
        options.add_argument("--disable-dev-shm-usage")

        driver = webdriver.Chrome(options=options)
        try:
            driver.get(url)

            # Wait for page load, then find the "expand all" button in table HEADER
            # This is the <a> element in thead that contains the fa-plus-square-o icon
            expand_link = WebDriverWait(driver, 10).until(
                EC.presence_of_element_located((By.XPATH,
                    "//table//thead//th//a[.//span[contains(@class, 'fa-plus-square-o')]]"))
            )

            # Scroll element into view and use JavaScript click to avoid interception
            driver.execute_script("arguments[0].scrollIntoView(true);", expand_link)
            time.sleep(0.5)  # Brief pause for any animations
            driver.execute_script("arguments[0].click();", expand_link)

            # Wait for AJAX response - look for the collapse icon or expanded rows
            try:
                WebDriverWait(driver, 10).until(
                    EC.presence_of_element_located((By.CSS_SELECTOR, "span.fa-minus-square-o"))
                )
            except TimeoutException:
                logger.debug(f"Module {number}: expansion timeout, using current state")

            # Parse the expanded page
            soup = BeautifulSoup(driver.page_source, "html.parser")
            box = soup.find("span", id=lambda x: x and "BoxVerwendbarkeit" in str(x))
            if box:
                return self.parse_expanded_degrees(str(box))

            return []
        except Exception as e:
            logger.warning(f"Selenium scraping failed for module {number}: {e}")
            return []
        finally:
            driver.quit()

    def parse_module(self, html: str, number: int, version: int) -> CourseData:
        """
        Parse all relevant information from a module page.

        Args:
            html: HTML content
            number: Module number
            version: Version number

        Returns:
            CourseData object with extracted information
        """
        soup = BeautifulSoup(html, "html.parser")

        # Construct the URL for this module
        url = URL_TEMPLATE.format(number=number, version=version)

        # Extract title from h1 or page title
        title = None
        h1 = soup.find("h1")
        if h1:
            title = h1.get_text(strip=True)
        else:
            title_tag = soup.find("title")
            if title_tag:
                title_text = title_tag.get_text(strip=True)
                # Remove "Moses - " prefix
                if title_text.startswith("Moses - "):
                    title = title_text[8:]
                else:
                    title = title_text

        # Extract standard fields
        credits = self._extract_text_after_label(soup, "Leistungspunkte")
        exam_type = self._extract_text_after_label(soup, "Prüfungsform")
        language = self._extract_text_after_label(soup, "Lehrsprache(n)")
        responsible = self._extract_text_after_label(soup, "Modulverantwortliche*r")

        # Extract term (Turnus)
        term = self._extract_term(soup)

        # Extract content sections
        learn_outcomes = self._extract_section_content(soup, "Lernergebnisse")
        learn_content = self._extract_section_content(soup, "Lehrinhalte")

        # Extract assigned degrees using Selenium for full category expansion
        assigned_degrees = self.fetch_expanded_with_selenium(number, version)

        return CourseData(
            number=number,
            version=version,
            url=url,
            title=title,
            credits=credits,
            exam_type=exam_type,
            language=language,
            responsible=responsible,
            term=term,
            learn_outcomes=learn_outcomes,
            learn_content=learn_content,
            assigned_degrees=assigned_degrees,
        )

    def scrape_module(self, module_number: int) -> Optional[CourseData]:
        """
        Scrape a single module, finding its latest version automatically.

        Args:
            module_number: The module number to scrape

        Returns:
            CourseData object or None if scraping failed
        """
        # Find the latest version
        latest_version = self.find_latest_version(module_number)
        if latest_version is None:
            self.failed_modules.append(module_number)
            return None

        # Fetch and parse the latest version
        html = self.fetch_html(module_number, latest_version)
        if html is None:
            self.failed_modules.append(module_number)
            return None

        return self.parse_module(html, module_number, latest_version)

    def scrape_all(self, module_numbers: list[int]) -> list[dict]:
        """
        Scrape all provided module numbers.

        Args:
            module_numbers: List of module numbers to scrape

        Returns:
            List of dictionaries with scraped course data
        """
        results = []
        total = len(module_numbers)

        for idx, number in enumerate(module_numbers, 1):
            logger.info(f"Scraping module {number} ({idx}/{total})")

            course_data = self.scrape_module(number)
            if course_data:
                results.append(asdict(course_data))

            self._wait()

        logger.info(f"Scraping complete: {len(results)}/{total} modules successful")
        if self.failed_modules:
            logger.warning(f"Failed modules: {self.failed_modules}")

        return results


def load_module_numbers_from_csv(csv_paths: list[str]) -> list[int]:
    """
    Load unique module numbers from CSV files.

    Args:
        csv_paths: List of paths to CSV files with course data

    Returns:
        List of unique module numbers
    """
    all_numbers = set()

    for path in csv_paths:
        try:
            df = pd.read_csv(path)
            if "#M" in df.columns:
                numbers = df["#M"].dropna().astype(int).tolist()
                all_numbers.update(numbers)
                logger.info(f"Loaded {len(numbers)} module numbers from {path}")
        except Exception as e:
            logger.error(f"Failed to load {path}: {e}")

    return sorted(list(all_numbers))


def main():
    """Main entry point for the scraper."""
    # Load module numbers from all CSV files
    csv_paths = [
        "./data/inf_courses.csv",
        "./data/winf_courses.csv",
        "./data/wiwi_courses.csv",
    ]

    module_numbers = load_module_numbers_from_csv(csv_paths)
    logger.info(f"Total unique modules to scrape: {len(module_numbers)}")

    # Initialize scraper with configurable delay
    scraper = MosesScraper(delay=1.0)

    # Scrape all modules
    results = scraper.scrape_all(module_numbers)

    # Save results to JSON
    output_path = "./data/scraped_courses.json"
    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(results, f, indent=2, ensure_ascii=False)

    logger.info(f"Results saved to {output_path}")

    # Save failed modules for retry
    if scraper.failed_modules:
        failed_path = "./data/failed_modules.json"
        with open(failed_path, "w") as f:
            json.dump(scraper.failed_modules, f)
        logger.info(f"Failed modules saved to {failed_path}")


if __name__ == "__main__":
    main()
