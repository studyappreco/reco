use("reco_db")

const q = "<trimmedInterests>"


db.courses.aggregate([
  {
    $search: {
      index: "course_recommendation",
      compound: {
        should: [
          { text: { query: q, path: "title", score: { boost: { value: 4 } } } },
          { text: { query: q, path: ["learn_content", "learn_result"] } }
        ],
        minimumShouldMatch: 1
      }
    }
  },
  { $project: { number: 1, title: 1, ects: 1, score: { $meta: "searchScore" } } },
  { $limit: 50 }
])
