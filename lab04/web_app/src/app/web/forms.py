from typing import Optional

import sqlalchemy as sa
from flask_wtf import FlaskForm
from wtforms import (
    BooleanField,
    DecimalField,
    IntegerField,
    PasswordField,
    SelectField,
    StringField,
    SubmitField,
    TextAreaField,
)
from wtforms.validators import (
    DataRequired,
    Email,
    EqualTo,
    Length,
    NumberRange,
    ValidationError,
)
from wtforms.validators import (
    Optional as WtOptional,
)

from app.core.schema import UserBase
from app.main import db


class LoginForm(FlaskForm):
    username = StringField(
        "Ім'я користувача",
        validators=[DataRequired(message="Вкажіть логін")],
    )
    password = PasswordField(
        "Пароль",
        validators=[DataRequired(message="Вкажіть пароль")],
    )
    remember_me = BooleanField("Запам'ятати мене")
    submit = SubmitField("Увійти")


class RegistrationForm(FlaskForm):
    username = StringField(
        "Ім'я користувача",
        validators=[
            DataRequired(),
            Length(min=3, max=64, message="Довжина від 3 до 64 символів"),
        ],
    )
    email = StringField(
        "Електронна пошта",
        validators=[DataRequired(), Email(message="Некоректний email")],
    )
    password = PasswordField(
        "Пароль",
        validators=[
            DataRequired(),
            Length(min=6, message="Мінімум 6 символів"),
        ],
    )
    password_repeat = PasswordField(
        "Повторіть пароль",
        validators=[
            DataRequired(),
            EqualTo("password", message="Паролі не співпадають"),
        ],
    )
    submit = SubmitField("Зареєструватися")

    def validate_username(self, username: StringField) -> None:
        user: Optional[UserBase] = db.session.scalar(
            sa.select(UserBase).where(UserBase.username == username.data)
        )

        if user is not None:
            raise ValidationError(
                "Це ім'я користувача вже зайняте. Оберіть інше."
            )

    def validate_email(self, email: StringField) -> None:
        user: Optional[UserBase] = db.session.scalar(
            sa.select(UserBase).where(UserBase.email == email.data)
        )

        if user is not None:
            raise ValidationError("Ця електронна адреса вже використовується.")


class EditProfileForm(FlaskForm):
    username = StringField("Ім'я користувача", validators=[DataRequired()])
    about_me = TextAreaField(
        "Про себе",
        validators=[Length(min=0, max=250)],
    )
    submit = SubmitField("Зберегти зміни")


class BookForm(FlaskForm):
    isbn = StringField(
        "ISBN код книги",
        validators=[
            DataRequired(message="Вкажіть ISBN"),
            Length(min=10, max=17),
        ],
    )
    title = StringField(
        "Назва видання",
        validators=[
            DataRequired(message="Вкажіть назву"),
            Length(min=1, max=200),
        ],
    )
    author_id = SelectField("Автор", coerce=int, validators=[DataRequired()])
    genre_id = SelectField(
        "Жанр / Категорія", coerce=int, validators=[DataRequired()]
    )
    publication_year = IntegerField(
        "Рік публікації",
        validators=[
            DataRequired(),
            NumberRange(min=1000, max=2030, message="Рік між 1000 та 2030"),
        ],
    )
    pages = IntegerField(
        "Кількість сторінок",
        validators=[
            WtOptional(),
            NumberRange(min=1, max=10000, message="Від 1 до 10000"),
        ],
    )
    price = DecimalField(
        "Ціна книги (грн)",
        places=2,
        validators=[
            DataRequired(),
            NumberRange(min=0.0, message="Ціна не може бути від'ємною"),
        ],
    )
    stock_quantity = IntegerField(
        "Кількість на складі",
        default=0,
        validators=[
            DataRequired(),
            NumberRange(min=0, message="Залишок >= 0"),
        ],
    )
    submit = SubmitField("Зберегти книгу")


class BookSearchForm(FlaskForm):
    query = StringField("Пошук за назвою або ISBN", validators=[WtOptional()])
    genre_id = SelectField("Жанр", coerce=int, validators=[WtOptional()])
    author_id = SelectField("Автор", coerce=int, validators=[WtOptional()])
    min_price = DecimalField("Мін. ціна", places=2, validators=[WtOptional()])
    max_price = DecimalField("Макс. ціна", places=2, validators=[WtOptional()])
    sort_by = SelectField(
        "Сортувати за",
        choices=[
            ("title_asc", "Назвою (А-Я)"),
            ("title_desc", "Назвою (Я-А)"),
            ("price_asc", "Ціною (зростання)"),
            ("price_desc", "Ціною (спадання)"),
            ("year_desc", "Новинками (рік ↓)"),
        ],
        default="title_asc",
    )
    submit = SubmitField("Фільтрувати")
