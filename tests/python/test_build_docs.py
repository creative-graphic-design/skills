from __future__ import annotations

import importlib.util
import sys
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch


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
    def test_reference_images_are_copied_without_changing_markdown_navigation(self) -> None:
        with tempfile.TemporaryDirectory() as temporary_directory:
            root = Path(temporary_directory).resolve()
            skills_root = root / "skills"
            skill_name = "cgd-non-designers-design-create"
            skill_dir = skills_root / "non-designers-design-skills" / skill_name
            references = skill_dir / "references"
            references.mkdir(parents=True)
            images = {
                "comparison.png": bytes.fromhex(
                    "89504e470d0a1a0a0000000d4948445200000001000000010804000000b51c0c02"
                    "0000000b4944415478da6364f80f00010501012718e3660000000049454e44ae426082"
                ),
                "comparison.svg": b'<svg xmlns="http://www.w3.org/2000/svg"/>\n',
            }
            for filename, content in images.items():
                (references / filename).write_bytes(content)
            (references / "guide.md").write_text("# Guide\n")
            image_links = "\n".join(
                f"![Comparison](references/{filename})" for filename in images
            )
            (skill_dir / "SKILL.md").write_text(
                f"---\nname: {skill_name}\ndescription: Create designs.\n---\n\n"
                f"# Create\n\n{image_links}\n\n[Guide](references/guide.md)\n"
            )

            with (
                patch.object(build_docs, "REPO_ROOT", root),
                patch.object(build_docs, "SKILLS_ROOT", skills_root),
                patch.object(build_docs, "ASSETS_ROOT", root / "assets"),
                patch.object(sys, "argv", ["build_docs.py"]),
            ):
                self.assertEqual(build_docs.main(), 0)

            page_dir = root / "docs" / skill_name
            page = (page_dir / "index.md").read_text()
            navigation = (root / "docs" / ".nav.yml").read_text()
            for filename, content in images.items():
                self.assertIn(f"![Comparison](references/{filename})", page)
                self.assertEqual((page_dir / "references" / filename).read_bytes(), content)
                self.assertNotIn(filename, navigation)
            self.assertIn(
                f"      - Guide: {skill_name}/references/guide.md\n", navigation
            )
            guide = (page_dir / "references" / "guide.md").read_text()
            self.assertIn('title: "Guide"', guide)
            self.assertTrue(guide.endswith("# Guide\n"))

    def test_grouped_skills_are_discovered_without_workspace_copies(self) -> None:
        with tempfile.TemporaryDirectory() as temporary_directory:
            root = Path(temporary_directory).resolve()
            skills_root = root / "skills"
            collection = skills_root / "non-designers-design-skills"
            skill_names = (
                "cgd-non-designers-design-create",
                "cgd-non-designers-design-review",
                "cgd-non-designers-design-skill",
            )
            for skill_name in skill_names:
                skill_dir = collection / skill_name
                skill_dir.mkdir(parents=True)
                (skill_dir / "SKILL.md").write_text(
                    f"---\nname: {skill_name}\ndescription: {skill_name}.\n---\n\n"
                    f"# {skill_name}\n"
                )

            collection_workspace = (
                skills_root / "non-designers-design-skills-workspace" / "copy"
            )
            collection_workspace.mkdir(parents=True)
            (collection_workspace / "SKILL.md").write_text("---\nname: copy\n---\n")
            skill_workspace = collection / "cgd-non-designers-design-review-workspace"
            skill_workspace.mkdir()
            (skill_workspace / "SKILL.md").write_text(
                "---\nname: cgd-non-designers-design-review-workspace\n---\n"
            )

            with (
                patch.object(build_docs, "REPO_ROOT", root),
                patch.object(build_docs, "SKILLS_ROOT", skills_root),
                patch.object(build_docs, "ASSETS_ROOT", root / "assets"),
                patch.object(
                    sys,
                    "argv",
                    ["build_docs.py", "--output", "docs", "--nav", "docs/.nav.yml"],
                ),
            ):
                self.assertEqual(build_docs.main(), 0)

            index = (root / "docs" / "index.md").read_text()
            navigation = (root / "docs" / ".nav.yml").read_text()
            for skill_name in skill_names:
                self.assertIn(f"({skill_name}/index.md)", index)
                self.assertIn(f"{skill_name}/index.md", navigation)
                self.assertTrue((root / "docs" / skill_name / "index.md").is_file())
            self.assertNotIn("copy", index)
            self.assertNotIn("copy", navigation)
            self.assertNotIn("non-designers-design-skills/", index)
            self.assertNotIn("non-designers-design-skills/", navigation)

    def test_meta_description_keeps_only_the_first_sentence(self) -> None:
        self.assertEqual(
            build_docs.meta_description("Build skills. More details follow."),
            "Build skills.",
        )

    def test_reference_title_capitalizes_known_initialisms(self) -> None:
        self.assertEqual(build_docs.reference_title("python_uv_api"), "Python UV API")


if __name__ == "__main__":
    unittest.main()
