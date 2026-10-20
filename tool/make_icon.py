"""Draw the Madplan app icon: a retro sunset behind a bowl of noodles.

Usage: python tool/make_icon.py   (requires Pillow)
Writes assets/icon/icon.png and assets/icon/foreground.png.
"""

import math
from pathlib import Path

from PIL import Image, ImageDraw

SIZE = 1024
SUPERSAMPLE = 4
MOTIF_BOX = 1000
LEGACY_SCALE = 0.9
ADAPTIVE_SCALE = 0.64

BURNT_ORANGE = (190, 81, 3, 255)
SUN = (255, 206, 27, 255)
TEAL = (6, 148, 148, 255)
RUST = (183, 65, 14, 255)
CREAM = (255, 247, 232, 255)
NOODLE = (255, 236, 180, 255)
NOODLE_SHADE = (226, 160, 50, 255)
CLEAR = (0, 0, 0, 0)

SUN_CENTER = (500, 430)
SUN_RADIUS = 300
SUN_STRIPES = ((395, 14), (445, 24), (500, 36))
RIM = (110, 535, 890, 580)
BOWL = (120, 260, 880, 860)
BOWL_BAND = (150, 640, 850, 672)
FOOT = (390, 840, 610, 890)
HEAP_CENTER = (500, 548)
HEAP_RADII = (320, 125)
STRAND_ROWS = (465, 497, 529)
STRAND_INSET = 30
STRAND_WIDTH = 12
STRAND_AMPLITUDE = 10
STRAND_WAVELENGTH = 70
STRAND_STEP = 4
CHOPSTICKS = (((560, 500), (870, 165)), ((615, 510), (915, 200)))
CHOPSTICK_WIDTH = 20
OUT = Path(__file__).resolve().parent.parent / "assets" / "icon"


def to_canvas(scale: float):
    canvas = SIZE * SUPERSAMPLE
    factor = canvas * scale / MOTIF_BOX
    offset = (canvas - MOTIF_BOX * factor) / 2

    def point(x: float, y: float) -> tuple[float, float]:
        return offset + x * factor, offset + y * factor

    def box(x0: float, y0: float, x1: float, y1: float) -> list[float]:
        return [*point(x0, y0), *point(x1, y1)]

    return point, box, factor


def strand(y: float, phase: float) -> list[tuple[float, float]]:
    cx, cy = HEAP_CENTER
    rx, ry = HEAP_RADII
    half = rx * math.sqrt(max(0.0, 1 - ((cy - y) / ry) ** 2)) - STRAND_INSET
    return [
        (x, y + STRAND_AMPLITUDE * math.sin(2 * math.pi * x / STRAND_WAVELENGTH + phase))
        for x in range(int(cx - half), int(cx + half), STRAND_STEP)
    ]


def draw_noodles(draw: ImageDraw.ImageDraw, point, box, factor: float) -> None:
    for start, end in CHOPSTICKS:
        draw.line([point(*start), point(*end)], fill=RUST, width=round(CHOPSTICK_WIDTH * factor))
    cx, cy = HEAP_CENTER
    rx, ry = HEAP_RADII
    draw.pieslice(box(cx - rx, cy - ry, cx + rx, cy + ry), start=180, end=360, fill=NOODLE)
    for index, y in enumerate(STRAND_ROWS):
        draw.line(
            [point(*p) for p in strand(y, phase=index * math.pi / 2)],
            fill=NOODLE_SHADE,
            width=round(STRAND_WIDTH * factor),
            joint="curve",
        )


def draw_motif(background: tuple[int, int, int, int], scale: float) -> Image.Image:
    canvas = SIZE * SUPERSAMPLE
    point, box, factor = to_canvas(scale)

    sun = Image.new("RGBA", (canvas, canvas), CLEAR)
    sun_draw = ImageDraw.Draw(sun)
    cx, cy = SUN_CENTER
    sun_draw.ellipse(
        box(cx - SUN_RADIUS, cy - SUN_RADIUS, cx + SUN_RADIUS, cy + SUN_RADIUS),
        fill=SUN,
    )
    for top, height in SUN_STRIPES:
        sun_draw.rectangle(box(0, top, MOTIF_BOX, top + height), fill=CLEAR)

    image = Image.new("RGBA", (canvas, canvas), background)
    image.alpha_composite(sun)

    draw = ImageDraw.Draw(image)
    draw_noodles(draw, point, box, factor)
    draw.pieslice(box(*BOWL), start=0, end=180, fill=TEAL)
    draw.rectangle(box(*BOWL_BAND), fill=RUST)
    draw.rounded_rectangle(box(*FOOT), radius=20 * factor, fill=TEAL)
    draw.rounded_rectangle(box(*RIM), radius=22 * factor, fill=CREAM)

    return image.resize((SIZE, SIZE), Image.Resampling.LANCZOS)


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    draw_motif(BURNT_ORANGE, LEGACY_SCALE).save(OUT / "icon.png")
    draw_motif(CLEAR, ADAPTIVE_SCALE).save(OUT / "foreground.png")
    print(f"Wrote icons to {OUT}")


if __name__ == "__main__":
    main()
