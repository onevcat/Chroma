#!/usr/bin/env python3
import argparse
import pathlib
import re
import sys


BASE16_KEYS = [
    "base00",
    "base01",
    "base02",
    "base03",
    "base04",
    "base05",
    "base06",
    "base07",
    "base08",
    "base09",
    "base0A",
    "base0B",
    "base0C",
    "base0D",
    "base0E",
    "base0F",
]

# Target contrast ratio between diff background and default foreground.
# We use a script-time adjustment to avoid runtime cost and to keep
# theme appearance consistent across outputs.
TARGET_CONTRAST = 4.0


def srgb_channel_to_linear(value: float) -> float:
    if value <= 0.04045:
        return value / 12.92
    return ((value + 0.055) / 1.055) ** 2.4


def luminance(rgb: tuple[int, int, int]) -> float:
    r, g, b = rgb
    # WCAG 2.1 relative luminance: convert sRGB to linear light first.
    rs = srgb_channel_to_linear(r / 255.0)
    gs = srgb_channel_to_linear(g / 255.0)
    bs = srgb_channel_to_linear(b / 255.0)
    return 0.2126 * rs + 0.7152 * gs + 0.0722 * bs


def contrast_ratio(a: tuple[int, int, int], b: tuple[int, int, int]) -> float:
    # WCAG contrast ratio: (L1 + 0.05) / (L2 + 0.05), L1 >= L2.
    l1 = luminance(a)
    l2 = luminance(b)
    lighter = max(l1, l2)
    darker = min(l1, l2)
    return (lighter + 0.05) / (darker + 0.05)


def hex_to_rgb(value: int) -> tuple[int, int, int]:
    return ((value >> 16) & 0xff, (value >> 8) & 0xff, value & 0xff)


def rgb_to_hex(rgb: tuple[int, int, int]) -> int:
    r, g, b = rgb
    return (r << 16) | (g << 8) | b


def blend(a: tuple[int, int, int], b: tuple[int, int, int], t: float) -> tuple[int, int, int]:
    return (
        int(round(a[0] + (b[0] - a[0]) * t)),
        int(round(a[1] + (b[1] - a[1]) * t)),
        int(round(a[2] + (b[2] - a[2]) * t)),
    )


def adjust_background_for_contrast(
    background: int, foreground: int, base_background: int, target: float
) -> int:
    # Adjust diff background toward the theme background until the
    # foreground contrast meets the target. This keeps the hue family
    # of base30 colors while avoiding low-contrast text (common in light themes).
    # foreground: base16 base05 (default text color)
    # base_background: base16 base00 (editor background)
    bg_rgb = hex_to_rgb(background)
    fg_rgb = hex_to_rgb(foreground)
    base_rgb = hex_to_rgb(base_background)

    if contrast_ratio(bg_rgb, fg_rgb) >= target:
        return background

    if contrast_ratio(base_rgb, fg_rgb) < target:
        # If even the background itself fails contrast, bail out to base00.
        return base_background

    # Binary search on the blend factor to reach the contrast target
    # with minimal deviation from the original base30 color.
    low = 0.0
    high = 1.0
    for _ in range(20):
        mid = (low + high) / 2.0
        candidate = blend(bg_rgb, base_rgb, mid)
        if contrast_ratio(candidate, fg_rgb) >= target:
            high = mid
        else:
            low = mid
    return rgb_to_hex(blend(bg_rgb, base_rgb, high))


def parse_table(
    source: str,
    table_name: str,
    references: dict[str, int] | None = None,
    reference_prefix: str | None = None,
) -> dict[str, int]:
    entries: dict[str, int] = {}
    lines = source.splitlines()
    start_index = None
    for index, line in enumerate(lines):
        if re.search(rf"{re.escape(table_name)}\s*=\s*\{{", line):
            start_index = index + 1
            break
    if start_index is None:
        return entries

    for line in lines[start_index:]:
        if re.match(r"\s*}\s*,?\s*$", line):
            break
        match = re.search(r"([A-Za-z0-9_]+)\s*=\s*['\"]#?([0-9a-fA-F]{6})['\"]", line)
        if match:
            key, hex_value = match.groups()
            entries[key] = int(hex_value, 16)
            continue
        if references and reference_prefix:
            ref_match = re.search(
                rf"([A-Za-z0-9_]+)\s*=\s*{re.escape(reference_prefix)}([A-Za-z0-9_]+)",
                line,
            )
            if ref_match:
                key, ref_key = ref_match.groups()
                if ref_key in references:
                    entries[key] = references[ref_key]
    return entries


def parse_appearance(source: str) -> str | None:
    match = re.search(r'M\.type\s*=\s*["\'](dark|light)["\']', source)
    if not match:
        return None
    return match.group(1)


def sanitize_identifier(name: str) -> str:
    parts = re.split(r"[^A-Za-z0-9]+", name)
    parts = [p for p in parts if p]
    if not parts:
        return "theme"
    first = parts[0].lower()
    rest = [p[:1].upper() + p[1:] for p in parts[1:]]
    identifier = first + "".join(rest)
    if identifier[0].isdigit():
        identifier = "theme" + identifier[:1].upper() + identifier[1:]
    return identifier


def pick_color(source: dict[str, int], keys: list[str], fallback: int) -> int:
    for key in keys:
        if key in source:
            return source[key]
    return fallback


def infer_appearance(base16: dict[str, int]) -> str:
    base00 = hex_to_rgb(base16["base00"])
    base05 = hex_to_rgb(base16["base05"])
    return "light" if luminance(base00) > luminance(base05) else "dark"


def load_theme(path: pathlib.Path) -> dict:
    source = path.read_text()
    base30 = parse_table(source, "M.base_30")
    base16 = parse_table(
        source,
        "M.base_16",
        references=base30,
        reference_prefix="M.base_30.",
    )
    appearance = parse_appearance(source) or infer_appearance(base16)
    missing = [key for key in BASE16_KEYS if key not in base16]
    if missing:
        raise ValueError(f"{path.name}: missing base_16 keys: {', '.join(missing)}")

    added_background = pick_color(
        base30,
        ["soft_green", "green1", "green", "vibrant_green"],
        base16["base0B"],
    )
    removed_background = pick_color(
        base30,
        ["tintred", "firered", "red", "brownred"],
        base16["base08"],
    )
    adjusted_added = adjust_background_for_contrast(
        added_background, base16["base05"], base16["base00"], TARGET_CONTRAST
    )
    adjusted_removed = adjust_background_for_contrast(
        removed_background, base16["base05"], base16["base00"], TARGET_CONTRAST
    )
    return {
        "name": path.stem,
        "identifier": sanitize_identifier(path.stem),
        "appearance": appearance,
        "base16": base16,
        "base30": base30,
        "diffAddedBackground": adjusted_added,
        "diffRemovedBackground": adjusted_removed,
    }


def render_theme(theme: dict) -> str:
    base16_lines = []
    for index, key in enumerate(BASE16_KEYS):
        suffix = "," if index < len(BASE16_KEYS) - 1 else ""
        base16_lines.append(f"            {key}: 0x{theme['base16'][key]:06x}{suffix}")
    base30_keys = sorted(theme["base30"].keys())
    base30_lines = []
    for index, key in enumerate(base30_keys):
        suffix = "," if index < len(base30_keys) - 1 else ""
        base30_lines.append(f'            "{key}": 0x{theme["base30"][key]:06x}{suffix}')

    return "\n".join(
        [
            "    .init(",
            f'        name: "{theme["name"]}",',
            f"        appearance: .{theme['appearance']},",
            "        base16: Base16Palette(",
            *base16_lines,
            "        ),",
            "        base30: [",
            *base30_lines,
            "        ],",
            f"        diffAddedBackground: 0x{theme['diffAddedBackground']:06x},",
            f"        diffRemovedBackground: 0x{theme['diffRemovedBackground']:06x}",
            "    ),",
        ]
    )


def render_identifier(theme: dict) -> str:
    return f'    public static let {theme["identifier"]}: Theme = themeByName["{theme["name"]}"]!'


def generate_data(themes: list[dict]) -> str:
    theme_blocks = "\n".join(render_theme(theme) for theme in themes)
    return "\n".join(
        [
            "import Chroma",
            "",
            "// This file is generated by Scripts/GenerateBase46Themes.py. Do not edit manually.",
            "",
            "let base46ThemeData: [Base46ThemeDefinition] = [",
            theme_blocks,
            "]",
            "",
        ]
    )


def generate_accessors(themes: list[dict]) -> str:
    identifier_blocks = "\n".join(render_identifier(theme) for theme in themes)
    return "\n".join(
        [
            "import Chroma",
            "",
            "// This file is generated by Scripts/GenerateBase46Themes.py. Do not edit manually.",
            "",
            "extension Base46Themes {",
            identifier_blocks,
            "}",
            "",
        ]
    )


def main() -> int:
    parser = argparse.ArgumentParser(description="Generate Base46 theme data for Chroma.")
    parser.add_argument("--base46", required=True, help="Path to the base46 repository.")
    parser.add_argument("--output", required=True, help="Output Swift data file path.")
    parser.add_argument(
        "--accessors-output",
        help="Output Swift file path for theme accessors (default: Base46ThemeAccessors.swift next to --output).",
    )
    parser.add_argument("--themes", nargs="*", help="Optional list of theme names to include.")
    args = parser.parse_args()

    base46_path = pathlib.Path(args.base46)
    themes_path = base46_path / "lua" / "base46" / "themes"
    if not themes_path.exists():
        print(f"Theme directory not found: {themes_path}", file=sys.stderr)
        return 1

    theme_files = sorted(themes_path.glob("*.lua"))
    if args.themes:
        requested = set(args.themes)
        theme_files = [path for path in theme_files if path.stem in requested]
        missing = requested.difference({path.stem for path in theme_files})
        if missing:
            print(f"Missing themes: {', '.join(sorted(missing))}", file=sys.stderr)
            return 1

    themes = [load_theme(path) for path in theme_files]
    output_path = pathlib.Path(args.output)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(generate_data(themes))

    accessors_path = (
        pathlib.Path(args.accessors_output)
        if args.accessors_output
        else output_path.with_name("Base46ThemeAccessors.swift")
    )
    accessors_path.write_text(generate_accessors(themes))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
