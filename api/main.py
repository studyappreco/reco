import uvicorn
from src.logging import UVICORN_LOG_CONFIG
from src.settings import Settings


def main():
    settings = Settings()
    uvicorn.run(
        "src.app:create_app",
        host=settings.host,
        port=settings.port,
        reload=settings.develop,
        log_config=UVICORN_LOG_CONFIG,
        factory=True,
    )


if __name__ == "__main__":
    main()