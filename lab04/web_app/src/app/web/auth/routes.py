from typing import Any, Dict, Optional, Union
from urllib.parse import urlsplit

from flask import (
    Blueprint,
    Response,
    flash,
    redirect,
    render_template,
    request,
    url_for,
)
from flask_login import current_user, login_user, logout_user

from app.core.schema import ActivityLogBase, UserBase
from app.core.security import Hash
from app.main import db
from app.web.forms import LoginForm, RegistrationForm

bp: Blueprint = Blueprint("Auth", __name__)


@bp.route("/login", methods=["GET", "POST"])
def login() -> Union[Response, str]:

    if current_user.is_authenticated:
        return redirect(url_for("Web.Main.index"))

    form: LoginForm = LoginForm()

    if form.validate_on_submit():
        user: Optional[UserBase] = db.session.scalar(
            db.select(UserBase).where(UserBase.username == form.username.data)
        )

        if not user or not Hash.verify(form.password.data, user.password_hash):
            flash("Невірне ім'я користувача або пароль.", "error")
            ActivityLogBase.log(
                action="LOGIN_FAILED",
                entity_type="USER",
                username=form.username.data,
                details={"ip": request.remote_addr},
                ip_address=request.remote_addr,
            )

            return redirect(url_for("Web.Auth.login"))

        remember: bool = bool(form.remember_me.data)
        login_user(user, remember=remember)
        ActivityLogBase.log(
            action="LOGIN_SUCCESS",
            entity_type="USER",
            entity_id=user.user_id,
            user_id=user.user_id,
            username=user.username,
            details={"role": user.role},
            ip_address=request.remote_addr,
        )
        flash(
            f"Ласкаво просимо, {user.username}! Ви успішно увійшли.", "success"
        )

        next_page: Optional[str] = request.args.get("next")

        if not next_page or urlsplit(next_page).netloc != "":
            next_page = url_for("Web.Main.index")

        return redirect(next_page)

    return render_template("login.html", title="Вхід до системи", form=form)


@bp.route("/register", methods=["GET", "POST"])
def register() -> Union[Response, str]:

    if current_user.is_authenticated:
        return redirect(url_for("Web.Main.index"))

    form: RegistrationForm = RegistrationForm()

    if form.validate_on_submit():
        user: UserBase = UserBase(
            username=form.username.data,
            email=form.email.data,
            role="user",
        )
        user.set_password(form.password.data)

        db.session.add(user)
        db.session.commit()

        details: Dict[str, Any] = {"email": user.email, "role": user.role}
        ActivityLogBase.log(
            action="REGISTER",
            entity_type="USER",
            entity_id=user.user_id,
            username=user.username,
            details=details,
            ip_address=request.remote_addr,
        )
        flash("Обліковий запис створено! Тепер ви можете увійти.", "success")

        return redirect(url_for("Web.Auth.login"))

    return render_template("register.html", title="Реєстрація", form=form)


@bp.route("/logout")
def logout() -> Response:

    if current_user.is_authenticated:
        ActivityLogBase.log(
            action="LOGOUT",
            entity_type="USER",
            entity_id=current_user.user_id,
            user_id=current_user.user_id,
            username=current_user.username,
            ip_address=request.remote_addr,
        )

    logout_user()
    flash("Ви вийшли з облікового запису.", "info")

    return redirect(url_for("Web.Main.index"))
