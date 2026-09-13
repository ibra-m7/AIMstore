#!/usr/bin/env python3
"""Prepare Yemeni payment method icons as square PNGs."""

from __future__ import annotations

from pathlib import Path

from PIL import Image

ROOT = Path(r"D:\AIMstore")
SRC = ROOT / "backend" / "storage" / "app" / "tmp_payment_icons"
OUT_DIRS = [
    ROOT / "backend" / "public" / "images" / "payments",
    ROOT / "backend" / "storage" / "app" / "public" / "payments",
    ROOT / "mobile" / "assets" / "images" / "payments",
]

# Prefer official app icons where available.
SOURCES = {
    "cash": None,  # generate
    "jeeb": ["jeeb_app.jpg", "jeeb.webp"],
    "floosak": ["floosak_app.jpg", "mfloos.png"],
    "onecash": ["onecash_app.jpg", "onecash_play.png", "onecash.jpg"],
    "jawali": ["jawali2_app.jpg", "jawali.png"],
    "banky": ["banky_app.jpg"],
    "easy": ["easy_play.png", "easy_app.jpg"],
    "mobile_money": ["mobilemoney_app.jpg", "mobilemoney.png"],
}


def ensure_dirs() -> None:
    for d in OUT_DIRS:
        d.mkdir(parents=True, exist_ok=True)


def make_cash_icon(size: int = 512) -> Image.Image:
    img = Image.new("RGBA", (size, size), (232, 238, 248, 255))
    # Simple brand-aligned cash mark
    from PIL import ImageDraw

    draw = ImageDraw.Draw(img)
    margin = size // 8
    draw.rounded_rectangle(
        (margin, margin, size - margin, size - margin),
        radius=size // 5,
        fill=(0, 51, 153, 255),
    )
    draw.ellipse(
        (size * 0.28, size * 0.28, size * 0.72, size * 0.72),
        fill=(227, 30, 36, 255),
    )
    draw.ellipse(
        (size * 0.36, size * 0.36, size * 0.64, size * 0.64),
        fill=(255, 255, 255, 255),
    )
    return img


def normalize(path: Path, size: int = 512) -> Image.Image:
    im = Image.open(path).convert("RGBA")
    # Fit into square canvas with white background for checkout clarity
    canvas = Image.new("RGBA", (size, size), (255, 255, 255, 255))
    im.thumbnail((size, size), Image.Resampling.LANCZOS)
    x = (size - im.width) // 2
    y = (size - im.height) // 2
    canvas.paste(im, (x, y), im)
    return canvas


def first_existing(names: list[str] | None) -> Path | None:
    if not names:
        return None
    for name in names:
        p = SRC / name
        if p.is_file() and p.stat().st_size > 500:
            return p
    return None


def main() -> None:
    ensure_dirs()
    for slug, names in SOURCES.items():
        if slug == "cash":
            img = make_cash_icon()
        else:
            src = first_existing(names)
            if src is None:
                print(f"MISSING {slug}")
                continue
            img = normalize(src)
            print(f"{slug} <- {src.name}")
        for out_dir in OUT_DIRS:
            dest = out_dir / f"{slug}.png"
            img.save(dest, format="PNG", optimize=True)
            print(f"  wrote {dest}")


if __name__ == "__main__":
    main()
