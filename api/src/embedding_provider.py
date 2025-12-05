from __future__ import annotations

from abc import ABC, abstractmethod
from typing import List, Sequence

from ollama import Client as OllamaClient
from openai import OpenAI


class EmbeddingProvider(ABC):
    """
    Strategy interface so we can swap embedding backends (Ollama, OpenAI, etc.)
    without changing call sites.
    """

    @abstractmethod
    def embed_one(self, text: str) -> List[float]:
        """
        Embed a single string.
        """

    def embed_many(self, texts: Sequence[str]) -> List[List[float]]:
        """
        Default implementation batches naively; override if backend supports batching.
        """
        return [self.embed_one(text) for text in texts]


class OllamaEmbeddingProvider(EmbeddingProvider):
    """
    Uses the local Ollama server for embeddings.
    """

    def __init__(self, model: str, host: str | None = None):
        self.model = model
        self.client = OllamaClient(host=host) if host else OllamaClient()

    def embed_one(self, text: str) -> List[float]:
        response = self.client.embeddings(model=self.model, prompt=text)
        return response["embedding"]


class OpenAIEmbeddingProvider(EmbeddingProvider):
    """
    Works with OpenAI or any OpenAI-compatible endpoint (e.g. local server with
    an OpenAI-like API surface) by supplying a custom base_url.
    """

    def __init__(self, model: str, api_key: str | None = None, base_url: str | None = None):
        self.model = model
        self.client = OpenAI(api_key=api_key, base_url=base_url) if base_url else OpenAI(api_key=api_key)

    def embed_one(self, text: str) -> List[float]:
        response = self.client.embeddings.create(model=self.model, input=text)
        return response.data[0].embedding

    def embed_many(self, texts: Sequence[str]) -> List[List[float]]:
        response = self.client.embeddings.create(model=self.model, input=list(texts))
        return [item.embedding for item in response.data]


def build_embedding_provider(
    provider: str,
    model: str,
    *,
    api_key: str | None = None,
    base_url: str | None = None,
    host: str | None = None,
) -> EmbeddingProvider:
    """
    Factory helper to construct an embedding provider from settings/env.
    provider: "ollama" | "openai"
    """
    normalized = provider.lower()
    if normalized == "ollama":
        return OllamaEmbeddingProvider(model=model, host=host)
    if normalized == "openai":
        return OpenAIEmbeddingProvider(model=model, api_key=api_key, base_url=base_url)
    raise ValueError(f"Unsupported embedding provider: {provider}")
