#!/usr/bin/env python3
"""Epey sitemap URL listesini CepKıyas katalog kaydına çevirir."""

from __future__ import annotations

import json
import os
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
URLS = ROOT / "data" / "epey-phone-urls.txt"
OUT = ROOT / "src" / "data" / "catalog.json"
MOBILE_OUT = ROOT / "mobile" / "assets" / "data" / "catalog.json"

BRANDS = [
    ("general-mobile", "General Mobile"),
    ("black-shark", "Black Shark"),
    ("turk-telekom", "Türk Telekom"),
    ("c5-mobile", "C5 Mobile"),
    ("bb-mobile", "BB Mobile"),
    ("smartphone-for-snapdragon-insiders", "Qualcomm"),
    ("google-pixel", "Google"),
    ("nothing-phone", "Nothing"),
    ("pocophone", "Poco"),
    ("oneplus", "OnePlus"),
    ("blackberry", "BlackBerry"),
    ("microsoft", "Microsoft"),
    ("motorola", "Motorola"),
    ("fairphone", "Fairphone"),
    ("blackview", "Blackview"),
    ("umidigi", "Umidigi"),
    ("elephone", "Elephone"),
    ("prestigio", "Prestigio"),
    ("vodafone", "Vodafone"),
    ("turkcell", "Turkcell"),
    ("teknosa", "Teknosa"),
    ("dijitsu", "Dijitsu"),
    ("gigabyte", "Gigabyte"),
    ("gigaset", "Gigaset"),
    ("essential", "Essential"),
    ("yotaphone", "YotaPhone"),
    ("samsung", "Samsung"),
    ("huawei", "Huawei"),
    ("xiaomi", "Xiaomi"),
    ("redmi", "Xiaomi"),
    ("honor", "Honor"),
    ("apple", "Apple"),
    ("oppo", "Oppo"),
    ("vivo", "vivo"),
    ("realme", "Realme"),
    ("infinix", "Infinix"),
    ("tecno", "Tecno"),
    ("nubia", "Nubia"),
    ("zte", "ZTE"),
    ("htc", "HTC"),
    ("poco", "Poco"),
    ("lenovo", "Lenovo"),
    ("sony", "Sony"),
    ("asus", "Asus"),
    ("meizu", "Meizu"),
    ("nokia", "Nokia"),
    ("reeder", "Reeder"),
    ("alcatel", "Alcatel"),
    ("casper", "Casper"),
    ("google", "Google"),
    ("hiking", "Hiking"),
    ("vestel", "Vestel"),
    ("tcl", "TCL"),
    ("omix", "Omix"),
    ("nothing", "Nothing"),
    ("doogee", "Doogee"),
    ("oukitel", "Oukitel"),
    ("ulefone", "Ulefone"),
    ("piranha", "Piranha"),
    ("quatro", "Quatro"),
    ("sunny", "Sunny"),
    ("neffos", "Neffos"),
    ("leeco", "LeEco"),
    ("mipo", "Mipo"),
    ("ovion", "Ovion"),
    ("fluo", "Fluo"),
    ("cat", "Cat"),
    ("lg", "LG"),
    ("cmf", "CMF"),
    ("itel", "itel"),
    ("moto", "Motorola"),
    ("narzo", "Realme"),
    ("axon", "ZTE"),
    ("sharp", "Sharp"),
    ("razer", "Razer"),
    ("philips", "Philips"),
    ("haier", "Haier"),
    ("wiko", "Wiko"),
    ("palm", "Palm"),
    ("zuk", "ZUK"),
    ("umi", "UMI"),
    ("tp", "TP-Link"),
    ("hp", "HP"),
    ("leica", "Leica"),
]

ACCENTS = {
    "Apple": "#8E8A83",
    "Samsung": "#5B6F86",
    "Xiaomi": "#F3A712",
    "Google": "#4285F4",
    "OnePlus": "#EB0029",
    "Nothing": "#D4FF00",
    "Honor": "#1A73E8",
    "Oppo": "#0066CC",
    "vivo": "#4154AF",
    "Poco": "#F4C430",
    "Huawei": "#CF0A2C",
    "Realme": "#FF6A00",
}

OFFICIAL_KEYS = {
    "apple-iphone-16-pro-max": "iphone-16-pro-max",
    "apple-iphone-16-pro": "iphone-16-pro",
    "apple-iphone-16": "iphone-16",
    "samsung-galaxy-s25-ultra": "galaxy-s25-ultra",
    "samsung-galaxy-s25": "galaxy-s25",
    "samsung-galaxy-z-fold6": "galaxy-z-fold6",
    "samsung-galaxy-a56": "galaxy-a56",
    "samsung-galaxy-a56-5g": "galaxy-a56",
    "xiaomi-15-ultra": "xiaomi-15-ultra",
    "xiaomi-15": "xiaomi-15",
    "xiaomi-redmi-note-14-pro-plus": "redmi-note-14-pro-plus",
    "redmi-note-14-pro-plus": "redmi-note-14-pro-plus",
    "google-pixel-9-pro-xl": "pixel-9-pro-xl",
    "google-pixel-9": "pixel-9",
    "oneplus-13": "oneplus-13",
    "nothing-phone-3": "nothing-phone-3",
    "honor-magic7-pro": "honor-magic7-pro",
    "oppo-find-x8-pro": "oppo-find-x8-pro",
    "vivo-x200-pro": "vivo-x200-pro",
    "poco-f7-ultra": "poco-f7-ultra",
    "huawei-pura-70-ultra": "huawei-pura-70-ultra",
    "realme-gt-7-pro": "realme-gt-7-pro",
}


def brand_of(slug: str) -> tuple[str, str]:
    for prefix, brand in BRANDS:
        if slug == prefix or slug.startswith(prefix + "-"):
            rest = slug[len(prefix) :].lstrip("-")
            return brand, rest or slug
    return slug.split("-")[0].title(), "-".join(slug.split("-")[1:]) or slug


def titleize(slug: str) -> str:
    parts = []
    for token in slug.split("-"):
        if token.upper() in {"GB", "TB", "5G", "4G", "LTE", "SE", "XL", "FE", "GT", "OS", "RAM"}:
            parts.append(token.upper())
        elif re.fullmatch(r"sm|cph|v\d+|nx\d+", token):
            parts.append(token.upper())
        elif token.isdigit():
            parts.append(token)
        else:
            parts.append(token[:1].upper() + token[1:])
    return " ".join(parts)


MIN_YEAR = 2016
MAX_YEAR = 2026
LEGACY = re.compile(
    r"iphone-[3-8](?![0-9])|galaxy-s[1-9](?![0-9])|galaxy-note-[1-9](?![0-9])|pixel-[1-5](?![0-9])"
)


def parse_year(slug: str, name: str) -> int:
    years = [int(y) for y in re.findall(r"(20(?:1[6-9]|2[0-6]))", slug)]
    if years:
        return years[-1]
    compact = slug.lower()
    for needle, year in (
        ("iphone-17", 2025),
        ("iphone-16", 2024),
        ("iphone-15", 2023),
        ("iphone-14", 2022),
        ("iphone-13", 2021),
        ("iphone-12", 2020),
        ("iphone-11", 2019),
        ("iphone-xr", 2018),
        ("iphone-xs", 2018),
        ("iphone-x", 2017),
        ("iphone-se-2022", 2022),
        ("iphone-se-2020", 2020),
        ("galaxy-s26", 2026),
        ("galaxy-s25", 2025),
        ("galaxy-s24", 2024),
        ("galaxy-s23", 2023),
        ("galaxy-s22", 2022),
        ("galaxy-s21", 2021),
        ("galaxy-s20", 2020),
        ("galaxy-note-20", 2020),
        ("galaxy-note-10", 2019),
        ("pixel-9", 2024),
        ("pixel-8", 2023),
        ("pixel-7", 2022),
        ("pixel-6", 2021),
        ("redmi-note-14", 2024),
        ("redmi-note-13", 2023),
    ):
        if needle in compact:
            return year
    return 2020


def in_catalog_window(slug: str, year: int) -> bool:
    if year < MIN_YEAR or year > MAX_YEAR:
        return False
    if LEGACY.search(slug.lower()) and not re.search(r"20(?:1[6-9]|2[0-6])", slug):
        return False
    return True


def parse_storage(slug: str) -> int:
    if re.search(r"(^|-)2tb(-|$)", slug):
        return 2048
    if re.search(r"(^|-)1tb(-|$)", slug):
        return 1024
    match = re.search(r"(^|-)(32|64|128|256|512)gb(-|$)", slug)
    return int(match.group(2)) if match else 0


def parse_ram(slug: str) -> int:
    match = re.search(r"(^|-)(3|4|6|8|12|16|18|24)-?gb(-|$)", slug)
    if match and "tb" not in match.group(0):
        value = int(match.group(2))
        if value <= 24:
            return value
    return 0


def os_family(brand: str) -> tuple[str, str]:
    if brand == "Apple":
        return "iOS", "iOS"
    if brand == "Huawei":
        return "HarmonyOS", "HarmonyOS / EMUI"
    return "Android", "Android"


def main() -> None:
    urls = [line.strip() for line in URLS.read_text().splitlines() if line.strip()]
    rows = []
    seen = set()
    for url in urls:
        slug = url.rsplit("/", 1)[-1].replace(".html", "")
        if slug in seen:
            continue
        seen.add(slug)
        brand, rest = brand_of(slug)
        name = titleize(rest)
        if brand == "Apple" and not name.lower().startswith("iphone"):
            name = f"iPhone {name}" if name else "iPhone"
        year = parse_year(slug, name)
        ram = parse_ram(slug)
        storage = parse_storage(slug)
        family, os_name = os_family(brand)
        foldable = any(key in slug for key in ("fold", "flip", "razr", "mate-x", "find-n", "magic-v", "mix-fold"))
        if not in_catalog_window(slug, year):
            continue
        rows.append(
            {
                "id": slug,
                "slug": slug,
                "brand": brand,
                "name": name,
                "fullName": f"{brand} {name}",
                "year": year,
                "priceTRY": 0,
                "popularity": max(12, min(68, 18 + (year - 2016) * 4)),
                "os": os_name,
                "osFamily": family,
                "accent": ACCENTS.get(brand, "#6EE7B7"),
                "sourceUrl": url,
                "officialId": OFFICIAL_KEYS.get(slug),
                "ram": ram,
                "storage": storage,
                "foldable": foldable,
                "network5g": year >= 2021 and brand != "Huawei",
            }
        )

    rows.sort(key=lambda row: (-row["popularity"], row["fullName"]))
    payload = json.dumps(rows, ensure_ascii=False, separators=(",", ":"))
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(payload)
    MOBILE_OUT.parent.mkdir(parents=True, exist_ok=True)
    MOBILE_OUT.write_text(payload)
    brands = sorted({row["brand"] for row in rows})
    print(f"wrote {len(rows)} models, {len(brands)} brands -> {OUT}")
    print("brands:", ", ".join(brands))


if __name__ == "__main__":
    main()
