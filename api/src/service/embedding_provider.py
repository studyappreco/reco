from __future__ import annotations

from abc import ABC, abstractmethod
from typing import List, Sequence
from loguru import logger

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


class FallbackEmbeddingProvider(EmbeddingProvider):
    """
    Tries the primary provider first; on error, falls back to a secondary.
    Useful when a local provider (e.g., Ollama) might be offline.
    """

    def __init__(self, primary: EmbeddingProvider, fallback: EmbeddingProvider):
        self.primary = primary
        self.fallback = fallback

    def embed_one(self, text: str) -> List[float]:
        try:
            return self.primary.embed_one(text)
        except Exception as exc:  # broad on purpose to avoid blocking pipeline
            logger.warning(f"Primary embedding provider failed ({exc}); falling back to secondary.")
            return self.fallback.embed_one(text)

    def embed_many(self, texts: Sequence[str]) -> List[List[float]]:
        try:
            return self.primary.embed_many(texts)
        except Exception as exc:
            logger.warning(f"Primary embedding provider failed in batch ({exc}); falling back to secondary.")
            return self.fallback.embed_many(texts)


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
