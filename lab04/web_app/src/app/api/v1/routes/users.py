from typing import (
    Annotated,
    Any,
    Dict,
    List,
    Optional,
    Tuple,
    Union,
)

from flask import Blueprint, Response, jsonify, request

from app.core.schema import UserBase
from app.core.security import Hash
from app.main import db

bp: Blueprint = Blueprint("Users", __name__)


@bp.route("/", methods=["POST"])
def create_user() -> Tuple[Response, int]:
    data: Dict[str, Any] = request.get_json() or {}

    username: Optional[str] = data.get("username")
    plain_password: str = data.get("password", "")

    if not plain_password:
        return jsonify({"message": "Password required"}), 409

    email: Optional[str] = data.get("email")

    if not username or not email:
        return jsonify({"message": "Please provide username and email"}), 400

    existing_user: Optional[UserBase] = db.session.scalars(
        db.select(UserBase).where(
            (UserBase.username == username) | (UserBase.email == email)
        )
    ).first()

    if existing_user:
        return jsonify({"message": "User already exists"}), 409

    new_user: UserBase = UserBase(
        username=username,
        email=email,
        password_hash=Hash.hash(plain_password),
    )

    db.session.add(new_user)
    db.session.commit()

    res_data: Dict[str, Any] = {
        "id": new_user.user_id,
        "username": new_user.username,
        "email": new_user.email,
    }

    return jsonify(res_data), 201


@bp.route("/all", methods=["GET"])
def get_all_users() -> Response:
    users: List[UserBase] = list(db.session.scalars(db.select(UserBase)).all())

    res_list: List[Dict[str, Any]] = [
        {"id": u.user_id, "username": u.username, "email": u.email}
        for u in users
    ]

    return jsonify(res_list)


@bp.route("/<int:id>", methods=["GET"])
def get_user_by_id(
    id: Annotated[int, "User ID"],
) -> Union[Tuple[Response, int], Response]:
    user: Optional[UserBase] = db.session.get(UserBase, id)

    if not user:
        return jsonify({"message": "User not found"}), 404

    res_user: Dict[str, Any] = {
        "id": user.user_id,
        "username": user.username,
        "email": user.email,
    }

    return jsonify(res_user)
