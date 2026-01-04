#!/usr/bin/env python3
import argparse
import datetime
import re
import shutil
import subprocess
import sys
from pathlib import Path

SEMVER_RE = re.compile(r"^\d+\.\d+\.\d+$")


def die(message: str) -> None:
    print(message, file=sys.stderr)
    sys.exit(1)


def run(cmd: list[str]) -> str:
    result = subprocess.run(cmd, check=True, text=True, stdout=subprocess.PIPE)
    return result.stdout.strip()


def ensure_clean() -> None:
    status = run(["git", "status", "--porcelain"])
    if status:
        die("Working tree is not clean. Commit or stash changes first.")


def ensure_tag_missing(version: str) -> None:
    existing = run(["git", "tag", "--list", version])
    if existing:
        die(f"Git tag {version} already exists.")


def read_cli_version(path: Path) -> str:
    text = path.read_text()
    match = re.search(r"static let version = \"([^\"]+)\"", text)
    if not match:
        die(f"CLI version not found in {path}.")
    return match.group(1)


def update_cli_version(path: Path, version: str) -> None:
    text = path.read_text()
    updated, count = re.subn(
        r"static let version = \"([^\"]+)\"",
        f'static let version = "{version}"',
        text,
        count=1,
    )
    if count == 0:
        die(f"CLI version not found in {path}.")
    path.write_text(updated)


def normalize_notes(notes: str) -> list[str]:
    lines = [line.rstrip() for line in notes.splitlines()]
    while lines and not lines[0].strip():
        lines.pop(0)
    while lines and not lines[-1].strip():
        lines.pop()
    if any(line.startswith("## [") for line in lines):
        die("Notes must not contain a version header (## [x.y.z]).")
    if not lines:
        die("Notes are empty after trimming.")
    return lines


def update_changelog(path: Path, version: str, date: str, notes_lines: list[str]) -> None:
    text = path.read_text()
    if "## [Unreleased]" not in text:
        die("CHANGELOG.md missing '## [Unreleased]' section.")
    if re.search(rf"^## \[{re.escape(version)}\]", text, re.MULTILINE):
        die(f"CHANGELOG.md already has a section for {version}.")

    lines = text.splitlines()
    try:
        idx = lines.index("## [Unreleased]")
    except ValueError:
        die("CHANGELOG.md missing exact '## [Unreleased]' heading.")

    next_idx = len(lines)
    for i in range(idx + 1, len(lines)):
        if lines[i].startswith("## ["):
            next_idx = i
            break

    insert_lines = []
    if lines[:next_idx] and lines[:next_idx][-1].strip():
        insert_lines.append("")
    insert_lines += [f"## [{version}] - {date}"]
    insert_lines += notes_lines
    insert_lines.append("")

    new_lines = lines[:next_idx] + insert_lines + lines[next_idx:]
    path.write_text("\n".join(new_lines) + "\n")


def validate_date(date: str) -> None:
    if not re.match(r"^\d{4}-\d{2}-\d{2}$", date):
        die("Date must be in YYYY-MM-DD format.")


def main() -> int:
    parser = argparse.ArgumentParser(description="Prepare and publish a Chroma release.")
    parser.add_argument("--version", required=True, help="Release version (SemVer).")
    parser.add_argument("--notes-file", required=True, help="Path to changelog notes body.")
    parser.add_argument(
        "--date",
        default=datetime.date.today().isoformat(),
        help="Release date (YYYY-MM-DD).",
    )
    parser.add_argument("--allow-dirty", action="store_true", help="Skip clean tree check.")
    parser.add_argument("--skip-commit", action="store_true", help="Do not commit changes.")
    parser.add_argument("--skip-tag", action="store_true", help="Do not create a git tag.")
    parser.add_argument("--skip-release", action="store_true", help="Do not create a GitHub release.")
    args = parser.parse_args()

    version = args.version.strip()
    if not SEMVER_RE.match(version):
        die("Version must be SemVer: X.Y.Z")
    validate_date(args.date)

    notes_path = Path(args.notes_file)
    if not notes_path.exists():
        die(f"Notes file not found: {notes_path}")
    notes_lines = normalize_notes(notes_path.read_text())

    if not args.allow_dirty:
        ensure_clean()

    if args.skip_tag and not args.skip_release:
        die("--skip-tag requires --skip-release (gh may create the tag automatically).")

    if not args.skip_tag:
        ensure_tag_missing(version)

    if not args.skip_release and not shutil.which("gh"):
        die("gh CLI not found. Install GitHub CLI or skip release creation.")

    changelog_path = Path("CHANGELOG.md")
    if not changelog_path.exists():
        die("CHANGELOG.md not found.")

    cli_path = Path("Sources/Ca/CaCommand.swift")
    current_cli_version = read_cli_version(cli_path)
    if current_cli_version == version:
        die(f"CLI version already set to {version}.")

    update_cli_version(cli_path, version)
    update_changelog(changelog_path, version, args.date, notes_lines)

    updated_cli_version = read_cli_version(cli_path)
    if updated_cli_version != version:
        die("CLI version update failed.")

    subprocess.run(["git", "add", str(changelog_path), str(cli_path)], check=True)

    if not args.skip_commit:
        subprocess.run(["git", "commit", "-m", f"Release {version}"], check=True)

    if not args.skip_tag:
        subprocess.run(["git", "tag", version], check=True)

    if not args.skip_release:
        subprocess.run(
            ["gh", "release", "create", version, "--notes-file", str(notes_path)],
            check=True,
        )

    print("Release preparation complete.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
