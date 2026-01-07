import uvicorn
from src.logging import UVICORN_LOG_CONFIG
from src.settings import Settings
from src.app import create_app

# Expose ASGI app for uvicorn main:app usage
app = create_app()


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
