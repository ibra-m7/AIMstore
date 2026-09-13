"""Regenerate phone launcher icons: full logo + white/blue blended background."""
from __future__ import annotations

import math
import re
from pathlib import Path

from PIL import Image

REPO = Path(__file__).resolve().parents[2]
MOBILE = REPO / "mobile"
COURIER = REPO / "courier"

# Brand blues
BLUE = (0, 51, 153)  # #003399
BLUE_SOFT = (232, 238, 248)  # #E8EEF8 primarySurface
WHITE = (255, 255, 255)


def load_logo() -> Image.Image:
    candidates = [
        MOBILE / "assets/images/logo.png",
        REPO / "backend/public/images/logo.png",
        REPO / "backend/public/brand-logo.jpg",
        MOBILE / "assets/images/home_logo.png",
        REPO / "homelogo.png",
    ]
    for path in candidates:
        if path.exists():
            img = Image.open(path).convert("RGBA")
            print(f"logo source: {path} {img.size}")
            return img
    raise SystemExit("no logo source found")


def white_blue_gradient(size: int) -> Image.Image:
    """Radial blend: white center → soft blue mid → brand blue edge tint."""
    img = Image.new("RGBA", (size, size))
    px = img.load()
    cx = cy = (size - 1) / 2.0
    max_r = math.hypot(cx, cy)
    for y in range(size):
        for x in range(size):
            t = math.hypot(x - cx, y - cy) / max_r
            t = min(1.0, t ** 0.92)
            if t < 0.45:
                u = t / 0.45
                r = int(WHITE[0] * (1 - u) + BLUE_SOFT[0] * u)
                g = int(WHITE[1] * (1 - u) + BLUE_SOFT[1] * u)
                b = int(WHITE[2] * (1 - u) + BLUE_SOFT[2] * u)
            else:
                u = (t - 0.45) / 0.55
                # soft blue → slightly deeper blue wash (not solid dark)
                deep = (
                    int(BLUE_SOFT[0] * 0.55 + BLUE[0] * 0.45),
                    int(BLUE_SOFT[1] * 0.55 + BLUE[1] * 0.45),
                    int(BLUE_SOFT[2] * 0.55 + BLUE[2] * 0.45),
                )
                r = int(BLUE_SOFT[0] * (1 - u) + deep[0] * u)
                g = int(BLUE_SOFT[1] * (1 - u) + deep[1] * u)
                b = int(BLUE_SOFT[2] * (1 - u) + deep[2] * u)
            px[x, y] = (r, g, b, 255)
    return img


def fit_logo(
    logo: Image.Image,
    size: int,
    *,
    pad_ratio: float = 0.18,
    bg: Image.Image | tuple[int, int, int, int] | None = None,
) -> Image.Image:
    if isinstance(bg, Image.Image):
        canvas = bg.resize((size, size), Image.Resampling.LANCZOS).convert("RGBA")
    elif bg is None:
        canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    else:
        canvas = Image.new("RGBA", (size, size), bg)

    inner = max(1, int(size * (1 - 2 * pad_ratio)))
    scale = min(inner / logo.width, inner / logo.height)
    nw = max(1, int(round(logo.width * scale)))
    nh = max(1, int(round(logo.height * scale)))
    scaled = logo.resize((nw, nh), Image.Resampling.LANCZOS)
    canvas.alpha_composite(scaled, ((size - nw) // 2, (size - nh) // 2))
    return canvas


def write_android(app: str, logo: Image.Image, gradient: Image.Image) -> None:
    res = REPO / app / "android/app/src/main/res"
    if not res.exists():
        print(f"skip missing res: {res}")
        return

    mip = {
        "mipmap-mdpi": 48,
        "mipmap-hdpi": 72,
        "mipmap-xhdpi": 96,
        "mipmap-xxhdpi": 144,
        "mipmap-xxxhdpi": 192,
    }
    # Adaptive foreground layers (larger canvas; safe zone ~66%).
    draw = {
        "drawable-mdpi": 108,
        "drawable-hdpi": 162,
        "drawable-xhdpi": 216,
        "drawable-xxhdpi": 324,
        "drawable-xxxhdpi": 432,
    }

    for folder, size in mip.items():
        out = res / folder
        out.mkdir(parents=True, exist_ok=True)
        full = fit_logo(logo, size, pad_ratio=0.14, bg=gradient)
        # Transparent FG for adaptive: more padding so mask doesn't crop.
        fg = fit_logo(logo, size, pad_ratio=0.20, bg=(0, 0, 0, 0))
        full.save(out / "ic_launcher.png")
        full.save(out / "ic_launcher_round.png")
        fg.save(out / "ic_launcher_foreground.png")

    for folder, size in draw.items():
        out = res / folder
        out.mkdir(parents=True, exist_ok=True)
        fit_logo(logo, size, pad_ratio=0.22, bg=(0, 0, 0, 0)).save(
            out / "ic_launcher_foreground.png"
        )

    colors = res / "values/colors.xml"
    if colors.exists():
        text = colors.read_text(encoding="utf-8")
        text = re.sub(
            r'(<color name="ic_launcher_background">)[^<]+(</color>)',
            r"\1#E8EEF8\2",
            text,
        )
        colors.write_text(text, encoding="utf-8")

    adaptive = res / "mipmap-anydpi-v26/ic_launcher.xml"
    if adaptive.exists():
        adaptive.write_text(
            """<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
  <background android:drawable="@color/ic_launcher_background"/>
  <foreground>
      <inset
          android:drawable="@drawable/ic_launcher_foreground"
          android:inset="12%" />
  </foreground>
</adaptive-icon>
""",
            encoding="utf-8",
        )
    print(f"android icons written for {app}")


def write_ios(logo: Image.Image, gradient: Image.Image) -> None:
    ios_set = MOBILE / "ios/Runner/Assets.xcassets/AppIcon.appiconset"
    if not ios_set.exists():
        print("skip iOS AppIcon set")
        return
    # Common Flutter AppIcon sizes present in Contents.json
    sizes = [
        ("Icon-App-20x20@1x.png", 20),
        ("Icon-App-20x20@2x.png", 40),
        ("Icon-App-20x20@3x.png", 60),
        ("Icon-App-29x29@1x.png", 29),
        ("Icon-App-29x29@2x.png", 58),
        ("Icon-App-29x29@3x.png", 87),
        ("Icon-App-40x40@1x.png", 40),
        ("Icon-App-40x40@2x.png", 80),
        ("Icon-App-40x40@3x.png", 120),
        ("Icon-App-50x50@1x.png", 50),
        ("Icon-App-50x50@2x.png", 100),
        ("Icon-App-57x57@1x.png", 57),
        ("Icon-App-57x57@2x.png", 114),
        ("Icon-App-60x60@2x.png", 120),
        ("Icon-App-60x60@3x.png", 180),
        ("Icon-App-72x72@1x.png", 72),
        ("Icon-App-72x72@2x.png", 144),
        ("Icon-App-76x76@1x.png", 76),
        ("Icon-App-76x76@2x.png", 152),
        ("Icon-App-83.5x83.5@2x.png", 167),
        ("Icon-App-1024x1024@1x.png", 1024),
    ]
    for name, size in sizes:
        path = ios_set / name
        if path.exists() or name.endswith("1024x1024@1x.png"):
            fit_logo(logo, size, pad_ratio=0.14, bg=gradient).convert("RGB").save(
                path, format="PNG"
            )
    print("iOS icons written")


def main() -> None:
    logo = load_logo()
    # Soften any residual near-white outer canvas without killing white ink.
    gradient = white_blue_gradient(1024)

    icon1024 = fit_logo(logo, 1024, pad_ratio=0.14, bg=gradient)
    (MOBILE / "assets/images").mkdir(parents=True, exist_ok=True)
    icon1024.save(MOBILE / "assets/images/app_icon.png")
    courier_assets = COURIER / "assets/images"
    if courier_assets.exists() or COURIER.exists():
        courier_assets.mkdir(parents=True, exist_ok=True)
        icon1024.save(courier_assets / "app_icon.png")

    write_android("mobile", logo, gradient)
    if (COURIER / "android/app/src/main/res").exists():
        write_android("courier", logo, gradient)

    write_ios(logo, gradient)

    fav = REPO / "backend/public"
    if fav.exists():
        fit_logo(logo, 192, pad_ratio=0.12, bg=gradient).save(fav / "favicon.png")
        fit_logo(logo, 32, pad_ratio=0.12, bg=gradient).save(
            fav / "favicon.ico", format="ICO", sizes=[(32, 32)]
        )

    print("done: full logo + white/blue blended icon background")


if __name__ == "__main__":
    main()
