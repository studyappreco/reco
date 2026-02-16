

const _csMasterPrompt = """
Extract all completed and failed exams from this transcript into a structured format.

Rules:
- German and English transcripts share the same structure (different column names)
- ECTS: Only include courses with 3-12 ECTS
- Grades: Only include grades between 0.0 and 5.0
- Dates: Format is dd.MM.yyyy

Overall structure of the Computer Science (CS) Masters Degree with English | German names is hierarchical:
    - two main categories: "Compulsory Electives" | "Wahlpflicht" and "Free Electives" | "Wahlbereich"
    - "Compulsory Electives" can be further subdivided into:
        - "Data and Software Engineering" | "Data and Software Engineering"
        - "Embedded Systems and Computer Architectures" | "Eingebettete Systeme und Rechnerarchitekturen"
        - "Foundations of Computing" | "Grundlagen der Informatik"
        - "Cognitive Systems" | "Kognitive Systeme"
        - "Digital Media and Human-Computer Interaction" | "Medientechnik und Mensch-Maschine-Interaktion"
        - "Distributed Systems and Networks" | "Verteilte Systeme und Netze"

For the output on how to call the TranscriptNodes per category:
  - "Data and Software Engineering" => "data_and_software_engineering"
  - "Embedded Systems and Computer Architectures" => "embedded_systems_and_computer_architectures"
  - "Foundations of Computing" => "foundations_of_computing"
  - "Cognitive Systems" => "cognitive_systems"
  - "Digital Media and Human-Computer Interaction" => "digital_media_and_human_computer_interaction"
  - "Distributed Systems and Networks" => "distributed_systems_and_networks"
  - "Compulsory Electives" => "compulsory_electives"
  - "Free Electives" => "free_electives"

Even if certain categories that are named above do not appear in the transcript directly include it as a TranscriptNode with an empty array of courses.

If the provided content does not match the CS master transcript rules and structure return null.
""";

const _csBachelorPrompt = """
Extract all completed and failed exams from this transcript into a structured format.

Rules:
- German and English transcripts share the same structure (different column names)
- ECTS: Only include courses with 3-12 ECTS
- Grades: include not only grades between 0.0 and 5.0, there are modules without a grade
- Dates: Format is dd.MM.yyyy
- Exclude entries starting with "Leistungsnachweis: "

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

If the course is prefixed with "Modulprüfung: "

Even if certain categories that are named above do not appear in the transcript directly include it as a TranscriptNode with an empty array of courses.

Don't confuse "Technical Foundations of Computer Science" | "Technische Grundlagen der Informatik" with "Theoretical Computer Science" | "Theoretische Informatik".
These are two different things. One is under compulsory modules and one under compulsory electives

If the provided content does not match the CS bachelor transcript rules and structure return null.
""";

const _ismPrompt = '''
Extract all completed and failed exams from this transcript into a structured format.

Rules:
- German and English transcripts share the same structure (different column names)
- ECTS: Only include courses with 3-12 ECTS
- Grades: Only include grades between 0.0 and 5.0
- Dates: Format is dd.MM.yyyy

Overall structure of the Information Systems Management (ISM) Masters Degree with English | German names is hierarchical:
    - two main categories: "Compulsory Electives" | "Wahlpflicht" and "Free Electives" | "Wahlbereich"
    - "Compulsory Electives" can be further subdivided into "Information Systems" | "Informationssysteme"  , "Computer Science" | "Informatik" and "Business and Economics" 
    - "Computer Science" can be further subdivided into "Distributed Systems and Networks" and "Data and Software Engineering"

For the output on how to call the TranscriptNodes per category:
  - "Information Systems" => "information_systems"
  - "Computer Science" => "computer_science"
  - "Business and Economics" => "business_and_economics"
  - "Compulsory Electives" => "compulsory_electives"
  -  "Free Electives" => "free_electives"
  
  Even if certain categories that are named above do not appear in the transcript directly include it as a TranscriptNode with an empty array of courses.

  
 If the provided content does not match the ISM transcript rules and structure return null.
''';

String getUserdetailsEmbeddingPrompt(List<String> interests, String program) {
  return """
   A student currently pursuing the program $program
   with the interests ${interests.join(', ')}
  """;
}


String getProgramPrompt(String programLiteral) {
  return switch (programLiteral) {
    'ISM' => _ismPrompt,
    'CS_M' => _csMasterPrompt,
    'CS_B' => _csBachelorPrompt,
    _ => throw ArgumentError('Unknown program: $programLiteral'),
  };
}

