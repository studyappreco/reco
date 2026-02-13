"""
Manages HTTP connection pool with automatic token refresh for SAP AI Core.
Provides both chat model (Agent) and embedding model (Embedder).
"""

from dataclasses import dataclass, field
import os
import time

import httpx
from openai import AsyncOpenAI
from pydantic_ai import Agent, Embedder
from pydantic_ai.models.openai import OpenAIChatModel
from pydantic_ai.embeddings.openai import OpenAIEmbeddingModel
from pydantic_ai.providers.openai import OpenAIProvider


@dataclass
class agent_context:
    """
    Manages HTTP connection pool with automatic token refresh.
    This class is intended to be stored as a singleton inside app.state (FastAPI).
    Whenever the token is refreshed, new models are created but the connection pool stays the same.
    """

    model_name: str = "gpt-4o-mini"
    embedding_model_name: str = "text-embedding-3-small"
    token_expires_in: int = 28800  # 8 hours
    system_prompt: str = ""

    _token: str | None = field(default=None, repr=False)
    _token_timestamp: float | None = field(default=None, repr=False)
    _http_client: httpx.AsyncClient | None = field(default=None, repr=False)
    _chat_model: OpenAIChatModel | None = field(default=None, repr=False)
    _base_url_chat: str | None = field(default=None, repr=False)
    _base_url_embedding: str | None = field(default=None, repr=False)
    _agent: Agent | None = field(default=None, repr=False)
    _embedder: Embedder | None = field(default=None, repr=False)

    @property
    def agent(self) -> Agent:
        """Get the agent (after initialization)."""
        if self._agent is None:
            raise RuntimeError("Not initialized. Call `await ctx.initialize()` first.")
        return self._agent

    @property
    def embedder(self) -> Embedder:
        """Get the embedder (after initialization)."""
        if self._embedder is None:
            raise RuntimeError("Not initialized. Call `await ctx.initialize()` first.")
        return self._embedder

    @property
    def chat_model(self) -> OpenAIChatModel:
        """Get the chat model (after initialization)."""
        if self._chat_model is None:
            raise RuntimeError("Not initialized. Call `await ctx.initialize()` first.")
        return self._chat_model

    def _is_token_valid(self) -> bool:
        if not self._token or not self._token_timestamp:
            return False
        return (time.time() - self._token_timestamp) < self.token_expires_in

    async def _fetch_token(self) -> str:
        """Fetch a new auth token from AI Core."""
        async with httpx.AsyncClient() as client:
            response = await client.post(
                os.environ["LLM_AUTH_URL"],
                data={"grant_type": "client_credentials"},
                auth=(os.environ["LLM_CLIENT_ID"], os.environ["LLM_CLIENT_SECRET"]),
            )
            response.raise_for_status()

        self._token = response.json()["access_token"]
        self._token_timestamp = time.time()
        return self._token

    async def _fetch_deployment_id(self, name : str) -> str:
        """Fetch deployment ID for the model."""
        url = f"{os.environ['LLM_API_BASE']}/lm/deployments"
        headers = {
            "AI-Resource-Group": os.environ["LLM_RESOURCE_GROUP"],
            "Authorization": f"Bearer {self._token}",
        }

        async with httpx.AsyncClient() as client:
            response = await client.get(url, headers=headers)
            response.raise_for_status()

        for deployment in response.json().get("resources", []):
            if deployment.get("scenarioId") != "foundation-models":
                continue
            model_details = (
                deployment.get("details", {})
                .get("resources", {})
                .get("backend_details", {})
                .get("model", {})
            )
            print(model_details)
            if model_details.get("name") == name:
                return deployment["id"]

        raise ValueError(f"Model '{name}' not found in available deployments.")

    def _create_openai_client(self, key: str) -> AsyncOpenAI:
        """Create an AsyncOpenAI client with the current token."""
        if key == "Chat":
            return AsyncOpenAI(
                base_url=self._base_url_chat,
                api_key=self._token,
                http_client=self._http_client,
            )
        else:
            return AsyncOpenAI(
                base_url=self._base_url_embedding,
                api_key=self._token,
                http_client=self._http_client,
            )


    def _create_chat_model(self) -> None:
        """Create the OpenAI chat model."""
        client = self._create_openai_client(key = "Chat")
        provider = OpenAIProvider(openai_client=client)
        self._chat_model = OpenAIChatModel(self.model_name, provider=provider)

    def _create_embedder(self) -> None:
        """Create the Pydantic AI embedder."""
        client = self._create_openai_client(key = "embedder")
        provider = OpenAIProvider(openai_client=client)
        embedding_model = OpenAIEmbeddingModel(
            self.embedding_model_name,
            provider=provider,
        )
        self._embedder = Embedder(embedding_model)

    async def initialize(self) -> "agent_context":
        """Initialize the context (call once at startup)."""
        await self._fetch_token()
        deployment_id_chat = await self._fetch_deployment_id(self.model_name)
        deplyoment_id_embedding = await self._fetch_deployment_id(self.embedding_model_name)

        self._base_url_chat = f"{os.environ['LLM_API_BASE']}/inference/deployments/{deployment_id_chat}"
        self._base_url_embedding = f"{os.environ['LLM_API_BASE']}/inference/deployments/{deplyoment_id_embedding}"
        self._http_client = httpx.AsyncClient(
            headers={"AI-Resource-Group": os.environ["LLM_RESOURCE_GROUP"]},
            params={"api-version": os.environ.get("LLM_API_VERSION", "2024-06-01")},
        )
        self._create_chat_model()
        self._create_embedder()
        return self

    async def ensure_valid_token(self) -> None:
        """Refresh token if expired (call before LLM requests)."""
        if not self._is_token_valid():
            await self._fetch_token()
            self._create_chat_model()
            self._create_embedder()

    async def close(self) -> None:
        """Cleanup resources."""
        if self._http_client:
            await self._http_client.aclose()
