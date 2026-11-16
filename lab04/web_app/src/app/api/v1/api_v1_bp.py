from flask import Blueprint

from .routes import auth, books, users

# Initialize the /v1
api_v1_bp: Blueprint = Blueprint("v1", __name__)

# Include blueprints to the /v1
api_v1_bp.register_blueprint(users.bp, url_prefix="/users")
api_v1_bp.register_blueprint(auth.bp, url_prefix="/auth")
api_v1_bp.register_blueprint(books.bp, url_prefix="/books")
