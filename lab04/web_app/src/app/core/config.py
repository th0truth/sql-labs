import os
from pathlib import Path
from typing import Annotated, Optional

from dotenv import load_dotenv
from pydantic_settings import BaseSettings, SettingsConfigDict

BASE_DIR: Path = Path(__file__).resolve().parent.parent.parent.parent
REPO_ROOT: Path = BASE_DIR.parent.parent

if (REPO_ROOT / ".env").exists():
    load_dotenv(REPO_ROOT / ".env")

elif (BASE_DIR / ".env").exists():
    load_dotenv(BASE_DIR / ".env")

DatabaseUrl = Annotated[Optional[str], "PostgreSQL connection string"]
SecretKey = Annotated[str, "Flask session secret key"]
ApiKey = Annotated[str, "REST API authentication key"]


def get_default_db_uri() -> str:
    db_url: DatabaseUrl = os.getenv("DATABASE_URL")

    if db_url:
        if db_url.startswith("postgres://"):
            return db_url.replace("postgres://", "postgresql://", 1)

        return db_url

    return "postgresql://postgres:password@localhost:5432/bookstore"


class Settings(BaseSettings):
    NAME: str = "Bookstore Management System"
    SECRET_KEY: SecretKey = os.getenv(
        "SECRET_KEY", "kL9vB2nQ7xZ0wE4rT6yU8iO1pA3sD5fG7hJ9kL2"
    )
    API_KEY: ApiKey = os.getenv("API_KEY", "bookstore-secret-api-key")

    # API версії
    API_V1_STR: str = "/api/v1"
    API_V2_STR: str = "/api/v2"

    # PostgreSQL підключення
    SQLALCHEMY_DATABASE_URI: str = get_default_db_uri()
    SQLALCHEMY_TRACK_MODIFICATIONS: bool = False

    env_path: Path = REPO_ROOT / ".env"
    model_config: SettingsConfigDict = SettingsConfigDict(
        env_file=str(env_path) if env_path.exists() else ".env",
        extra="ignore",
        env_ignore_empty=True,
    )


settings: Settings = Settings()
