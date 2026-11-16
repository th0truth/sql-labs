from collections.abc import Callable
from functools import wraps
from typing import (
    Annotated,
    Any,
    Dict,
    List,
    Optional,
    Tuple,
    Union,
)

import sqlalchemy as sa
from flask import Blueprint, Response, jsonify, request

from app.core.config import settings
from app.core.schema import ActivityLogBase, AuthorBase, BookBase, GenreBase
from app.main import db

bp: Blueprint = Blueprint("BooksAPI", __name__)


def require_api_key(f: Callable[..., Any]) -> Callable[..., Any]:

    @wraps(f)
    def decorated_function(*args: Any, **kwargs: Any) -> Any:
        api_key: Optional[str] = request.headers.get("X-API-Key")

        if api_key != settings.API_KEY:
            error_msg: Dict[str, Any] = {
                "success": False,
                "error": "Invalid or missing X-API-Key header",
            }

            return jsonify(error_msg), 401

        return f(*args, **kwargs)

    return decorated_function


@bp.route("/", methods=["GET"])
def get_all_books() -> Union[Tuple[Response, int], Response]:
    """Отримати список усіх книг з можливістю фільтрації."""
    query: Any = sa.select(BookBase).join(BookBase.author).join(BookBase.genre)

    genre_id: Optional[int] = request.args.get("genre_id", type=int)

    if genre_id:
        query = query.where(BookBase.genre_id == genre_id)

    books: List[BookBase] = list(db.session.scalars(query).all())

    return jsonify(
        {
            "success": True,
            "count": len(books),
            "data": [b.to_dict() for b in books],
        }
    )


@bp.route("/<int:book_id>", methods=["GET"])
def get_book(
    book_id: Annotated[int, "Book ID"],
) -> Tuple[Response, int]:
    """Отримати детальну інформацію про конкретну книгу."""
    book: Optional[BookBase] = db.session.get(BookBase, book_id)

    if not book:
        return jsonify({"success": False, "error": "Book not found"}), 404

    return jsonify({"success": True, "data": book.to_dict()}), 200


@bp.route("/", methods=["POST"])
@require_api_key
def create_book() -> Tuple[Response, int]:
    """Створити нову книгу через REST API (потребує X-API-Key)."""
    data: Dict[str, Any] = request.get_json() or {}

    required: List[str] = ["isbn", "title", "author_id", "genre_id", "price"]
    missing: List[str] = [f for f in required if f not in data]

    if missing:
        msg: str = f"Missing required fields: {', '.join(missing)}"

        return jsonify({"success": False, "error": msg}), 400

    if not db.session.get(AuthorBase, data["author_id"]):
        return jsonify({"success": False, "error": "Invalid author_id"}), 400

    if not db.session.get(GenreBase, data["genre_id"]):
        return jsonify({"success": False, "error": "Invalid genre_id"}), 400

    existing_isbn: Optional[BookBase] = db.session.scalar(
        sa.select(BookBase).where(BookBase.isbn == data["isbn"])
    )

    if existing_isbn:
        err_dup: str = "Book with this ISBN already exists"

        return jsonify({"success": False, "error": err_dup}), 409

    try:
        new_book: BookBase = BookBase(
            isbn=data["isbn"],
            title=data["title"],
            author_id=data["author_id"],
            genre_id=data["genre_id"],
            publication_year=data.get("publication_year"),
            pages=data.get("pages"),
            price=data["price"],
            stock_quantity=data.get("stock_quantity", 0),
        )
        db.session.add(new_book)
        db.session.commit()

        details: Dict[str, Any] = {
            "title": new_book.title,
            "isbn": new_book.isbn,
        }
        ActivityLogBase.log(
            action="API_CREATE",
            entity_type="BOOK",
            entity_id=new_book.book_id,
            username="api_client",
            details=details,
            ip_address=request.remote_addr,
        )

        return (
            jsonify(
                {
                    "success": True,
                    "message": "Book created successfully",
                    "data": new_book.to_dict(),
                }
            ),
            201,
        )

    except sa.exc.SQLAlchemyError as err:
        db.session.rollback()

        return jsonify({"success": False, "error": str(err)}), 500


@bp.route("/<int:book_id>", methods=["DELETE"])
@require_api_key
def delete_book(
    book_id: Annotated[int, "Book ID"],
) -> Tuple[Response, int]:
    """Видалити книгу через REST API (потребує X-API-Key)."""
    book: Optional[BookBase] = db.session.get(BookBase, book_id)

    if not book:
        return jsonify({"success": False, "error": "Book not found"}), 404

    try:
        title: str = book.title
        db.session.delete(book)
        db.session.commit()

        ActivityLogBase.log(
            action="API_DELETE",
            entity_type="BOOK",
            entity_id=book_id,
            username="api_client",
            details={"title": title},
            ip_address=request.remote_addr,
        )

        return (
            jsonify(
                {
                    "success": True,
                    "message": f"Book '{title}' deleted successfully",
                }
            ),
            200,
        )

    except sa.exc.SQLAlchemyError as err:
        db.session.rollback()

        return jsonify({"success": False, "error": str(err)}), 500
