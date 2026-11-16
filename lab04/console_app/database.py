import os
from pathlib import Path
from typing import Annotated, Any, Dict, List, Optional, Tuple, Union

import psycopg2
from dotenv import load_dotenv
from psycopg2.extensions import connection, cursor
from psycopg2.extras import RealDictCursor

base_dir: Path = Path(__file__).resolve().parent
repo_root: Path = base_dir.parent.parent

if (repo_root / ".env").exists():
    load_dotenv(repo_root / ".env")

elif (base_dir / ".env").exists():
    load_dotenv(base_dir / ".env")

# Annotated type aliases for clear domain semantics
DatabaseUri = Annotated[str, "PostgreSQL connection URI"]
SqlParam = Annotated[
    Optional[Union[Tuple[Any, ...], List[Any]]],
    "Query parameters tuple or list",
]


class DatabaseConnection:
    """Клас інкапсуляції підключення до PostgreSQL СУБД."""

    def __init__(
        self,
        database_url: Optional[DatabaseUri] = None,
    ) -> None:
        self.database_url: Optional[str] = database_url or os.getenv(
            "DATABASE_URL"
        )
        self.conn: Optional[connection] = None

    def connect(self) -> bool:

        try:
            if self.database_url:
                self.conn = psycopg2.connect(self.database_url)

            else:
                self.conn = psycopg2.connect(
                    dbname=os.getenv("POSTGRES_DB", "bookstore"),
                    user=os.getenv("POSTGRES_USER", "postgres"),
                    password=os.getenv("POSTGRES_PASSWORD", "password"),
                    host=os.getenv("POSTGRES_HOST", "localhost"),
                    port=int(os.getenv("POSTGRES_PORT", "5432")),
                )

            with self.conn.cursor() as cur:
                cur.execute("SET search_path TO bookstore, public;")
                self.conn.commit()

            return True

        except psycopg2.Error as err:
            print(f"❌ Помилка підключення до бази даних: {err}")
            self.conn = None

            return False

    def disconnect(self) -> None:
        if self.conn and not self.conn.closed:
            self.conn.close()
            print("🔌 З'єднання з базою даних закрито.")

    def execute_query(
        self,
        query: str,
        params: SqlParam = None,
    ) -> Optional[cursor]:
        """Виконання DML інструкцій (INSERT, UPDATE, DELETE)."""

        if not self.conn:
            print("❌ Відсутнє активне підключення до БД.")

            return None

        try:
            cur: cursor = self.conn.cursor()
            cur.execute(query, params)
            self.conn.commit()

            return cur

        except psycopg2.Error as err:
            self.conn.rollback()
            print(f"❌ Помилка виконання SQL-запиту: {err}")

            return None

    def fetch_all(
        self,
        query: str,
        params: SqlParam = None,
    ) -> List[Dict[str, Any]]:
        """Отримання всіх результатів вибірки у форматі словника."""

        if not self.conn:
            return []

        try:
            with self.conn.cursor(cursor_factory=RealDictCursor) as cur:
                cur.execute(query, params)

                return list(cur.fetchall())

        except psycopg2.Error as err:
            self.conn.rollback()
            print(f"❌ Помилка вибірки даних: {err}")

            return []

    def fetch_one(
        self,
        query: str,
        params: SqlParam = None,
    ) -> Optional[Dict[str, Any]]:
        """Отримання одного рядка результату вибірки."""

        if not self.conn:
            return None

        try:
            with self.conn.cursor(cursor_factory=RealDictCursor) as cur:
                cur.execute(query, params)

                return cur.fetchone()

        except psycopg2.Error as err:
            self.conn.rollback()
            print(f"❌ Помилка вибірки рядка: {err}")

            return None
