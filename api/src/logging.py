"""Setup for logging"""

import inspect
import logging
import sys

from fastapi import Request
from loguru import logger
from src.settings import Settings

UVICORN_LOG_CONFIG = {
    "version": 1,
    "handlers": {
        "default": {
            "class":"src.logging._InterceptHandler"
        },
    },
    "loggers": {
        "uvicorn": {
            "handlers": ["default"],
            "level": "INFO",
            "propagate": True,
        },
    },
}


LOGURU_FORMAT = (
    "<green>{time:YYYY-MM-DD HH:mm:ss.SSS}</green> | "
    "<level>{level: <8}</level> | "
    "<cyan>{name}</cyan> - <level>{message}</level> | {extra}"
)


def init_logging(settings: Settings):
    """
    Configure logging so that all logs are handled by `loguru`. Ensure that app settings
    are respected.
    """
    logging.basicConfig(handlers=[_InterceptHandler()], level=logging.DEBUG, force=True)
    logger.remove()
    logger.add(
        sys.stdout,
        format=LOGURU_FORMAT,
        level=settings.log_level,
        colorize=settings.develop,
        serialize=not settings.develop,
    )
    # Disable logs for specific modules as needed
    # logger.disable("modulename")


async def log_middleware(request: Request, call_next):
    """Middleware that adds request URL context to any logs created by the request"""
    with logger.contextualize(route=request.url.path):
        response = await call_next(request)
    return response


class _InterceptHandler(logging.Handler):
    """Intercept standard logging to make sure we render it using loguru"""

    def __init__(self, level: int | str = 0) -> None:
        super().__init__(level)

    def emit(self, record: logging.LogRecord) -> None:
        # Get corresponding Loguru level if it exists.
        level: str | int
        try:
            level = logger.level(record.levelname).name
        except ValueError:
            level = record.levelno

        # Find caller from where originated the logged message.
        frame, depth = inspect.currentframe(), 0
        while frame and (depth == 0 or frame.f_code.co_filename == logging.__file__):
            frame = frame.f_back
            depth += 1

        logger.opt(depth=depth, exception=record.exc_info).log(level, record.getMessage())
