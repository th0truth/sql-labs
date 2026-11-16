from datetime import UTC, datetime
from typing import (
    Annotated,
    Any,
    ClassVar,
    Dict,
    Optional,
)

import sqlalchemy as sa
import sqlalchemy.orm as so
from sqlalchemy.dialects.postgresql import JSONB

from app.main import db


class ActivityLogBase(db.Model):
    __tablename__: str = "activity_log"
    __table_args__: ClassVar[Dict[str, str]] = {"schema": "bookstore"}

    log_id: so.Mapped[int] = so.mapped_column(primary_key=True)
    user_id: so.Mapped[Optional[int]] = so.mapped_column(
        sa.ForeignKey("bookstore.users.user_id"), nullable=True
    )
    username: so.Mapped[Optional[str]] = so.mapped_column(sa.String(64))
    action: so.Mapped[str] = so.mapped_column(sa.String(50))
    entity_type: so.Mapped[str] = so.mapped_column(sa.String(50))
    entity_id: so.Mapped[Optional[int]] = so.mapped_column(
        sa.Integer, nullable=True
    )
    details: so.Mapped[Optional[Dict[str, Any]]] = so.mapped_column(
        JSONB, nullable=True
    )
    ip_address: so.Mapped[Optional[str]] = so.mapped_column(sa.String(45))
    created_at: so.Mapped[datetime] = so.mapped_column(
        default=lambda: datetime.now(UTC), index=True
    )

    @classmethod
    def log(
        cls,
        action: Annotated[str, "Action code name"],
        entity_type: Annotated[str, "Target entity type"],
        entity_id: Optional[int] = None,
        user_id: Optional[int] = None,
        username: Optional[str] = None,
        details: Optional[Dict[str, Any]] = None,
        ip_address: Optional[str] = None,
    ) -> Optional["ActivityLogBase"]:

        try:
            entry: ActivityLogBase = cls(
                user_id=user_id,
                username=username,
                action=action,
                entity_type=entity_type,
                entity_id=entity_id,
                details=details or {},
                ip_address=ip_address,
            )
            db.session.add(entry)
            db.session.commit()

            return entry

        except sa.exc.SQLAlchemyError:
            db.session.rollback()

            return None

    def __repr__(self) -> str:

        return (
            f"<ActivityLog {self.action} on "
            f"{self.entity_type}#{self.entity_id} by {self.username}>"
        )
