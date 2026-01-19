from typing import Optional
from sqlalchemy import URL
from dotenv import load_dotenv
import os

class Settings:

    def __init__(self):
        load_dotenv()
        self.develop = os.getenv("DEVELOP", "True").lower() == "true"
        self.root_path = os.getenv("ROOT_PATH", "")
        self.port = int(os.getenv("PORT", "8000"))
        self.host = os.getenv("HOST", "0.0.0.0")
        self.log_level = os.getenv("LOG_LEVEL", "INFO")
        
        self.db_auto_migrate = os.getenv("DB_AUTO_MIGRATE", "True").lower() == "true"
        self.db_host = os.getenv("DB_HOST", "localhost")
        self.db_port = int(os.getenv("DB_PORT", "5432"))
        self.db_name = os.getenv("DB_NAME", "db")
        self.db_user = os.getenv("DB_USER", "postgres")
        self.db_password = os.getenv("DB_PASSWORD", "postgres")
        
        self.llm_model = os.getenv("OLLAMA_MODEL", "llama:3.2:latest")
        self.reco_model = os.getenv("RECO_MODEL", "reco-llm-model")
        self.llm_port = int(os.getenv("LLM_PORT", "11434"))
        self.llm_host = os.getenv("OLLAMA_BASE_PATH", "http://localhost:11434")
        self.llm_host_local = "http://localhost:11434"
        # Embedding settings
        self.embedding_provider = os.getenv("EMBEDDING_PROVIDER", "ollama")
        self.embedding_model = os.getenv("EMBEDDING_MODEL", self.llm_model)
        self.embedding_base_url: Optional[str] = os.getenv("EMBEDDING_BASE_URL")
        self.openai_api_key: Optional[str] = os.getenv("OPENAI_API_KEY")

        self.jwt_secret = os.getenv("JWT_SECRET", "change-me")
        self.jwt_algorithm = os.getenv("JWT_ALGORITHM", "HS256")
        self.jwt_expire_minutes = int(os.getenv("JWT_EXPIRE_MINUTES", "60"))

    #for now, change when running on docker
    def llm_url(self) -> str:
        return f"http://{self.llm_host_local}:{self.llm_port}"
    


    def database_url(self) -> URL:
        url = URL.create(
            drivername="postgresql",
            username=self.db_user,
            password=self.db_password,
            host=self.db_host,
            port=self.db_port,
            database=self.db_name,
            query=dict(),
        )
        return url
