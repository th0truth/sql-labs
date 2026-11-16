import io
from datetime import datetime
from typing import Annotated, Any, List

from reportlab.lib import colors
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import cm
from reportlab.platypus import (
    Paragraph,
    SimpleDocTemplate,
    Spacer,
    Table,
    TableStyle,
)


def generate_books_pdf_report(
    books: Annotated[List[Any], "List of BookBase models"],
) -> io.BytesIO:
    """Генерація офіційного PDF-звіту каталогу книгарні (Рівень 3)."""
    buffer: io.BytesIO = io.BytesIO()
    doc: SimpleDocTemplate = SimpleDocTemplate(
        buffer,
        pagesize=A4,
        leftMargin=1.5 * cm,
        rightMargin=1.5 * cm,
        topMargin=1.5 * cm,
        bottomMargin=1.5 * cm,
    )
    elements: List[Any] = []
    styles = getSampleStyleSheet()

    title_style: ParagraphStyle = ParagraphStyle(
        "DocTitle",
        parent=styles["Heading1"],
        fontSize=18,
        leading=22,
        textColor=colors.HexColor("#1e293b"),
        alignment=1,
        spaceAfter=10,
    )

    meta_style: ParagraphStyle = ParagraphStyle(
        "DocMeta",
        parent=styles["Normal"],
        fontSize=9,
        leading=12,
        textColor=colors.HexColor("#64748b"),
        alignment=1,
        spaceAfter=15,
    )

    cell_style: ParagraphStyle = ParagraphStyle(
        "CellText",
        parent=styles["Normal"],
        fontSize=8,
        leading=10,
    )

    header_cell_style: ParagraphStyle = ParagraphStyle(
        "HeaderCellText",
        parent=styles["Normal"],
        fontSize=8,
        leading=10,
        textColor=colors.white,
    )

    elements.append(
        Paragraph("ЗВІТ: КАТАЛОГ ВИДАНЬ КНИЖКОВОГО МАГАЗИНУ", title_style)
    )
    date_str: str = datetime.now().strftime("%d.%m.%Y %H:%M:%S")
    elements.append(
        Paragraph(
            f"Дата формування: {date_str} | СУБД: PostgreSQL (Bookstore DB)",
            meta_style,
        )
    )

    table_data: List[List[Paragraph]] = [
        [
            Paragraph("<b>#</b>", header_cell_style),
            Paragraph("<b>ISBN</b>", header_cell_style),
            Paragraph("<b>Назва книги</b>", header_cell_style),
            Paragraph("<b>Автор</b>", header_cell_style),
            Paragraph("<b>Жанр</b>", header_cell_style),
            Paragraph("<b>Рік</b>", header_cell_style),
            Paragraph("<b>Ціна, ₴</b>", header_cell_style),
            Paragraph("<b>Склад</b>", header_cell_style),
        ]
    ]

    total_price: float = 0.0
    total_stock: int = 0

    for idx, b in enumerate(books, 1):
        price: float = float(b.price)
        stock: int = int(b.stock_quantity)
        total_price += price
        total_stock += stock

        author_name: str = b.author.full_name if b.author else "—"
        genre_name: str = b.genre.name if b.genre else "—"

        table_data.append(
            [
                Paragraph(str(idx), cell_style),
                Paragraph(b.isbn, cell_style),
                Paragraph(b.title, cell_style),
                Paragraph(author_name, cell_style),
                Paragraph(genre_name, cell_style),
                Paragraph(str(b.publication_year or "—"), cell_style),
                Paragraph(f"{price:.2f}", cell_style),
                Paragraph(str(stock), cell_style),
            ]
        )

    table: Table = Table(
        table_data,
        colWidths=[
            1.0 * cm,
            3.2 * cm,
            5.0 * cm,
            3.5 * cm,
            2.5 * cm,
            1.2 * cm,
            1.8 * cm,
            1.3 * cm,
        ],
    )

    table.setStyle(
        TableStyle(
            [
                ("BACKGROUND", (0, 0), (-1, 0), colors.HexColor("#0f172a")),
                ("ALIGN", (0, 0), (-1, -1), "LEFT"),
                ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
                ("BOTTOMPADDING", (0, 0), (-1, 0), 4),
                ("TOPPADDING", (0, 0), (-1, 0), 4),
                ("GRID", (0, 0), (-1, -1), 0.5, colors.HexColor("#cbd5e1")),
                (
                    "ROWBACKGROUNDS",
                    (0, 1),
                    (-1, -1),
                    [colors.white, colors.HexColor("#f8fafc")],
                ),
            ]
        )
    )

    elements.append(table)
    elements.append(Spacer(1, 15))

    avg_price: float = total_price / len(books) if books else 0.0
    total_val: float = sum(
        float(b.price) * int(b.stock_quantity) for b in books
    )
    summary_text: str = f"""
    <b>ЗВЕДЕНІ ПІДСУМКИ:</b><br/>
    • Загальна кількість найменувань: <b>{len(books)}</b><br/>
    • Сумарний тираж на складі: <b>{total_stock} шт.</b><br/>
    • Середня вартість одного видання: <b>₴{avg_price:.2f}</b><br/>
    • Загальна облікова вартість фонду: <b>₴{total_val:.2f}</b>
    """
    summary_style: ParagraphStyle = ParagraphStyle(
        "SummaryStyle",
        parent=styles["Normal"],
        fontSize=9,
        leading=14,
        textColor=colors.HexColor("#334155"),
    )
    elements.append(Paragraph(summary_text, summary_style))

    doc.build(elements)
    buffer.seek(0)

    return buffer
