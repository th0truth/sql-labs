#!/usr/bin/env python3
"""Лабораторна робота №4: Розробка реляційної бази даних з простою інтеграцією.

Консольний застосунок CRUD для управління книгарнею (Bookstore).
Рівень складності: Рівень 1.
"""

import sys
from typing import Annotated, Any, Dict, List, Optional, Tuple, Union

from database import DatabaseConnection

# Annotated semantic types
BookRecord = Annotated[Dict[str, Any], "Book row representation"]
AuthorRecord = Annotated[Dict[str, Any], "Author row representation"]
GenreRecord = Annotated[Dict[str, Any], "Genre row representation"]
BookId = Annotated[int, "Book primary key identifier"]
MenuChoice = Annotated[str, "CLI numeric choice selection"]


def print_header(title: Annotated[str, "Header title string"]) -> None:
    print("\n" + "=" * 78)
    print(f"📚 {title.center(72)} 📚")
    print("=" * 78)


def display_books(books: List[BookRecord]) -> None:

    if not books:
        print("\n⚠️ Книг за вказаними критеріями не знайдено.")

        return

    print("\n" + "-" * 78)
    header: str = (
        f"{'ID':<4} | {'Назва':<28} | {'Автор':<18} | {'Ціна, ₴':<8} | "
        f"{'Склад':<5}"
    )
    print(header)
    print("-" * 78)

    for b in books:
        title_str: str = (
            (b["title"][:25] + "..") if len(b["title"]) > 27 else b["title"]
        )
        author_str: str = (
            (b["author_name"][:15] + "..")
            if len(b["author_name"]) > 17
            else b["author_name"]
        )
        price_val: float = float(b["price"])
        stock_val: int = int(b["stock_quantity"])
        row: str = (
            f"{b['book_id']:<4} | {title_str:<28} | "
            f"{author_str:<18} | {price_val:<8.2f} | {stock_val:<5}"
        )
        print(row)

    print("-" * 78)
    print(f"Всього знайдено записів: {len(books)}")


def display_authors(authors: List[AuthorRecord]) -> None:

    if not authors:
        print("\n⚠️ Авторів не знайдено.")

        return

    print("\n" + "-" * 78)
    print(f"{'ID':<4} | {'Імя та Прізвище':<32} | {'Країна':<18} | {'Рік':<6}")
    print("-" * 78)

    for a in authors:
        full_name: str = f"{a['first_name']} {a['last_name']}"
        country_str: str = a["country"] or "—"
        year_str: str = str(a["birth_year"] or "—")
        print(
            f"{a['author_id']:<4} | {full_name:<32} | "
            f"{country_str:<18} | {year_str:<6}"
        )

    print("-" * 78)


def get_all_books(db: DatabaseConnection) -> List[BookRecord]:
    query: str = """
        SELECT
            b.book_id,
            b.isbn,
            b.title,
            (a.first_name || ' ' || a.last_name) AS author_name,
            g.name AS genre_name,
            b.publication_year,
            b.price,
            b.stock_quantity
        FROM books b
        JOIN authors a ON a.author_id = b.author_id
        JOIN genres g  ON g.genre_id = b.genre_id
        ORDER BY b.book_id ASC;
    """

    return db.fetch_all(query)


def get_all_authors(db: DatabaseConnection) -> List[AuthorRecord]:
    query: str = "SELECT * FROM authors ORDER BY last_name, first_name;"

    return db.fetch_all(query)


def get_all_genres(db: DatabaseConnection) -> List[GenreRecord]:
    query: str = "SELECT genre_id, name FROM genres ORDER BY name;"

    return db.fetch_all(query)


def action_add_book(db: DatabaseConnection) -> None:
    print_header("ДОДАВАННЯ НОВОЇ КНИГИ (CREATE)")

    try:
        isbn: str = input(
            "Введіть ISBN (наприклад, 978-617-12-3456-7): "
        ).strip()
        title: str = input("Введіть назву книги: ").strip()
        author_first: str = input("Ім'я автора: ").strip()
        author_last: str = input("Прізвище автора: ").strip()

        print("\nДоступні жанри:")
        genres: List[GenreRecord] = get_all_genres(db)

        for g in genres:
            print(f" [{g['genre_id']}] {g['name']}")

        genre_id: int = int(input("\nОберіть ID жанру: ").strip())
        pub_year: int = int(input("Рік видання: ").strip())
        pages: int = int(input("Кількість сторінок: ").strip())
        price: float = float(input("Ціна книги (грн): ").strip())
        stock: int = int(input("Кількість на складі: ").strip())

        query: str = """
            SELECT sp_add_book_with_author(
                %s, %s, %s, %s, %s, %s, %s, %s, %s
            ) AS new_id;
        """
        params: Tuple[Union[str, int, float], ...] = (
            isbn,
            title,
            author_first,
            author_last,
            genre_id,
            pub_year,
            pages,
            price,
            stock,
        )
        res: Optional[Dict[str, Any]] = db.fetch_one(query, params)

        if res and res.get("new_id"):
            print(f"\n✅ Книгу додано! Присвоєно ID: {res['new_id']}")

        else:
            print("\n❌ Не вдалося додати книгу.")

    except (ValueError, KeyError) as err:
        print(f"\n❌ Помилка вводу: {err}")


def action_update_book(db: DatabaseConnection) -> None:
    print_header("ОНОВЛЕННЯ ДАНИХ КНИГИ (UPDATE)")
    books: List[BookRecord] = get_all_books(db)
    display_books(books)

    try:
        book_id: BookId = int(
            input("\nВведіть ID книги для оновлення: ").strip()
        )
        existing: Optional[BookRecord] = db.fetch_one(
            "SELECT book_id, title, price, stock_quantity "
            "FROM books WHERE book_id = %s;",
            (book_id,),
        )

        if not existing:
            print("❌ Книгу з таким ID не знайдено.")

            return

        print(
            f"\nОбрано: '{existing['title']}' | "
            f"Ціна: ₴{existing['price']} | "
            f"Залишок: {existing['stock_quantity']}"
        )
        print("1. Змінити ціну")
        print("2. Змінити залишок на складі")
        print("3. Оновити ціну та залишок одночасно")
        choice: str = input("Ваш вибір: ").strip()

        if choice == "1":
            new_price: float = float(input("Нова ціна (грн): ").strip())
            db.execute_query(
                "UPDATE books SET price = %s WHERE book_id = %s;",
                (new_price, book_id),
            )
            print(f"✅ Ціну книги ID {book_id} оновлено на ₴{new_price:.2f}.")

        elif choice == "2":
            new_stock: int = int(input("Новий залишок: ").strip())
            db.execute_query(
                "UPDATE books SET stock_quantity = %s WHERE book_id = %s;",
                (new_stock, book_id),
            )
            print(f"✅ Залишок книги ID {book_id} оновлено на {new_stock} шт.")

        elif choice == "3":
            new_price = float(input("Нова ціна (грн): ").strip())
            new_stock = int(input("Новий залишок: ").strip())
            db.execute_query(
                "UPDATE books SET price = %s, stock_quantity = %s "
                "WHERE book_id = %s;",
                (new_price, new_stock, book_id),
            )
            print(f"✅ Дані книги ID {book_id} успішно оновлено.")

        else:
            print("⚠️ Невідома дія.")

    except (ValueError, KeyError) as err:
        print(f"❌ Помилка оновлення: {err}")


def action_delete_book(db: DatabaseConnection) -> None:
    print_header("ВИДАЛЕННЯ КНИГИ (DELETE)")
    books: List[BookRecord] = get_all_books(db)
    display_books(books)

    try:
        book_id: BookId = int(
            input("\nВведіть ID книги для видалення: ").strip()
        )
        existing: Optional[BookRecord] = db.fetch_one(
            "SELECT book_id, title FROM books WHERE book_id = %s;",
            (book_id,),
        )

        if not existing:
            print("❌ Книгу з таким ID не знайдено.")

            return

        confirm: str = (
            input(
                f"⚠️ Видалити книгу '{existing['title']}' (ID: {book_id})? "
                f"(так/ні): "
            )
            .strip()
            .lower()
        )

        if confirm in ("так", "yes", "y"):
            res: Any = db.execute_query(
                "DELETE FROM books WHERE book_id = %s;",
                (book_id,),
            )

            if res:
                print(f"✅ Книгу ID {book_id} успішно видалено.")

        else:
            print("Операцію скасовано користувачем.")

    except (ValueError, KeyError) as err:
        print(f"❌ Помилка видалення: {err}")


def action_search_books(db: DatabaseConnection) -> None:
    print_header("ПОШУК ТА ФІЛЬТРАЦІЯ КНИГ")
    term: str = input("Введіть пошуковий запит (назва або автор): ").strip()

    if not term:
        print("Пошуковий запит не може бути порожнім.")

        return

    pattern: str = f"%{term}%"
    query: str = """
        SELECT
            b.book_id,
            b.isbn,
            b.title,
            (a.first_name || ' ' || a.last_name) AS author_name,
            g.name AS genre_name,
            b.publication_year,
            b.price,
            b.stock_quantity
        FROM books b
        JOIN authors a ON a.author_id = b.author_id
        JOIN genres g  ON g.genre_id = b.genre_id
        WHERE LOWER(b.title) LIKE LOWER(%s)
           OR LOWER(a.first_name || ' ' || a.last_name) LIKE LOWER(%s)
        ORDER BY b.title;
    """
    results: List[BookRecord] = db.fetch_all(query, (pattern, pattern))
    display_books(results)


def action_author_analytics(db: DatabaseConnection) -> None:
    print_header("БІЗНЕС-АНАЛІТИКА ПО АВТОРАХ (PROCEDURE)")
    authors: List[AuthorRecord] = get_all_authors(db)
    display_authors(authors)

    try:
        author_id: int = int(input("\nВведіть ID автора для звіту: ").strip())
        res: Optional[Dict[str, Any]] = db.fetch_one(
            "SELECT * FROM sp_get_author_analytics(%s);",
            (author_id,),
        )

        if not res or not res.get("author_full_name"):
            print("❌ Дані по вказаному автору відсутні.")

            return

        print("\n" + "=" * 65)
        print(f"📊 ЗВЕДЕНА СТАТИСТИКА: {res['author_full_name']}")
        print("=" * 65)
        print(f" • Кількість видань:       {res['total_books']} шт.")
        print(f" • Середня ціна книги:     ₴{float(res['avg_price']):.2f}")
        print(
            f" • Діапазон цін:           "
            f"₴{float(res['min_price']):.2f} - ₴{float(res['max_price']):.2f}"
        )
        print(f" • Загальний тираж:        {res['total_stock']} прим.")
        rev: float = float(res["total_sales_revenue"])
        print(f" • Виторг замовлень:       ₴{rev:.2f}")
        print("=" * 65)

    except (ValueError, KeyError) as err:
        print(f"❌ Помилка отримання аналітики: {err}")


def main_menu() -> MenuChoice:
    print("\n" + "╔" + "═" * 58 + "╗")
    print("║        СИСТЕМА УПРАВЛІННЯ КНИГАРНЕЮ (BOOKSTORE CLI)       ║")
    print("╠" + "═" * 58 + "╣")
    print("║  1. 📖 Переглянути повний каталог книг (READ)             ║")
    print("║  2. ✍️  Переглянути авторів книгарні                       ║")
    print("║  3. ➕ Додати нову книгу (CREATE)                          ║")
    print("║  4. ✏️  Оновити ціну або залишок книги (UPDATE)            ║")
    print("║  5. 🗑️  Видалити книгу (DELETE)                            ║")
    print("║  6. 🔍 Пошук книг за назвою / автором                     ║")
    print("║  7. 📈 Аналітичний звіт по автору (STORED PROCEDURE)      ║")
    print("║  0. 🚪 Вихід з програми                                   ║")
    print("╚" + "═" * 58 + "╝")

    return input("Оберіть пункт меню: ").strip()


def main() -> None:
    db: DatabaseConnection = DatabaseConnection()
    print("⏳ Встановлення з'єднання з базою даних PostgreSQL...")

    if not db.connect():
        print("❌ Не вдалося підключитися до бази даних.")
        sys.exit(1)

    print("✅ Успішно підключено до PostgreSQL (схема bookstore)!")

    try:
        while True:
            choice: MenuChoice = main_menu()

            if choice == "1":
                books: List[BookRecord] = get_all_books(db)
                display_books(books)

            elif choice == "2":
                authors: List[AuthorRecord] = get_all_authors(db)
                display_authors(authors)

            elif choice == "3":
                action_add_book(db)

            elif choice == "4":
                action_update_book(db)

            elif choice == "5":
                action_delete_book(db)

            elif choice == "6":
                action_search_books(db)

            elif choice == "7":
                action_author_analytics(db)

            elif choice == "0":
                print("\n👋 Роботу з програмою завершено. Гарного дня!")
                break

            else:
                print("\n❌ Некоректна опція. Оберіть число від 0 до 7.")

            input("\nНатисніть Enter для повернення в меню...")

    except (KeyboardInterrupt, EOFError):
        print("\n👋 Роботу з програмою завершено. До побачення!")

    finally:
        db.disconnect()


if __name__ == "__main__":
    main()
