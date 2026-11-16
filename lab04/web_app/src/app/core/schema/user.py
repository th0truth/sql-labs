from datetime import UTC, datetime
from hashlib import md5
from typing import Annotated, ClassVar, Dict, Optional, Union

import sqlalchemy as sa
import sqlalchemy.orm as so
from flask_login import UserMixin

from app.core.security import Hash
from app.main import db

Username = Annotated[str, "Unique account username"]
EmailAddress = Annotated[str, "Unique account email address"]
PasswordHash = Annotated[str, "Argon2 encoded password hash"]
UserRole = Annotated[str, "RBAC system role: admin, manager, user"]


class UserBase(UserMixin, db.Model):
    __tablename__: str = "users"
    __table_args__: ClassVar[Dict[str, str]] = {"schema": "bookstore"}

    user_id: so.Mapped[int] = so.mapped_column(primary_key=True)
    username: so.Mapped[Username] = so.mapped_column(
        sa.String(64), unique=True, index=True
    )
    email: so.Mapped[EmailAddress] = so.mapped_column(
        sa.String(100), unique=True, index=True
    )
    password_hash: so.Mapped[PasswordHash] = so.mapped_column(sa.String(256))
    role: so.Mapped[UserRole] = so.mapped_column(sa.String(20), default="user")
    is_active: so.Mapped[bool] = so.mapped_column(default=True)
    created_at: so.Mapped[datetime] = so.mapped_column(
        default=lambda: datetime.now(UTC)
    )

    def get_id(self) -> str:

        return str(self.user_id)

    @property
    def is_admin(self) -> bool:

        return self.role == "admin"

    @property
    def is_manager(self) -> bool:

        return self.role in ("admin", "manager")

    def set_password(self, password: Union[str, bytes]) -> None:
        raw: str = (
            password.decode("utf-8")
            if isinstance(password, bytes)
            else password
        )
        self.password_hash = Hash.hash(raw)

    def check_password(self, password: Optional[str]) -> bool:

        if not password:
            return False

        return Hash.verify(password, self.password_hash)

    def avatar(self, size: int = 40) -> str:
        digest: str = md5(self.email.lower().encode("utf-8")).hexdigest()

        return f"https://www.gravatar.com/avatar/{digest}?d=identicon&s={size}"

    def __repr__(self) -> str:

        return f"<User {self.username} ({self.role})>"
