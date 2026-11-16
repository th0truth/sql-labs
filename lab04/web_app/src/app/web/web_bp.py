from flask import Blueprint

from .auth.routes import bp as auth_bp
from .main.routes import bp as main_bp

# Initialize Web blueprint
web_bp: Blueprint = Blueprint("Web", __name__)

# Include blueprints
web_bp.register_blueprint(auth_bp)
web_bp.register_blueprint(main_bp)
