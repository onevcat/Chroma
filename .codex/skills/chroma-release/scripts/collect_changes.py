#!/usr/bin/env python3
import argparse
import subprocess
import sys
from typing import Optional


def run(cmd: list[str]) -> str:
    result = subprocess.run(cmd, check=True, text=True, stdout=subprocess.PIPE)
    return result.stdout


def latest_tag() -> Optional[str]:
    try:
        return run(["git", "describe", "--tags", "--abbrev=0"]).strip()
    except subprocess.CalledProcessError:
        return None


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Collect changes between the latest tag and HEAD for release notes."
    )
    parser.add_argument("--since-tag", help="Override the tag to compare from.")
    args = parser.parse_args()

    tag = args.since_tag or latest_tag()
    if tag:
        range_spec = f"{tag}..HEAD"
        log_args = ["git", "log", "--reverse", range_spec, "--pretty=format:%h %s%n%b%n---"]
        diff_args = ["git", "diff", "--name-status", range_spec]
        stat_args = ["git", "diff", "--stat", range_spec]
    else:
        range_spec = "<root>..HEAD"
        log_args = ["git", "log", "--reverse", "--pretty=format:%h %s%n%b%n---"]
        diff_args = ["git", "diff", "--name-status", "--root", "HEAD"]
        stat_args = ["git", "diff", "--stat", "--root", "HEAD"]

    print("# Release Context")
    print(f"latest_tag: {tag or 'none'}")
    print(f"range: {range_spec}")
    print("\n## Commit Log")
    print(run(log_args).rstrip())
    print("\n## Changed Files")
    print(run(diff_args).rstrip())
    print("\n## Diff Stat")
    print(run(stat_args).rstrip())
    return 0


if __name__ == "__main__":
    sys.exit(main())
