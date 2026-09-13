"""Remove white canvas outside the blue logo circle; keep blue + white/red logo art.

Then regenerate app icons / favicons across mobile, courier, and backend.
"""
from __future__ import annotations

import json
from collections import deque
from pathlib import Path

from PIL import Image

REPO = Path(__file__).resolve().parents[2]  # D:\AIMstore
BACKEND = REPO / "backend"
MOBILE = REPO / "mobile"
COURIER = REPO / "courier"

SRC_CANDIDATES = [
    BACKEND / "public/brand-logo.jpg",
    BACKEND / "public/brand-logo.png",
    MOBILE / "assets/images/logo.png",
    BACKEND / "public/images/logo.png",
]


def is_near_white(r: int, g: int, b: int, a: int, threshold: int = 245) -> bool:
    return a > 0 and r >= threshold and g >= threshold and b >= threshold


def remove_outer_white(img: Image.Image, threshold: int = 240) -> Image.Image:
    """Flood-fill near-white from image edges → transparent. Keeps white ink inside blue circle."""
    rgba = img.convert("RGBA")
    w, h = rgba.size
    px = rgba.load()
    visited = [[False] * w for _ in range(h)]
    q: deque[tuple[int, int]] = deque()

    def try_enqueue(x: int, y: int) -> None:
        if x < 0 or y < 0 or x >= w or y >= h or visited[y][x]:
            return
        r, g, b, a = px[x, y]
        if not is_near_white(r, g, b, a, threshold):
            return
        visited[y][x] = True
        q.append((x, y))

    for x in range(w):
        try_enqueue(x, 0)
        try_enqueue(x, h - 1)
    for y in range(h):
        try_enqueue(0, y)
        try_enqueue(w - 1, y)

    while q:
        x, y = q.popleft()
        r, g, b, _a = px[x, y]
        px[x, y] = (r, g, b, 0)
        for nx, ny in ((x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)):
            try_enqueue(nx, ny)

    # Eat light fringe stuck to the transparent exterior (anti-alias halo).
    for _ in range(4):
        doomed: list[tuple[int, int]] = []
        for y in range(h):
            for x in range(w):
                r, g, b, a = px[x, y]
                if a == 0:
                    continue
                # Light / whitish rim only — not saturated red/blue logo ink.
                if min(r, g, b) < 180 or (r + g + b) < 560:
                    continue
                touches_clear = False
                for nx, ny in ((x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)):
                    if nx < 0 or ny < 0 or nx >= w or ny >= h or px[nx, ny][3] == 0:
                        touches_clear = True
                        break
                if touches_clear:
                    doomed.append((x, y))
        for x, y in doomed:
            r, g, b, _a = px[x, y]
            px[x, y] = (r, g, b, 0)

    return rgba


def crop_to_opaque(img: Image.Image, pad: int = 2) -> Image.Image:
    bbox = img.getbbox()
    if not bbox:
        return img
    l, t, r, b = bbox
    l = max(0, l - pad)
    t = max(0, t - pad)
    r = min(img.width, r + pad)
    b = min(img.height, b + pad)
    return img.crop((l, t, r, b))


def fit_on_canvas(img: Image.Image, size: int, bg=(0, 0, 0, 0)) -> Image.Image:
    """Scale logo up or down to fill size×size, centered on transparent (or given) canvas."""
    canvas = Image.new("RGBA", (size, size), bg)
    logo = img.convert("RGBA")
    # Cover the canvas while keeping aspect ratio (upscale allowed).
    scale = min(size / logo.width, size / logo.height)
    new_w = max(1, int(round(logo.width * scale)))
    new_h = max(1, int(round(logo.height * scale)))
    logo = logo.resize((new_w, new_h), Image.Resampling.LANCZOS)
    x = (size - logo.width) // 2
    y = (size - logo.height) // 2
    canvas.alpha_composite(logo, (x, y))
    return canvas


def write_android_mipmaps(res_dir: Path, logo: Image.Image) -> None:
    mipmap_sizes = {
        "mipmap-mdpi": 48,
        "mipmap-hdpi": 72,
        "mipmap-xhdpi": 96,
        "mipmap-xxhdpi": 144,
        "mipmap-xxxhdpi": 192,
    }
    # Adaptive-icon foreground drawables (Flutter default layout).
    drawable_sizes = {
        "drawable-mdpi": 108,
        "drawable-hdpi": 162,
        "drawable-xhdpi": 216,
        "drawable-xxhdpi": 324,
        "drawable-xxxhdpi": 432,
    }
    for folder, size in mipmap_sizes.items():
        out_dir = res_dir / folder
        out_dir.mkdir(parents=True, exist_ok=True)
        icon = fit_on_canvas(logo, size)
        for name in ("ic_launcher.png", "ic_launcher_round.png", "ic_launcher_foreground.png"):
            icon.save(out_dir / name)

    for folder, size in drawable_sizes.items():
        out_dir = res_dir / folder
        if not out_dir.exists():
            continue
        fit_on_canvas(logo, size).save(out_dir / "ic_launcher_foreground.png")

    colors = res_dir / "values" / "colors.xml"
    if colors.exists():
        text = colors.read_text(encoding="utf-8")
        # Keep adaptive background as brand blue (not white).
        if "ic_launcher_background" in text:
            import re

            text = re.sub(
                r'(<color name="ic_launcher_background">)[^<]+(</color>)',
                r"\1#003399\2",
                text,
            )
            colors.write_text(text, encoding="utf-8")
        else:
            colors.write_text(
                text.replace(
                    "</resources>",
                    '    <color name="ic_launcher_background">#003399</color>\n</resources>',
                ),
                encoding="utf-8",
            )


def write_ios_icons(appiconset: Path, logo: Image.Image) -> None:
    if not appiconset.exists():
        return
    contents = appiconset / "Contents.json"
    if not contents.exists():
        fit_on_canvas(logo, 1024).save(appiconset / "Icon-App-1024x1024@1x.png")
        return
    data = json.loads(contents.read_text(encoding="utf-8"))
    for item in data.get("images", []):
        filename = item.get("filename")
        if not filename:
            continue
        scale = int(float(str(item.get("scale", "1x")).replace("x", "")))
        size_pt = float(str(item.get("size", "1024x1024")).split("x")[0])
        px = max(int(round(size_pt * scale)), 1)
        fit_on_canvas(logo, px).save(appiconset / filename)


def main() -> None:
    src_path = next((p for p in SRC_CANDIDATES if p.exists()), None)
    if src_path is None:
        raise SystemExit("No source logo found")

    cleaned = crop_to_opaque(remove_outer_white(Image.open(src_path)))
    print(f"source={src_path} -> {cleaned.size}")

    # In-app / web logos (transparent outside blue circle)
    (MOBILE / "assets/images").mkdir(parents=True, exist_ok=True)
    (COURIER / "assets/images").mkdir(parents=True, exist_ok=True)
    (BACKEND / "public/images").mkdir(parents=True, exist_ok=True)

    cleaned.save(MOBILE / "assets/images/logo.png")
    cleaned.save(MOBILE / "assets/images/logo_mark.png")
    cleaned.save(COURIER / "assets/images/logo.png")
    cleaned.save(BACKEND / "public/images/logo.png")

    # App icons: same logo centered on transparent square
    icon1024 = fit_on_canvas(cleaned, 1024)
    icon1024.save(MOBILE / "assets/images/app_icon.png")
    icon1024.save(COURIER / "assets/images/app_icon.png")

    write_android_mipmaps(MOBILE / "android/app/src/main/res", cleaned)
    write_android_mipmaps(COURIER / "android/app/src/main/res", cleaned)
    write_ios_icons(MOBILE / "ios/Runner/Assets.xcassets/AppIcon.appiconset", cleaned)
    write_ios_icons(COURIER / "ios/Runner/Assets.xcassets/AppIcon.appiconset", cleaned)

    fav = fit_on_canvas(cleaned, 192)
    fav.save(BACKEND / "public/favicon.png")
    # ICO needs opaque-ish fallback; keep blue circle on transparent then flatten to blue for tiny ico
    fav32 = fit_on_canvas(cleaned, 32)
    fav32.save(BACKEND / "public/favicon.ico", format="ICO", sizes=[(32, 32)])
    if (MOBILE / "web").exists():
        fav.save(MOBILE / "web/favicon.png")

    print("Done: white canvas removed; blue circle kept; icons regenerated.")


if __name__ == "__main__":
    main()
