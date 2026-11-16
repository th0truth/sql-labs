from datetime import UTC, datetime
from typing import (
    TYPE_CHECKING,
    ClassVar,
    Dict,
    List,
    Optional,
)

import sqlalchemy as sa
import sqlalchemy.orm as so

from app.main import db

if TYPE_CHECKING:
    from .book import BookBase


class CustomerBase(db.Model):
    __tablename__: str = "customers"
    __table_args__: ClassVar[Dict[str, str]] = {"schema": "bookstore"}

    customer_id: so.Mapped[int] = so.mapped_column(primary_key=True)
    full_name: so.Mapped[str] = so.mapped_column(sa.String(100))
    email: so.Mapped[str] = so.mapped_column(
        sa.String(100), unique=True, index=True
    )
    phone: so.Mapped[Optional[str]] = so.mapped_column(sa.String(20))
    city: so.Mapped[Optional[str]] = so.mapped_column(sa.String(50))
    address: so.Mapped[Optional[str]] = so.mapped_column(sa.String(200))
    discount_percent: so.Mapped[float] = so.mapped_column(
        sa.Numeric(5, 2), default=0.00
    )
    created_at: so.Mapped[datetime] = so.mapped_column(
        default=lambda: datetime.now(UTC)
    )

    orders: so.Mapped[List["OrderBase"]] = so.relationship(
        back_populates="customer"
    )

    def __repr__(self) -> str:

        return f"<Customer {self.full_name}>"


class OrderBase(db.Model):
    __tablename__: str = "orders"
    __table_args__: ClassVar[Dict[str, str]] = {"schema": "bookstore"}

    order_id: so.Mapped[int] = so.mapped_column(primary_key=True)
    customer_id: so.Mapped[int] = so.mapped_column(
        sa.ForeignKey("bookstore.customers.customer_id"), index=True
    )
    order_date: so.Mapped[datetime] = so.mapped_column(
        default=lambda: datetime.now(UTC), index=True
    )
    status: so.Mapped[str] = so.mapped_column(sa.String(20), default="Pending")
    total_amount: so.Mapped[float] = so.mapped_column(
        sa.Numeric(10, 2), default=0.00
    )
    notes: so.Mapped[Optional[str]] = so.mapped_column(sa.Text)

    customer: so.Mapped["CustomerBase"] = so.relationship(
        back_populates="orders"
    )
    items: so.Mapped[List["OrderItemBase"]] = so.relationship(
        back_populates="order", cascade="all, delete-orphan"
    )

    def __repr__(self) -> str:

        return (
            f"<Order #{self.order_id} - {self.status} (₴{self.total_amount})>"
        )


class OrderItemBase(db.Model):
    __tablename__: str = "order_items"
    __table_args__: ClassVar[Dict[str, str]] = {"schema": "bookstore"}

    order_item_id: so.Mapped[int] = so.mapped_column(primary_key=True)
    order_id: so.Mapped[int] = so.mapped_column(
        sa.ForeignKey("bookstore.orders.order_id"), index=True
    )
    book_id: so.Mapped[int] = so.mapped_column(
        sa.ForeignKey("bookstore.books.book_id"), index=True
    )
    quantity: so.Mapped[int] = so.mapped_column(sa.Integer)
    unit_price: so.Mapped[float] = so.mapped_column(sa.Numeric(10, 2))
    subtotal: so.Mapped[float] = so.mapped_column(
        sa.Numeric(10, 2), sa.Computed("quantity * unit_price")
    )

    order: so.Mapped["OrderBase"] = so.relationship(back_populates="items")
    book: so.Mapped["BookBase"] = so.relationship(back_populates="order_items")

    def __repr__(self) -> str:

        return (
            f"<OrderItem order={self.order_id} "
            f"book={self.book_id} qty={self.quantity}>"
        )
