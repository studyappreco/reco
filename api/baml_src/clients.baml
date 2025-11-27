// Learn more about clients at https://docs.boundaryml.com/docs/snippets/clients/overview


client<llm> CustomOllama {
   provider openai-generic
   options {
     base_url env.OLLAMA_BASE_PATH
     model env.OLLAMA_MODEL
     default_role "user"
   }
}


// https://docs.boundaryml.com/docs/snippets/clients/retry
retry_policy Constant {
  max_retries 3
  strategy {
    type constant_delay
    delay_ms 200
  }
}
