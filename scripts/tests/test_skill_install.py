"""Offline tests for the portable KB skill installer.

Every test uses temporary HOME/agent/config paths. Nothing is installed into a
real agent directory and no existing config contents are printed.
"""

from __future__ import annotations

import os
import subprocess
import tempfile
import unittest
from pathlib import Path


REPO = Path(__file__).resolve().parents[2]
INSTALLER = REPO / "skills" / "install.sh"


class SkillInstallerTests(unittest.TestCase):
    def run_installer(self, *args: str, root: Path) -> subprocess.CompletedProcess[str]:
        env = os.environ.copy()
        env["HOME"] = str(root / "home")
        env["CLAUDE_HOME"] = str(root / "claude")
        env["CODEX_HOME"] = str(root / "codex")
        env.pop("KB_ROOT", None)
        env.pop("KB_CONFIG", None)
        env.pop("KB_CONFIG_PATH", None)
        env.pop("KB_AGENT", None)
        return subprocess.run(
            ["bash", str(INSTALLER), *args],
            cwd=REPO,
            env=env,
            text=True,
            capture_output=True,
            check=False,
        )

    def test_claude_default_is_backward_compatible(self) -> None:
        with tempfile.TemporaryDirectory() as raw:
            root = Path(raw)
            result = self.run_installer("--agent", "claude", root=root)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertTrue((root / "claude" / "skills" / "kb-ask" / "SKILL.md").is_file())
            self.assertTrue((root / "claude" / "kb-config.md").is_file())

    def test_codex_default_creates_concrete_config(self) -> None:
        with tempfile.TemporaryDirectory() as raw:
            root = Path(raw)
            result = self.run_installer("--agent", "codex", root=root)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertTrue((root / "codex" / "skills" / "kb-scan" / "SKILL.md").is_file())
            self.assertIn("KB_ROOT:", (root / "codex" / "kb-config.md").read_text())

    def test_custom_destination_and_config(self) -> None:
        with tempfile.TemporaryDirectory() as raw:
            root = Path(raw)
            destination = root / "portable-skills"
            config = root / "runtime" / "kb-config.md"
            result = self.run_installer(
                "--agent", "custom", "--destination", str(destination),
                "--config", str(config), root=root,
            )
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertTrue((destination / "kb-ask" / "references" / "kb-core.md").is_file())
            self.assertTrue((destination / "kb-relink" / "relink.py").is_file())
            self.assertTrue(config.is_file())
            self.assertNotIn("book-to-skill", {path.name for path in destination.iterdir()})

    def test_custom_agent_requires_destination(self) -> None:
        with tempfile.TemporaryDirectory() as raw:
            result = self.run_installer("--agent", "custom", root=Path(raw))
            self.assertNotEqual(result.returncode, 0)
            self.assertIn("requires --destination", result.stderr)

    def test_existing_config_is_preserved_and_redacted(self) -> None:
        with tempfile.TemporaryDirectory() as raw:
            root = Path(raw)
            destination = root / "skills"
            config = root / "config.md"
            config.parent.mkdir(parents=True, exist_ok=True)
            sentinel = "KB_ROOT: /private/sentinel/vault\nVAULT_NAME: hidden-vault\n"
            config.write_text(sentinel)
            first = self.run_installer(
                "--agent", "custom", "--destination", str(destination),
                "--config", str(config), root=root,
            )
            self.assertEqual(first.returncode, 0, first.stderr)
            self.assertEqual(config.read_text(), sentinel)
            output = first.stdout + first.stderr
            self.assertNotIn("/private/sentinel/vault", output)
            self.assertNotIn("hidden-vault", output)
            second = self.run_installer(
                "--agent", "custom", "--destination", str(destination),
                "--config", str(config), "--force", root=root,
            )
            self.assertEqual(second.returncode, 0, second.stderr)
            self.assertEqual(config.read_text(), sentinel)
            replaced = self.run_installer(
                "--agent", "custom", "--destination", str(destination),
                "--config", str(config), "--force", "--force-config", root=root,
            )
            self.assertEqual(replaced.returncode, 0, replaced.stderr)
            self.assertNotEqual(config.read_text(), sentinel)
            self.assertIn("KB_ROOT:", config.read_text())

    def test_force_replaces_skill_files_but_preserves_unrelated_files(self) -> None:
        with tempfile.TemporaryDirectory() as raw:
            root = Path(raw)
            destination = root / "skills"
            config = root / "config.md"
            first = self.run_installer(
                "--agent", "custom", "--destination", str(destination),
                "--config", str(config), root=root,
            )
            self.assertEqual(first.returncode, 0, first.stderr)
            extra = destination / "kb-ask" / "local-extra.txt"
            extra.write_text("keep me")
            old_skill = destination / "kb-ask" / "SKILL.md"
            old_skill.write_text("old content")
            forced = self.run_installer(
                "--agent", "custom", "--destination", str(destination),
                "--config", str(config), "--force", root=root,
            )
            self.assertEqual(forced.returncode, 0, forced.stderr)
            self.assertEqual(extra.read_text(), "keep me")
            self.assertNotEqual(old_skill.read_text(), "old content")

    def test_custom_config_symlink_is_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as raw:
            root = Path(raw)
            destination = root / "skills"
            real_config_dir = root / "real-config"
            real_config_dir.mkdir()
            linked_config_dir = root / "linked-config"
            linked_config_dir.symlink_to(real_config_dir, target_is_directory=True)
            result = self.run_installer(
                "--agent", "custom", "--destination", str(destination),
                "--config", str(linked_config_dir / "kb-config.md"), root=root,
            )
            self.assertNotEqual(result.returncode, 0)
            self.assertIn("symlink", result.stderr)
            self.assertFalse((real_config_dir / "kb-config.md").exists())


if __name__ == "__main__":
    unittest.main()
