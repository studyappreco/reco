

function Funny_story() -> string {
  client CustomOllama
  prompt #"
    {{ _.role("user")}}
    Tell me a funny story in 25 words max.
  "#
}