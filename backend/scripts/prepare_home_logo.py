"""Prepare homelogo for app bar + full-bleed-safe launcher icons."""
from __future__ import annotations

import re
from collections import deque
from pathlib import Path

from PIL import Image

REPO = Path(__file__).resolve().parents[2]


def remove_near_black(img: Image.Image, thr: int = 40) -> Image.Image:
    rgba = img.convert("RGBA")
    w, h = rgba.size
    px = rgba.load()
    visited = [[False] * w for _ in range(h)]
    q: deque[tuple[int, int]] = deque()

    def is_bg(r: int, g: int, b: int, a: int) -> bool:
        return a > 0 and r <= thr and g <= thr and b <= thr

    def enq(x: int, y: int) -> None:
        if x < 0 or y < 0 or x >= w or y >= h or visited[y][x]:
            return
        r, g, b, a = px[x, y]
        if not is_bg(r, g, b, a):
            return
        visited[y][x] = True
        q.append((x, y))

    for x in range(w):
        enq(x, 0)
        enq(x, h - 1)
    for y in range(h):
        enq(0, y)
        enq(w - 1, y)

    while q:
        x, y = q.popleft()
        r, g, b, _a = px[x, y]
        px[x, y] = (r, g, b, 0)
        for nx, ny in ((x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)):
            enq(nx, ny)

    for _ in range(2):
        doomed: list[tuple[int, int]] = []
        for y in range(h):
            for x in range(w):
                r, g, b, a = px[x, y]
                if a == 0 or max(r, g, b) > 55:
                    continue
                if any(
                    nx < 0 or ny < 0 or nx >= w or ny >= h or px[nx, ny][3] == 0
                    for nx, ny in ((x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1))
                ):
                    doomed.append((x, y))
        for x, y in doomed:
            r, g, b, _a = px[x, y]
            px[x, y] = (r, g, b, 0)

    bbox = rgba.getbbox()
    return rgba.crop(bbox) if bbox else rgba


def make_icon(logo: Image.Image, size: int, pad_ratio: float = 0.16, bg=(0, 0, 0, 255)) -> Image.Image:
    """Fit entire wide logo inside square without cropping."""
    canvas = Image.new("RGBA", (size, size), bg)
    inner = max(1, int(size * (1 - 2 * pad_ratio)))
    scale = min(inner / logo.width, inner / logo.height)
    nw = max(1, int(round(logo.width * scale)))
    nh = max(1, int(round(logo.height * scale)))
    scaled = logo.resize((nw, nh), Image.Resampling.LANCZOS)
    canvas.alpha_composite(scaled, ((size - nw) // 2, (size - nh) // 2))
    return canvas


def main() -> None:
    src_path = REPO / "homelogo.png"
    if not src_path.exists():
        raise SystemExit(f"missing {src_path}")

    logo = remove_near_black(Image.open(src_path))
    print(f"home logo {logo.size} aspect={logo.width / logo.height:.3f}")

    for d in (
        REPO / "mobile/assets/images",
        REPO / "courier/assets/images",
        REPO / "backend/public/images",
    ):
        d.mkdir(parents=True, exist_ok=True)
        logo.save(d / "home_logo.png")

    # Keep a transparent master next to the original name.
    logo.save(REPO / "homelogo.png")

    icon1024 = make_icon(logo, 1024, pad_ratio=0.16)
    icon1024.save(REPO / "mobile/assets/images/app_icon.png")
    icon1024.save(REPO / "courier/assets/images/app_icon.png")

    mip = {
        "mipmap-mdpi": 48,
        "mipmap-hdpi": 72,
        "mipmap-xhdpi": 96,
        "mipmap-xxhdpi": 144,
        "mipmap-xxxhdpi": 192,
    }
    draw = {
        "drawable-mdpi": 108,
        "drawable-hdpi": 162,
        "drawable-xhdpi": 216,
        "drawable-xxhdpi": 324,
        "drawable-xxxhdpi": 432,
    }
    for app in ("mobile", "courier"):
        res = REPO / app / "android/app/src/main/res"
        for folder, size in mip.items():
            out = res / folder
            out.mkdir(parents=True, exist_ok=True)
            ic = make_icon(logo, size)
            for name in ("ic_launcher.png", "ic_launcher_round.png", "ic_launcher_foreground.png"):
                ic.save(out / name)
        for folder, size in draw.items():
            out = res / folder
            if out.exists():
                make_icon(logo, size).save(out / "ic_launcher_foreground.png")
        colors = res / "values/colors.xml"
        if colors.exists():
            text = colors.read_text(encoding="utf-8")
            text = re.sub(
                r'(<color name="ic_launcher_background">)[^<]+(</color>)',
                r"\1#000000\2",
                text,
            )
            colors.write_text(text, encoding="utf-8")

    make_icon(logo, 192).save(REPO / "backend/public/favicon.png")
    make_icon(logo, 32).save(REPO / "backend/public/favicon.ico", format="ICO", sizes=[(32, 32)])
    print("homelogo prepared")


if __name__ == "__main__":
    main()
