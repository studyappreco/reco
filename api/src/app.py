from fastapi import FastAPI
from src.settings import Settings
from contextlib import asynccontextmanager
from sqlmodel import create_engine
from loguru import logger
from fastapi.openapi.utils import get_openapi
from fastapi.responses import HTMLResponse
from sqlmodel import SQLModel
from ollama import Client
from src.database import init_db

from src.router.api import router as router_example
from src.router.admin import router as router_admin
from src.router.student import router as router_student


def create_app():
    import src.model as _models
    settings = Settings()
    app = FastAPI(lifespan=get_lifespan(settings), root_path=settings.root_path, docs_url=None)

    @app.get("/health")
    def _():
        return "OK"
    
    @app.get("/docs")
    def _():
        return HTMLResponse(get_custom_swagger_js(settings.root_path))
    
    app.openapi = lambda: custom_openapi(app)
    
    app.include_router(router_example)
    app.include_router(router_admin)
    app.include_router(router_student)

    return app

def custom_openapi(app: FastAPI):
    if app.openapi_schema:
        return app.openapi_schema
    openapi_schema = get_openapi(
        title="RECO Api",
        version="1.0.0",
        summary="Api for Reco",
        description="",
        routes=app.routes,
    )
    app.openapi_schema = openapi_schema
    return app.openapi_schema


def create_ollama_model():
    client = Client()
    response = client.create(
    model='reco-llm-model',
    from_='llama3.2:latest',
    system='You are a friendly and smart helper',
    stream=False,
    )
    logger.info(f"creating the model returned: {response.status}")


def get_lifespan(settings: Settings):
    @asynccontextmanager
    async def lifespan(app: FastAPI):
        # Do setup
        app.state.settings = settings
        app.state.engine = init_db()
        
        
        create_ollama_model()
        yield
        # Do teardown
        app.state.engine = None

    return lifespan



def get_custom_swagger_js(root_path: str):
    return """
    <!DOCTYPE html>
    <html>
    <head>
    <link type="text/css" rel="stylesheet" href="https://cdn.jsdelivr.net/npm/swagger-ui-dist@5.9.0/swagger-ui.css">
    <link rel="shortcut icon" href="https://fastapi.tiangolo.com/img/favicon.png">
    <title>FastAPI - Swagger UI</title>
    </head>
    <body>
    <div id="swagger-ui">
    </div>
    <script src="https://cdn.jsdelivr.net/npm/swagger-ui-dist@5.9.0/swagger-ui-bundle.js"></script>
    <script>
    var baseURL = window.location.origin;
    var url;
    if (baseURL === "http://localhost:8000"){
    url = "/openapi.json";
    } else{
    url = "ROOT_PATH/openapi.json";
    }

    const readCookie = (name) => {
        const value = document.cookie.match(`(^|;)\\s*${name}\\s*=\\s*([^;]+)`)
        return value ? (value.pop()) : ""
    }
    const ui = SwaggerUIBundle({
        requestInterceptor: (req) => {
            if (! req.loadSpec) {
                // Add the header to "try it out" calls but not spec fetches
                req.headers["x-signavio-id"] = readCookie("token") || "";
            }
            return req;
        },
        url: url,
        "dom_id": "#swagger-ui",
        "layout": "BaseLayout",
        "deepLinking": true,
        "showExtensions": true,
        "showCommonExtensions": true,
        oauth2RedirectUrl: window.location.origin + '/docs/oauth2-redirect',
            presets: [
                SwaggerUIBundle.presets.apis,
                SwaggerUIBundle.SwaggerUIStandalonePreset
                ],
    })
    </script>
    </body>
    </html>
    """.replace("ROOT_PATH", root_path)
