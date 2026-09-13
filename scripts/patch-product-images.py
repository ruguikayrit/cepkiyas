#!/usr/bin/env python3
"""SVG yerine Wikipedia/Commons PNG görselleri ve resmi kaynak URL'leri yazar."""

from __future__ import annotations

import json
import re
import urllib.parse
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OVERLAY = ROOT / "mobile" / "assets" / "data" / "specs-overlay.json"
UA = "TeknoKiyas/1.0 (catalog enrichment)"

OFFICIAL = {
    "apple": "https://www.apple.com/iphone/",
    "samsung": "https://www.samsung.com/",
    "google": "https://store.google.com/product/pixel_phone_specs",
    "xiaomi": "https://www.mi.com/",
    "oneplus": "https://www.oneplus.com/",
    "honor": "https://www.honor.com/",
    "oppo": "https://www.oppo.com/",
    "vivo": "https://www.vivo.com/",
    "realme": "https://www.realme.com/",
    "motorola": "https://www.motorola.com/",
    "nothing": "https://nothing.tech/",
    "huawei": "https://consumer.huawei.com/",
}

WIKI_TITLES = {
    "apple-iphone-17": "IPhone 17",
    "apple-iphone-17-pro": "IPhone 17 Pro",
    "apple-iphone-17-pro-max": "IPhone 17 Pro Max",
    "apple-iphone-16": "IPhone 16",
    "apple-iphone-16-pro": "IPhone 16 Pro",
    "apple-iphone-16-pro-max": "IPhone 16 Pro Max",
    "apple-iphone-15": "IPhone 15",
    "apple-iphone-15-pro": "IPhone 15 Pro",
    "apple-iphone-14": "IPhone 14",
    "apple-iphone-13": "IPhone 13",
    "samsung-galaxy-s25": "Samsung Galaxy S25",
    "samsung-galaxy-s25-ultra": "Samsung Galaxy S25 Ultra",
    "samsung-galaxy-s26": "Samsung Galaxy S26",
}


def get_json(url: str) -> dict:
    req = urllib.request.Request(url, headers={"User-Agent": UA, "Accept": "application/json"})
    with urllib.request.urlopen(req, timeout=35) as resp:
        return json.loads(resp.read().decode())


def wiki_image(title: str) -> str:
    quoted = urllib.parse.quote(title.replace(" ", "_"))
    data = get_json(f"https://en.wikipedia.org/api/rest_v1/page/summary/{quoted}")
    for key in ("originalimage", "thumbnail"):
        block = data.get(key) or {}
        url = block.get("source", "")
        if url and ".svg" not in url.lower():
            return url
    return ""


def brand_of(slug: str) -> str:
    for prefix in OFFICIAL:
        if slug.startswith(prefix) or f"-{prefix}-" in slug:
            return prefix
    if slug.startswith("apple-"):
        return "apple"
    if slug.startswith("samsung-"):
        return "samsung"
    if slug.startswith("google-"):
        return "google"
    return ""


def main() -> None:
    overlay = json.loads(OVERLAY.read_text())
    updated = 0
    for slug, entry in overlay.items():
        if not isinstance(entry, dict):
            continue
        img = entry.get("image", "")
        if not img or ".svg" in img.lower():
            base = slug
            for suffix in ("-512gb", "-256gb", "-128gb", "-1tb", "-2tb"):
                if base.endswith(suffix):
                    base = base[: -len(suffix)]
            title = WIKI_TITLES.get(base)
            if title:
                png = wiki_image(title)
                if png:
                    entry["image"] = png
                    updated += 1
        b = brand_of(slug)
        if b and OFFICIAL.get(b):
            entry["sourceUrl"] = OFFICIAL[b]
    OVERLAY.write_text(json.dumps(overlay, ensure_ascii=False, indent=2))
    src = ROOT / "src" / "data" / "specs-overlay.json"
    src.write_text(OVERLAY.read_text())
    print(f"patched images/urls, image fixes ~{updated}, entries {len(overlay)}")


if __name__ == "__main__":
    main()
