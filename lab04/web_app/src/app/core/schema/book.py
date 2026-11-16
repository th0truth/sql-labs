from datetime import UTC, datetime
from typing import (
    TYPE_CHECKING,
    Annotated,
    ClassVar,
    Dict,
    List,
    Optional,
    Union,
)

import sqlalchemy as sa
import sqlalchemy.orm as so

from app.main import db

if TYPE_CHECKING:
    from .order import OrderItemBase


class GenreBase(db.Model):
    __tablename__: str = "genres"
    __table_args__: ClassVar[Dict[str, str]] = {"schema": "bookstore"}

    genre_id: so.Mapped[int] = so.mapped_column(primary_key=True)
    name: so.Mapped[str] = so.mapped_column(
        sa.String(50), unique=True, index=True
    )
    description: so.Mapped[Optional[str]] = so.mapped_column(sa.Text)
    created_at: so.Mapped[datetime] = so.mapped_column(
        default=lambda: datetime.now(UTC)
    )

    books: so.Mapped[List["BookBase"]] = so.relationship(
        back_populates="genre"
    )

    def __repr__(self) -> str:

        return f"<Genre {self.name}>"


class AuthorBase(db.Model):
    __tablename__: str = "authors"
    __table_args__: ClassVar[Dict[str, str]] = {"schema": "bookstore"}

    author_id: so.Mapped[int] = so.mapped_column(primary_key=True)
    first_name: so.Mapped[str] = so.mapped_column(sa.String(50))
    last_name: so.Mapped[str] = so.mapped_column(sa.String(50), index=True)
    birth_year: so.Mapped[Optional[int]] = so.mapped_column(sa.Integer)
    country: so.Mapped[Optional[str]] = so.mapped_column(sa.String(50))
    bio: so.Mapped[Optional[str]] = so.mapped_column(sa.Text)
    created_at: so.Mapped[datetime] = so.mapped_column(
        default=lambda: datetime.now(UTC)
    )

    books: so.Mapped[List["BookBase"]] = so.relationship(
        back_populates="author"
    )

    @property
    def full_name(self) -> str:

        return f"{self.first_name} {self.last_name}"

    def __repr__(self) -> str:

        return f"<Author {self.full_name}>"


class BookBase(db.Model):
    __tablename__: str = "books"
    __table_args__: ClassVar[Dict[str, str]] = {"schema": "bookstore"}

    book_id: so.Mapped[int] = so.mapped_column(primary_key=True)
    isbn: so.Mapped[str] = so.mapped_column(
        sa.String(17), unique=True, index=True
    )
    title: so.Mapped[str] = so.mapped_column(sa.String(200), index=True)
    author_id: so.Mapped[int] = so.mapped_column(
        sa.ForeignKey("bookstore.authors.author_id"), index=True
    )
    genre_id: so.Mapped[int] = so.mapped_column(
        sa.ForeignKey("bookstore.genres.genre_id"), index=True
    )
    publication_year: so.Mapped[Optional[int]] = so.mapped_column(sa.Integer)
    pages: so.Mapped[Optional[int]] = so.mapped_column(sa.Integer)
    price: so.Mapped[float] = so.mapped_column(sa.Numeric(10, 2))
    stock_quantity: so.Mapped[int] = so.mapped_column(default=0)
    created_at: so.Mapped[datetime] = so.mapped_column(
        default=lambda: datetime.now(UTC)
    )
    updated_at: so.Mapped[datetime] = so.mapped_column(
        default=lambda: datetime.now(UTC),
        onupdate=lambda: datetime.now(UTC),
    )

    author: so.Mapped["AuthorBase"] = so.relationship(back_populates="books")
    genre: so.Mapped["GenreBase"] = so.relationship(back_populates="books")
    order_items: so.Mapped[List["OrderItemBase"]] = so.relationship(
        back_populates="book"
    )

    @property
    def in_stock(self) -> bool:

        return self.stock_quantity > 0

    def to_dict(
        self,
    ) -> Dict[str, Annotated[Union[int, str, float, None], "Book property"]]:
        author_name: Optional[str] = (
            self.author.full_name if self.author else None
        )
        genre_name: Optional[str] = self.genre.name if self.genre else None

        result: Dict[
            str, Annotated[Union[int, str, float, None], "Book property"]
        ] = {
            "book_id": self.book_id,
            "isbn": self.isbn,
            "title": self.title,
            "author_id": self.author_id,
            "author_name": author_name,
            "genre_id": self.genre_id,
            "genre_name": genre_name,
            "publication_year": self.publication_year,
            "pages": self.pages,
            "price": float(self.price),
            "stock_quantity": self.stock_quantity,
        }

        return result

    def __repr__(self) -> str:

        return f"<Book {self.title}>"
