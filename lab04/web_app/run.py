import sys
from pathlib import Path

src_dir: str = str(Path(__file__).resolve().parent / "src")

if src_dir not in sys.path:
    sys.path.insert(0, src_dir)

from app.main import app  # noqa: E402

if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=5000)
