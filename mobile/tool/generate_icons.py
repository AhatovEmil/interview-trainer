"""Генератор иконок приложения.

Иконка совпадает с эмблемой на экране входа: тёмный квадрат и молния — тот же
знак, что видит человек при первом запуске. Рисуется здесь, а не берётся
картинкой из репозитория, чтобы её можно было переделать одной правкой
координат и перегенерировать все плотности разом.

Внешних зависимостей нет намеренно: Pillow на машине разработчика может не
стоять, а PNG собирается из zlib, который есть всегда.

    python mobile/tool/generate_icons.py
"""

from __future__ import annotations

import struct
import zlib
from pathlib import Path

# Палитра совпадает с AppColors: чернила и поверхность.
INK = (12, 16, 23, 255)
SURFACE = (255, 255, 255, 255)

# Молния в нормализованных координатах. Контур обходится по часовой стрелке:
# верхняя точка, спуск влево, полка, нижнее остриё, подъём вправо, полка.
BOLT = (
    (0.58, 0.06),
    (0.25, 0.55),
    (0.45, 0.55),
    (0.40, 0.94),
    (0.75, 0.44),
    (0.55, 0.44),
)

# Сглаживание: считаем в несколько раз крупнее и усредняем.
SUPERSAMPLE = 4

# Плотности Android для обычной иконки.
MIPMAPS = {
    "mdpi": 48,
    "hdpi": 72,
    "xhdpi": 96,
    "xxhdpi": 144,
    "xxxhdpi": 192,
}

# Адаптивная иконка обрезается системой под форму устройства, и гарантированно
# видна только внутренняя часть. Поэтому слой переднего плана крупнее, а сам
# знак занимает меньшую долю холста.
ADAPTIVE_SIZE = 432
ADAPTIVE_SAFE = 0.62

ROOT = Path(__file__).resolve().parents[1]
RES = ROOT / "android" / "app" / "src" / "main" / "res"
STORE = ROOT.parent / "store" / "android"


def _inside(polygon: tuple[tuple[float, float], ...], x: float, y: float) -> bool:
    """Точка внутри многоугольника — по числу пересечений луча."""
    inside = False
    count = len(polygon)
    for index in range(count):
        x1, y1 = polygon[index]
        x2, y2 = polygon[(index + 1) % count]
        if (y1 > y) != (y2 > y):
            cross = x1 + (y - y1) / (y2 - y1) * (x2 - x1)
            if x < cross:
                inside = not inside
    return inside


def _rounded(x: float, y: float, radius: float) -> bool:
    """Скруглённый квадрат.

    Точка вне фигуры только в углах: если она попала в угловую зону, проверяем
    расстояние до центра скругления. Везде остальное — внутри.
    """
    if radius <= 0:
        return True
    corner_x = radius if x < radius else (1 - radius if x > 1 - radius else None)
    corner_y = radius if y < radius else (1 - radius if y > 1 - radius else None)
    if corner_x is None or corner_y is None:
        return True
    dx = x - corner_x
    dy = y - corner_y
    return dx * dx + dy * dy <= radius * radius


def _blend(base: tuple[int, int, int, int], top: tuple[int, int, int, int],
           alpha: float) -> tuple[int, int, int, int]:
    return tuple(round(b + (t - b) * alpha) for b, t in zip(base, top))  # type: ignore[return-value]


def _render(size: int, *, background: bool, scale: float, radius: float) -> bytes:
    """Пиксели RGBA. background=False — прозрачный фон для адаптивного слоя."""
    rows: list[bytes] = []
    step = 1.0 / SUPERSAMPLE
    offset = (1.0 - scale) / 2

    for py in range(size):
        row = bytearray()
        for px in range(size):
            hits_bolt = 0
            hits_plate = 0
            for sy in range(SUPERSAMPLE):
                for sx in range(SUPERSAMPLE):
                    x = (px + (sx + 0.5) * step) / size
                    y = (py + (sy + 0.5) * step) / size
                    if background and _rounded(x, y, radius):
                        hits_plate += 1
                    bolt_x = (x - offset) / scale
                    bolt_y = (y - offset) / scale
                    if 0 <= bolt_x <= 1 and 0 <= bolt_y <= 1 and _inside(BOLT, bolt_x, bolt_y):
                        hits_bolt += 1

            total = SUPERSAMPLE * SUPERSAMPLE
            pixel = (0, 0, 0, 0)
            if background:
                pixel = _blend(pixel, INK, hits_plate / total)
            pixel = _blend(pixel, SURFACE, hits_bolt / total)
            row.extend(pixel)
        rows.append(bytes(row))
    return b"".join(b"\x00" + row for row in rows)


def _png(size: int, raw: bytes) -> bytes:
    def chunk(tag: bytes, payload: bytes) -> bytes:
        body = tag + payload
        return struct.pack(">I", len(payload)) + body + struct.pack(">I", zlib.crc32(body))

    header = struct.pack(">IIBBBBB", size, size, 8, 6, 0, 0, 0)
    return (
        b"\x89PNG\r\n\x1a\n"
        + chunk(b"IHDR", header)
        + chunk(b"IDAT", zlib.compress(raw, 9))
        + chunk(b"IEND", b"")
    )


def write(path: Path, size: int, *, background: bool, scale: float, radius: float) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(_png(size, _render(size, background=background, scale=scale, radius=radius)))
    print(f"  {path.relative_to(ROOT.parent)}  {size}x{size}")


def main() -> None:
    print("Иконки приложения:")
    for density, size in MIPMAPS.items():
        write(
            RES / f"mipmap-{density}" / "ic_launcher.png",
            size,
            background=True,
            scale=0.62,
            radius=0.22,
        )

    print("Адаптивная иконка:")
    write(
        RES / "mipmap-xxxhdpi" / "ic_launcher_foreground.png",
        ADAPTIVE_SIZE,
        background=False,
        scale=ADAPTIVE_SAFE * 0.62,
        radius=0.0,
    )

    print("Для карточки в магазине:")
    write(STORE / "icon-512.png", 512, background=True, scale=0.62, radius=0.22)


if __name__ == "__main__":
    main()
