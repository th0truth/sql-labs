import base64
import io
from collections import Counter
from typing import Annotated, Any, List

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402

plt.rcParams["font.sans-serif"] = [
    "Liberation Sans",
    "DejaVu Sans",
    "Noto Sans",
    "Arial",
    "sans-serif",
]
plt.rcParams["axes.unicode_minus"] = False


def generate_genre_chart(
    books: Annotated[List[Any], "List of BookBase models"],
) -> str:
    """Генерація кругової діаграми розподілу книг за жанрами (base64 PNG)."""

    if not books:
        return ""

    genre_names: List[str] = [
        b.genre.name if b.genre else "Інше" for b in books
    ]
    counts: Counter[str] = Counter(genre_names)

    labels: List[str] = list(counts.keys())
    values: List[int] = list(counts.values())

    fig, ax = plt.subplots(figsize=(6, 4), dpi=100)
    palette: List[str] = [
        "#3b82f6",
        "#10b981",
        "#f59e0b",
        "#ef4444",
        "#8b5cf6",
        "#ec4899",
        "#06b6d4",
        "#84cc16",
    ]
    colors_list: List[str] = [
        palette[i % len(palette)] for i in range(len(labels))
    ]

    _wedges, _texts, autotexts = ax.pie(
        values,
        labels=labels,
        autopct="%1.1f%%",
        startangle=140,
        colors=colors_list,
        textprops={"color": "#1e293b", "fontsize": 8},
    )

    for at in autotexts:
        at.set_color("white")
        at.set_weight("bold")
        at.set_fontsize(8)

    ax.set_title(
        "Розподіл книг за жанрами",
        fontsize=11,
        fontweight="bold",
        pad=12,
        color="#0f172a",
    )
    plt.tight_layout()

    buf: io.BytesIO = io.BytesIO()
    plt.savefig(buf, format="png", bbox_inches="tight")
    buf.seek(0)
    img_b64: str = base64.b64encode(buf.getvalue()).decode("utf-8")
    plt.close(fig)

    return img_b64


def generate_price_distribution_chart(
    books: Annotated[List[Any], "List of BookBase models"],
) -> str:
    """Генерація гістограми розподілу цін на книги (base64 PNG)."""

    if not books:
        return ""

    prices: List[float] = [float(b.price) for b in books]

    fig, ax = plt.subplots(figsize=(7, 4), dpi=100)
    ax.hist(
        prices,
        bins=8,
        color="#0284c7",
        edgecolor="#0369a1",
        alpha=0.85,
        rwidth=0.85,
    )

    ax.set_title(
        "Розподіл цін на видання в книгарні (грн)",
        fontsize=11,
        fontweight="bold",
        pad=12,
        color="#0f172a",
    )
    ax.set_xlabel("Ціна (₴)", fontsize=9, color="#475569")
    ax.set_ylabel("Кількість книг", fontsize=9, color="#475569")
    ax.grid(axis="y", linestyle="--", alpha=0.3)
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)

    plt.tight_layout()

    buf: io.BytesIO = io.BytesIO()
    plt.savefig(buf, format="png", bbox_inches="tight")
    buf.seek(0)
    img_b64: str = base64.b64encode(buf.getvalue()).decode("utf-8")
    plt.close(fig)

    return img_b64
