from typing import Optional
from sqlalchemy import URL

class Settings:

    develop : bool = True

    root_path: str = ""
    port: int = 8000
    host: str = "0.0.0.0"
    log_level: str = "INFO"

    db_auto_migrate: bool = True
    db_host: str = "localhost"
    db_port: int = 5452
    db_name: str = "db"
    db_user: str = "postgres"
    db_password: str = "postgres"


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