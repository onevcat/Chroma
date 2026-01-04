#!/usr/bin/env python3
import argparse
import re
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


def require_clean() -> None:
    status = run(["git", "status", "--porcelain"])
    if status:
        die("Working tree is not clean. Commit or stash changes first.")


def read_cli_version(path: Path) -> str:
    text = path.read_text()
    match = re.search(r"static let version = \"([^\"]+)\"", text)
    if not match:
        die(f"CLI version not found in {path}.")
    return match.group(1)


def changelog_has_version(path: Path, version: str) -> bool:
    for line in path.read_text().splitlines():
        if line.startswith(f"## [{version}]"):
            return True
    return False


def main() -> int:
    parser = argparse.ArgumentParser(description="Validate Chroma release consistency.")
    parser.add_argument("--version", required=True, help="Expected release version (SemVer).")
    parser.add_argument(
        "--require-clean",
        action="store_true",
        help="Fail if working tree is not clean.",
    )
    parser.add_argument(
        "--require-tag",
        action="store_true",
        help="Fail if the git tag does not exist.",
    )
    args = parser.parse_args()

    version = args.version.strip()
    if not SEMVER_RE.match(version):
        die("Version must be SemVer: X.Y.Z")

    if args.require_clean:
        require_clean()

    cli_version = read_cli_version(Path("Sources/Ca/CaCommand.swift"))
    if cli_version != version:
        die(f"CLI version mismatch: expected {version}, found {cli_version}.")

    changelog_path = Path("CHANGELOG.md")
    if not changelog_path.exists():
        die("CHANGELOG.md not found.")
    if not changelog_has_version(changelog_path, version):
        die(f"CHANGELOG.md missing section for {version}.")

    if args.require_tag:
        tags = run(["git", "tag", "--list", version])
        if not tags:
            die(f"Git tag {version} not found.")

    print("Release check passed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
