from abc import ABC, abstractmethod
import requests
from openai import OpenAI

class EmbeddingProvider(ABC):
    @abstractmethod
    def embed(self, text: str) -> list[float]:
        pass


class OllamaEmbeddingProvider(EmbeddingProvider):
    def embed(self, text: str) -> list[float]:
        response = requests.post("http://blabla/api/embed", json={"model": "mistral", "input": text})   #ToDO: replace with actual URL
        return response.json()["embedding"]


class OpenAIEmbeddingProvider(EmbeddingProvider):
    def embed(self, text: str) -> list[float]:
        client = OpenAI()
        response = client.embeddings.create(model="text-embedding-ada-002", input=text) # or 3-small or 3-large?
        return response.data[0].embedding

