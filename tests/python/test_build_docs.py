from __future__ import annotations

import importlib.util
import unittest
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[2]
SCRIPT_PATH = REPO_ROOT / "scripts" / "build_docs.py"


def load_module():
    spec = importlib.util.spec_from_file_location("build_docs", SCRIPT_PATH)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"Failed to load module from {SCRIPT_PATH}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


build_docs = load_module()


class BuildDocsHelpersTest(unittest.TestCase):
    def test_meta_description_keeps_only_the_first_sentence(self) -> None:
        self.assertEqual(
            build_docs.meta_description("Build skills. More details follow."),
            "Build skills.",
        )

    def test_reference_title_capitalizes_known_initialisms(self) -> None:
        self.assertEqual(build_docs.reference_title("python_uv_api"), "Python UV API")


if __name__ == "__main__":
    unittest.main()
