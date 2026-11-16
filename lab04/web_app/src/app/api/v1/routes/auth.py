from typing import Union

from flask import Blueprint, Response, flash, redirect, render_template

from app.web.forms import LoginForm

bp: Blueprint = Blueprint("Authentication", __name__)


@bp.route("/login", methods=["GET", "POST"])
def login() -> Union[Response, str]:
    form: LoginForm = LoginForm()

    if form.validate_on_submit():
        flash(
            f"Login requested: {form.username.data}, {form.remember_me.data}"
        )

        return redirect("/")

    return render_template("login.html", title="Sign In", form=form)
