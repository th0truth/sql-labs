import io
import os
import subprocess
from datetime import datetime
from typing import (
    Annotated,
    Any,
    Dict,
    List,
    Optional,
    Union,
)

import sqlalchemy as sa
from flask import (
    Blueprint,
    Response,
    abort,
    flash,
    redirect,
    render_template,
    request,
    send_file,
    url_for,
)
from flask_login import current_user, login_required

from app.core.schema import (
    ActivityLogBase,
    AuthorBase,
    BookBase,
    GenreBase,
    OrderBase,
)
from app.main import db
from app.web.charts import (
    generate_genre_chart,
    generate_price_distribution_chart,
)
from app.web.forms import BookForm, BookSearchForm
from app.web.reports import generate_books_pdf_report

bp: Blueprint = Blueprint("Main", __name__)


@bp.route("/")
@bp.route("/index")
def index() -> str:
    """Головна сторінка: інформаційна панель книгарні (Dashboard)."""
    total_books: int = (
        db.session.scalar(sa.select(sa.func.count(BookBase.book_id))) or 0
    )
    total_authors: int = (
        db.session.scalar(sa.select(sa.func.count(AuthorBase.author_id))) or 0
    )
    total_genres: int = (
        db.session.scalar(sa.select(sa.func.count(GenreBase.genre_id))) or 0
    )
    total_orders: int = (
        db.session.scalar(sa.select(sa.func.count(OrderBase.order_id))) or 0
    )

    recent_books: List[BookBase] = list(
        db.session.scalars(
            sa.select(BookBase).order_by(BookBase.created_at.desc()).limit(6)
        ).all()
    )

    return render_template(
        "index.html",
        title="Головна панель",
        total_books=total_books,
        total_authors=total_authors,
        total_genres=total_genres,
        total_orders=total_orders,
        recent_books=recent_books,
    )


@bp.route("/books", methods=["GET"])
def books_list() -> str:
    """Каталог книг: пошук, фільтрація за жанром, ціною та сортування."""
    form: BookSearchForm = BookSearchForm(request.args, meta={"csrf": False})

    genres: List[GenreBase] = list(
        db.session.scalars(sa.select(GenreBase).order_by(GenreBase.name)).all()
    )
    authors: List[AuthorBase] = list(
        db.session.scalars(
            sa.select(AuthorBase).order_by(AuthorBase.last_name)
        ).all()
    )

    form.genre_id.choices = [(0, "Всі жанри")] + [
        (g.genre_id, g.name) for g in genres
    ]
    form.author_id.choices = [(0, "Всі автори")] + [
        (a.author_id, a.full_name) for a in authors
    ]

    query: Any = sa.select(BookBase).join(BookBase.author).join(BookBase.genre)

    search_term: str = request.args.get("query", "").strip()

    if search_term:
        query = query.where(
            sa.or_(
                BookBase.title.ilike(f"%{search_term}%"),
                BookBase.isbn.ilike(f"%{search_term}%"),
                AuthorBase.last_name.ilike(f"%{search_term}%"),
                AuthorBase.first_name.ilike(f"%{search_term}%"),
            )
        )

    genre_id: Optional[int] = request.args.get("genre_id", type=int)

    if genre_id and genre_id > 0:
        query = query.where(BookBase.genre_id == genre_id)

    author_id: Optional[int] = request.args.get("author_id", type=int)

    if author_id and author_id > 0:
        query = query.where(BookBase.author_id == author_id)

    min_price: Optional[float] = request.args.get("min_price", type=float)

    if min_price is not None:
        query = query.where(BookBase.price >= min_price)

    max_price: Optional[float] = request.args.get("max_price", type=float)

    if max_price is not None:
        query = query.where(BookBase.price <= max_price)

    sort_by: str = request.args.get("sort_by", "title_asc")

    if sort_by == "title_desc":
        query = query.order_by(BookBase.title.desc())

    elif sort_by == "price_asc":
        query = query.order_by(BookBase.price.asc())

    elif sort_by == "price_desc":
        query = query.order_by(BookBase.price.desc())

    elif sort_by == "year_desc":
        query = query.order_by(BookBase.publication_year.desc())

    else:
        query = query.order_by(BookBase.title.asc())

    books: List[BookBase] = list(db.session.scalars(query).all())

    return render_template(
        "books/list.html",
        title="Каталог книг",
        books=books,
        form=form,
    )


@bp.route("/books/add", methods=["GET", "POST"])
@login_required
def book_add() -> Union[Response, str]:
    """Додавання книги (CREATE)."""
    form: BookForm = BookForm()

    genres: List[GenreBase] = list(
        db.session.scalars(sa.select(GenreBase).order_by(GenreBase.name)).all()
    )
    authors: List[AuthorBase] = list(
        db.session.scalars(
            sa.select(AuthorBase).order_by(AuthorBase.last_name)
        ).all()
    )

    form.genre_id.choices = [(g.genre_id, g.name) for g in genres]
    form.author_id.choices = [(a.author_id, a.full_name) for a in authors]

    if form.validate_on_submit():
        isbn_val: str = form.isbn.data.strip()
        existing_isbn: Optional[BookBase] = db.session.scalar(
            sa.select(BookBase).where(BookBase.isbn == isbn_val)
        )

        if existing_isbn:
            flash("Книга з таким ISBN вже зареєстрована.", "error")

            return render_template(
                "books/form.html", title="Додати книгу", form=form
            )

        book: BookBase = BookBase(
            isbn=isbn_val,
            title=form.title.data.strip(),
            author_id=form.author_id.data,
            genre_id=form.genre_id.data,
            publication_year=form.publication_year.data,
            pages=form.pages.data,
            price=form.price.data,
            stock_quantity=form.stock_quantity.data,
        )
        db.session.add(book)
        db.session.commit()

        details: Dict[str, Any] = {
            "title": book.title,
            "price": float(book.price),
            "isbn": book.isbn,
        }
        ActivityLogBase.log(
            action="CREATE",
            entity_type="BOOK",
            entity_id=book.book_id,
            user_id=current_user.user_id,
            username=current_user.username,
            details=details,
            ip_address=request.remote_addr,
        )
        flash(f"Книгу «{book.title}» успішно додано!", "success")

        return redirect(url_for("Web.Main.books_list"))

    return render_template(
        "books/form.html", title="Додати книгу", form=form, is_edit=False
    )


@bp.route("/books/<int:book_id>/edit", methods=["GET", "POST"])
@login_required
def book_edit(
    book_id: Annotated[int, "Book ID"],
) -> Union[Response, str]:
    """Редагування книги (UPDATE)."""
    book: Optional[BookBase] = db.session.get(BookBase, book_id)

    if not book:
        abort(404)

    form: BookForm = BookForm(obj=book)

    genres: List[GenreBase] = list(
        db.session.scalars(sa.select(GenreBase).order_by(GenreBase.name)).all()
    )
    authors: List[AuthorBase] = list(
        db.session.scalars(
            sa.select(AuthorBase).order_by(AuthorBase.last_name)
        ).all()
    )

    form.genre_id.choices = [(g.genre_id, g.name) for g in genres]
    form.author_id.choices = [(a.author_id, a.full_name) for a in authors]

    if form.validate_on_submit():
        old_price: float = float(book.price)
        new_price: float = float(form.price.data)

        book.isbn = form.isbn.data.strip()
        book.title = form.title.data.strip()
        book.author_id = form.author_id.data
        book.genre_id = form.genre_id.data
        book.publication_year = form.publication_year.data
        book.pages = form.pages.data
        book.price = form.price.data
        book.stock_quantity = form.stock_quantity.data

        db.session.commit()

        details: Dict[str, Any] = {
            "title": book.title,
            "old_price": old_price,
            "new_price": new_price,
        }
        ActivityLogBase.log(
            action="UPDATE",
            entity_type="BOOK",
            entity_id=book.book_id,
            user_id=current_user.user_id,
            username=current_user.username,
            details=details,
            ip_address=request.remote_addr,
        )
        flash(f"Дані книги «{book.title}» успішно оновлено!", "success")

        return redirect(url_for("Web.Main.books_list"))

    return render_template(
        "books/form.html",
        title="Редагувати книгу",
        form=form,
        is_edit=True,
        book=book,
    )


@bp.route("/books/<int:book_id>/delete", methods=["POST"])
@login_required
def book_delete(
    book_id: Annotated[int, "Book ID"],
) -> Response:
    """Видалення книги (DELETE)."""

    if not current_user.is_manager:
        flash("У вас недостатньо прав для видалення записів.", "error")

        return redirect(url_for("Web.Main.books_list"))

    book: Optional[BookBase] = db.session.get(BookBase, book_id)

    if not book:
        abort(404)

    title: str = book.title

    try:
        db.session.delete(book)
        db.session.commit()

        ActivityLogBase.log(
            action="DELETE",
            entity_type="BOOK",
            entity_id=book_id,
            user_id=current_user.user_id,
            username=current_user.username,
            details={"title": title},
            ip_address=request.remote_addr,
        )
        flash(f"Книгу «{title}» успішно видалено.", "success")

    except sa.exc.SQLAlchemyError as err:
        db.session.rollback()
        flash(f"Не вдалося видалити книгу: {err}.", "error")

    return redirect(url_for("Web.Main.books_list"))


@bp.route("/authors")
def authors_list() -> str:
    """Список авторів та їх бібліографія."""
    authors: List[AuthorBase] = list(
        db.session.scalars(
            sa.select(AuthorBase).order_by(
                AuthorBase.last_name, AuthorBase.first_name
            )
        ).all()
    )

    return render_template("authors.html", title="Автори", authors=authors)


@bp.route("/stats")
def stats() -> str:
    """Аналітика та графічна візуалізація даних (Рівень 3)."""
    books: List[BookBase] = list(
        db.session.scalars(sa.select(BookBase).join(BookBase.genre)).all()
    )
    genre_chart: str = generate_genre_chart(books)
    price_chart: str = generate_price_distribution_chart(books)

    top_books: Any = (
        db.session.execute(
            sa.text("SELECT * FROM bookstore.v_top_selling_books LIMIT 5;")
        )
        .mappings()
        .all()
    )

    return render_template(
        "stats.html",
        title="Аналітика та статистика",
        genre_chart=genre_chart,
        price_chart=price_chart,
        top_books=top_books,
        books_count=len(books),
    )


@bp.route("/reports/pdf")
def export_pdf() -> Response:
    """Експорт каталогу книг у форматі PDF (Рівень 3)."""
    books: List[BookBase] = list(
        db.session.scalars(
            sa.select(BookBase)
            .join(BookBase.author)
            .join(BookBase.genre)
            .order_by(BookBase.title)
        ).all()
    )
    pdf_buffer: io.BytesIO = generate_books_pdf_report(books)

    user_id_val: Optional[int] = (
        current_user.user_id if current_user.is_authenticated else None
    )
    username_val: str = (
        current_user.username if current_user.is_authenticated else "guest"
    )

    ActivityLogBase.log(
        action="EXPORT_PDF",
        entity_type="REPORT",
        user_id=user_id_val,
        username=username_val,
        details={"books_count": len(books)},
        ip_address=request.remote_addr,
    )

    filename: str = (
        f"bookstore_catalog_{datetime.now().strftime('%Y%m%d_%H%M')}.pdf"
    )

    return send_file(
        pdf_buffer,
        as_attachment=True,
        download_name=filename,
        mimetype="application/pdf",
    )


@bp.route("/backup")
@login_required
def backup() -> Response:
    """Створення резервної копії схеми (Рівень 3)."""

    if not current_user.is_admin:
        flash("Резервне копіювання дозволено тільки адміністраторам.", "error")

        return redirect(url_for("Web.Main.index"))

    backup_dir: str = os.path.join(
        os.path.dirname(__file__), "..", "..", "..", "backups"
    )
    os.makedirs(backup_dir, exist_ok=True)
    date_str: str = datetime.now().strftime("%Y%m%d_%H%M%S")
    filename: str = f"bookstore_backup_{date_str}.sql"
    filepath: str = os.path.join(backup_dir, filename)

    try:
        db_url: Optional[str] = os.getenv("DATABASE_URL")

        if db_url:
            cmd: str = (
                f'pg_dump "{db_url}" --schema=bookstore '
                f'--clean --if-exists > "{filepath}"'
            )
            subprocess.run(cmd, shell=True, check=True)

        else:
            with open(filepath, "w", encoding="utf-8") as f:
                f.write(f"-- Backup bookstore generated at {datetime.now()}\n")

        ActivityLogBase.log(
            action="BACKUP_CREATED",
            entity_type="DATABASE",
            user_id=current_user.user_id,
            username=current_user.username,
            details={"filename": filename},
            ip_address=request.remote_addr,
        )

        return send_file(filepath, as_attachment=True, download_name=filename)

    except (subprocess.SubprocessError, OSError) as err:
        flash(f"Помилка створення резервної копії: {err}", "error")

        return redirect(url_for("Web.Main.index"))
