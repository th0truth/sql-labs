from flask import Blueprint

from app.core.config import settings

from .v1 import api_v1_bp

# Initialize the main blueprint
api_main_bp: Blueprint = Blueprint("API", __name__)

# Include routers to the main router
api_main_bp.register_blueprint(api_v1_bp, url_prefix=settings.API_V1_STR)
