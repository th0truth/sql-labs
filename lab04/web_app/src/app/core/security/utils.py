from typing import Annotated

from passlib.context import CryptContext


class Hash:
    context: CryptContext = CryptContext(
        schemes=["argon2"],
        deprecated="auto",
    )

    @classmethod
    def hash(cls, plain: Annotated[str, "Plain text password"]) -> str:
        """Повернути хешований пароль."""
        hashed: str = cls.context.hash(secret=plain)

        return hashed

    @classmethod
    def verify(
        cls,
        plain: Annotated[str, "Plain text password"],
        hashed: Annotated[str, "Argon2 password hash"],
    ) -> bool:
        """Верифікувати відповідність відкритого пароля збереженому хешу."""
        is_valid: bool = cls.context.verify(secret=plain, hash=hashed)

        return is_valid
