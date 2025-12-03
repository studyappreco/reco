

enum DocumentType {
  IS_TRANSCRIPT
  IS_NOT_TRANSCRIPT
}


function Is_the_right_content(content : string) -> DocumentType {
  client OpenAiClient
  prompt #"
    {{ _.role("user")}}

    Can you determine if all the information listed below is present in the content given to you?

    Following elements should be contained in the 
      - university address: Straße des 17. Juni 135 10623 Berlin
      - an annotation section with description of grades
      - information how to verify this document
      - optional: data on exams and grades finished or failed

    {{ ctx.output_format }}
    {{ content }}
  "#
}


class TranscriptRow {
  exam_number int? @description("No. of Exam | Prüfungsnr")
  exam_name string? @description("Name of Exam | Bezeichnung der Leistung")
  term string? @description("Term | Semester; starts with Summer or Winter")
  exam_date string? @description("Date of Exam | Prüf. Datum; The schema is dd.MM.yyyy")
  grade float? @description("Grade | Note")
  ects float? @description("Credits | LP")
}

function Parse_transcript_contents(transcript : string) -> TranscriptRow[] {
  client OpenAiClient
  prompt #"
    {{ _.role("user")}}
    Given to you is the content of a university transcript.
    Please extract information of already taken exams in form of a structured table.
    German and English transcripts have the same structure but different column names.

    Courses have minimum of 3 ECTS and maximum of 12. Disregard anything else.
    Grades can range from 1.0 to 5.0 disregard aanything else.
    Dates have the following scheme: dd.MM.yyyy

    Entries like "core studies" , "elective modules" or something similar do not resemble courses but general Information
    disregard these as they do not represent courdse information.

    {{ ctx.output_format }}
    {{ transcript }}
  "#
}






