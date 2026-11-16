from typing import Annotated, Any, Optional

import sqlalchemy as sa
from flask import Flask
from flask_login import LoginManager
from flask_migrate import Migrate
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import event

from .core.config import settings

db: SQLAlchemy = SQLAlchemy()
migrate: Migrate = Migrate()
login: LoginManager = LoginManager()


def create_app() -> Flask:
    app: Flask = Flask(__name__)
    app.config.from_mapping(settings.model_dump())

    # Initialize extensions
    db.init_app(app)
    migrate.init_app(app, db)

    login.init_app(app)
    login.login_view = "Web.Auth.login"
    login.login_message = (
        "Будь ласка, увійдіть до системи для доступу до цієї сторінки."
    )
    login.login_message_category = "info"

    with app.app_context():

        @event.listens_for(db.engine, "connect")
        def set_search_path(
            dbapi_connection: Any,
            connection_record: Any,
        ) -> None:

            try:
                cursor = dbapi_connection.cursor()
                cursor.execute("SET search_path TO bookstore, public;")
                cursor.close()

            except (sa.exc.SQLAlchemyError, Exception):
                pass

        from .core.schema import UserBase

        @login.user_loader
        def load_user(
            user_id: Annotated[str, "User ID identifier"],
        ) -> Optional[UserBase]:

            return db.session.get(UserBase, int(user_id))

        from .api.api import api_main_bp
        from .web.web_bp import web_bp

        app.register_blueprint(web_bp)
        app.register_blueprint(api_main_bp)

        return app


app: Flask = create_app()
