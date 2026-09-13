#!/usr/bin/env python3
"""Wikidata + Wikipedia + Commons ile katalog özellik ve ön görünüş görsellerini doldur."""

from __future__ import annotations

import json
import re
import time
import unicodedata
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CATALOG = ROOT / "src" / "data" / "catalog.json"
OUT = ROOT / "src" / "data" / "specs-overlay.json"
CACHE = ROOT / "data" / "external"
UA = "CepKiyasCatalog/1.0 (phone comparison; research)"

BAD_IMAGE = (
    "logo",
    "wordmark",
    "icon",
    "2160p",
    "vp9",
    "youtube",
    "screenshot",
    "boxart",
    "box-art",
    "unboxing",
)

MAJOR = {
    "samsung",
    "apple",
    "xiaomi",
    "huawei",
    "honor",
    "oppo",
    "vivo",
    "google",
    "realme",
    "oneplus",
    "motorola",
    "nokia",
    "sony",
    "asus",
    "nothing",
    "poco",
    "tecno",
    "infinix",
    "htc",
    "lg",
    "meizu",
    "lenovo",
    "zte",
    "nubia",
    "tcl",
}


def get_json(url: str, timeout: int = 60) -> dict | list:
    req = urllib.request.Request(url, headers={"User-Agent": UA, "Accept": "application/json"})
    with urllib.request.urlopen(req, timeout=timeout) as resp:
        return json.loads(resp.read().decode("utf-8"))


def norm(text: str) -> str:
    text = unicodedata.normalize("NFKD", text).encode("ascii", "ignore").decode()
    text = text.lower()
    text = text.replace("&", " and ")
    for token in ("smartphone", "smart phone", "mobile phone", "5g", "4g", "lte", "edition"):
        text = text.replace(token, " ")
    return re.sub(r"[^a-z0-9]+", "", text)


def strip_storage(slug: str) -> str:
    slug = re.sub(r"-(32|64|128|256|512)gb$", "", slug)
    return re.sub(r"-(1|2)tb$", "", slug)


def image_ok(url: str) -> bool:
    low = urllib.parse.unquote(url).lower()
    return bool(url) and not any(bad in low for bad in BAD_IMAGE)


def commons_thumb(url: str, width: int = 640) -> str:
    if "Special:FilePath" in url:
        return url.replace("http://", "https://") + ("" if "width=" in url else f"?width={width}")
    if "upload.wikimedia.org" in url or "thumb.wikimedia.org" in url:
        return url
    return url


def wikidata_index() -> list[dict]:
    CACHE.mkdir(parents=True, exist_ok=True)
    cache_path = CACHE / "wikidata-smartphones.json"
    if cache_path.exists() and cache_path.stat().st_size > 1000:
        return json.loads(cache_path.read_text())

    rows = []
    seen = set()
    for klass in ("Q19723451", "Q22645"):
        offset = 0
        while True:
            query = f"""
            SELECT ?item ?itemLabel ?brandLabel ?image WHERE {{
              ?item wdt:P31 wd:{klass}.
              OPTIONAL {{ ?item wdt:P176 ?brand. }}
              OPTIONAL {{ ?item wdt:P18 ?image. }}
              SERVICE wikibase:label {{ bd:serviceParam wikibase:language "en,tr". }}
            }}
            LIMIT 500 OFFSET {offset}
            """
            url = "https://query.wikidata.org/sparql?" + urllib.parse.urlencode({"query": query, "format": "json"})
            data = get_json(url, timeout=80)
            binds = data["results"]["bindings"]
            if not binds:
                break
            for bind in binds:
                label = bind.get("itemLabel", {}).get("value", "")
                qid = bind["item"]["value"].rsplit("/", 1)[-1]
                if not label or qid in seen:
                    continue
                if label.startswith("Q") and label[1:].isdigit():
                    continue
                seen.add(qid)
                rows.append(
                    {
                        "qid": qid,
                        "label": label,
                        "brand": bind.get("brandLabel", {}).get("value", ""),
                        "image": bind.get("image", {}).get("value", ""),
                        "enwiki": "",
                        "trwiki": "",
                    }
                )
            print(f"  wikidata {klass} offset {offset}: +{len(binds)} total {len(rows)}")
            offset += 500
            if len(binds) < 500:
                break
            time.sleep(0.4)
    cache_path.write_text(json.dumps(rows, ensure_ascii=False))
    return rows


def wiki_summary(title: str, lang: str) -> dict:
    quoted = urllib.parse.quote(title.replace(" ", "_"))
    url = f"https://{lang}.wikipedia.org/api/rest_v1/page/summary/{quoted}"
    try:
        return get_json(url, timeout=25)  # type: ignore[return-value]
    except Exception:
        return {}


def wiki_search(query: str, lang: str) -> str:
    url = (
        f"https://{lang}.wikipedia.org/w/api.php?"
        + urllib.parse.urlencode(
            {
                "action": "query",
                "list": "search",
                "srsearch": query,
                "srlimit": 5,
                "format": "json",
            }
        )
    )
    try:
        data = get_json(url, timeout=25)
        hits = data.get("query", {}).get("search", [])
        qn = norm(query)
        for hit in hits:
            title = hit.get("title", "")
            tn = norm(title)
            if qn and (qn in tn or tn in qn) and "list of" not in title.lower():
                return title
        return hits[0]["title"] if hits else ""
    except Exception:
        return ""


def wiki_infobox(title: str, lang: str) -> str:
    url = (
        f"https://{lang}.wikipedia.org/w/api.php?"
        + urllib.parse.urlencode(
            {
                "action": "parse",
                "page": title,
                "prop": "wikitext",
                "section": 0,
                "format": "json",
            }
        )
    )
    try:
        data = get_json(url, timeout=30)
        return data.get("parse", {}).get("wikitext", {}).get("*", "")
    except Exception:
        return ""


def first_number(pattern: str, text: str) -> float | None:
    match = re.search(pattern, text, re.I)
    if not match:
        return None
    try:
        return float(match.group(1).replace(",", "."))
    except ValueError:
        return None


def parse_infobox(wikitext: str, model_hint: str) -> dict:
    out: dict = {}
    if not wikitext:
        return out
    hint = norm(model_hint)
    window = wikitext
    if hint and hint in norm(wikitext):
        # Keep a slice around the model name so series infoboxes pick the right variant.
        idx = norm(wikitext).find(hint)
        if idx > 0:
            raw_idx = max(0, wikitext.lower().find(model_hint.split()[-1].lower()))
            window = wikitext[max(0, raw_idx - 400) : raw_idx + 1800]

    size = first_number(r"([0-9]{1,2}\.[0-9])\s*(?:in|inch|''|\")", window)
    if not size:
        size = first_number(r"convert\|([0-9]{1,2}\.[0-9])\|in", window)
    hz = first_number(r"([6-9]0|[1-4][0-9]0)\s*Hz", window)
    bright = first_number(r"([0-9]{3,5})\s*nits", window)
    height = first_number(r"H:\s*\{\{convert\|([0-9]{2,3}(?:\.[0-9])?)\|mm", window) or first_number(
        r"([0-9]{3}(?:\.[0-9])?)\s*mm.*[x×]", window
    )
    width = first_number(r"W:\s*\{\{convert\|([0-9]{2,3}(?:\.[0-9])?)\|mm", window)
    thick = first_number(r"D:\s*\{\{convert\|([0-9](?:\.[0-9])?)\|mm", window) or first_number(
        r"\{\{convert\|([5-9](?:\.[0-9])?)\|mm", window
    )
    weight = first_number(r"([0-9]{2,3}(?:\.[0-9])?)\s*g\b", window)
    mah = first_number(r"([1-9][0-9]{3,4})\s*mAh", window)
    watt = first_number(r"([1-9][0-9]{0,2})\s*W", window)
    ram = first_number(r"\b([3-9]|1[0-8]|24)\s*GB(?:\s*RAM)?", window)
    storage = first_number(r"\b(32|64|128|256|512)\s*GB(?!\s*RAM)", window)
    chip = re.search(r"(Snapdragon[^|<,\n]+|Dimensity[^|<,\n]+|Apple A[0-9]{2}[^|<,\n]*|Kirin[^|<,\n]+|Exynos[^|<,\n]+|Tensor[^|<,\n]+)", window)
    ip = re.search(r"\bIP[0-9]{2}[A-Z]?\b", window)
    cam = re.search(r"\b([0-9]{2,3})\s*MP\b", window)
    os_match = re.search(r"\| *os *= *([^\n]+)", wikitext, re.I)
    disp_type = re.search(r"(AMOLED|OLED|LTPO|IPS|Super Retina|Dynamic AMOLED)[^|\n]*", window, re.I)

    if size:
        out["displaySize"] = size
    if hz:
        out["refreshRate"] = int(hz)
    if bright:
        out["brightness"] = int(bright)
    if height:
        out["height"] = height
    if width:
        out["width"] = width
    if thick:
        out["thickness"] = thick
    if weight and 80 < weight < 400:
        out["weight"] = int(round(weight))
    if mah and 1500 < mah < 12000:
        out["capacity"] = int(mah)
    if watt and watt <= 240:
        out["wiredWatt"] = int(watt)
    if ram:
        out["ram"] = int(ram)
    if storage:
        out["storage"] = int(storage)
    if chip:
        out["chipset"] = re.sub(r"\[\[|\]\]", "", chip.group(1)).strip(" .;")
    if ip:
        out["ipRating"] = ip.group(0)
    if cam:
        out["mainMp"] = int(cam.group(1))
    if os_match:
        os_text = re.sub(r"\[\[(?:[^|\]]*\|)?([^\]]+)\]\]", r"\1", os_match.group(1))
        os_text = re.sub(r"<[^>]+>", "", os_text).strip()
        if os_text:
            out["os"] = os_text[:80]
    if disp_type:
        out["displayType"] = disp_type.group(0).strip()[:60]
    if "5G" in window or "5G" in wikitext:
        out["network5g"] = True
    return out


def pick_image(wd_image: str, summary: dict) -> str:
    candidates = []
    original = (summary.get("originalimage") or {}).get("source") or ""
    thumb = (summary.get("thumbnail") or {}).get("source") or ""
    if original:
        candidates.append(original)
    if thumb:
        candidates.append(thumb)
    if wd_image:
        candidates.append(commons_thumb(wd_image))
    for url in candidates:
        if image_ok(url):
            return url
    return ""


def best_match(row: dict, index: list[dict]) -> dict | None:
    keys = [
        norm(f"{row['brand']} {row['name']}"),
        norm(row["fullName"]),
        norm(row["name"]),
    ]
    keys = [k for k in keys if len(k) > 4]
    brand_n = norm(row["brand"])
    scored: list[tuple[int, dict]] = []
    for item in index:
        label_n = norm(f"{item.get('brand','')} {item['label']}")
        only = norm(item["label"])
        for key in keys:
            if key == only or key == label_n:
                return item
            if key in only or only in key:
                bonus = 2 if brand_n and brand_n in norm(item.get("brand", "") + item["label"]) else 0
                scored.append((len(key) + bonus, item))
    if not scored:
        return None
    scored.sort(key=lambda pair: pair[0], reverse=True)
    return scored[0][1]


def apply_to_overlay(overlay: dict, catalog_id: str, payload: dict) -> None:
    current = overlay.get(catalog_id, {})
    current.update({k: v for k, v in payload.items() if v not in ("", None, 0, False) or k == "network5g"})
    overlay[catalog_id] = current


def exact_index(index: list[dict]) -> dict[str, dict]:
    mapping: dict[str, dict] = {}
    for item in index:
        mapping[norm(item["label"])] = item
        mapping[norm(f"{item.get('brand', '')} {item['label']}")] = item
    return mapping


def lookup_exact(row: dict, mapping: dict[str, dict]) -> dict | None:
    for key in (norm(row["fullName"]), norm(f"{row['brand']} {row['name']}"), norm(row["name"])):
        if key in mapping:
            return mapping[key]
    return None


def payload_from(hit: dict | None, seed: dict, title: str, lang: str, summary: dict, infobox: dict) -> dict:
    source = ""
    if title:
        source = summary.get("content_urls", {}).get("desktop", {}).get("page") or (
            f"https://{lang}.wikipedia.org/wiki/{title.replace(' ', '_')}"
        )
    image = pick_image((hit or {}).get("image", ""), summary)
    return {
        "image": image,
        "sourceUrl": source or seed.get("sourceUrl"),
        "os": infobox.get("os"),
        "chipset": infobox.get("chipset"),
        "displaySize": infobox.get("displaySize"),
        "displayType": infobox.get("displayType"),
        "refreshRate": infobox.get("refreshRate"),
        "brightness": infobox.get("brightness"),
        "height": infobox.get("height"),
        "width": infobox.get("width"),
        "thickness": infobox.get("thickness"),
        "weight": infobox.get("weight"),
        "capacity": infobox.get("capacity"),
        "wiredWatt": infobox.get("wiredWatt"),
        "ram": infobox.get("ram") or seed.get("ram") or None,
        "storage": infobox.get("storage") or seed.get("storage") or None,
        "mainMp": infobox.get("mainMp"),
        "ipRating": infobox.get("ipRating"),
        "network5g": infobox.get("network5g", seed.get("network5g")),
        "qid": (hit or {}).get("qid"),
    }


def main() -> None:
    rows = json.loads(CATALOG.read_text())
    overlay: dict = {}

    print("wikidata index…")
    index = wikidata_index()
    mapping = exact_index(index)
    print(f"wikidata models: {len(index)}")

    groups: dict[str, list[dict]] = {}
    for row in rows:
        groups.setdefault(strip_storage(row["slug"]), []).append(row)

    unique_hits: dict[str, tuple[dict, list[dict]]] = {}
    exact = 0
    for base, items in groups.items():
        seed = min(items, key=lambda row: len(row["name"]))
        hit = lookup_exact(seed, mapping) or best_match(seed, index)
        if not hit:
            continue
        exact += 1
        unique_hits.setdefault(hit["qid"], (hit, []))[1].extend(items)

    print(f"exact/fuzzy groups: {exact}, unique wikidata: {len(unique_hits)}")

    done = 0
    for qid, (hit, items) in unique_hits.items():
        seed = min(items, key=lambda row: len(row["name"]))
        title = hit["label"]
        lang = "en"
        summary = wiki_summary(title, lang)
        if not summary.get("title") and not summary.get("originalimage"):
            found = wiki_search(title, "en")
            if found:
                title = found
                summary = wiki_summary(title, lang)
        infobox = parse_infobox(wiki_infobox(title, lang) if title else "", seed["name"])
        payload = payload_from(hit, seed, title, lang, summary, infobox)
        for item in items:
            apply_to_overlay(overlay, item["id"], payload)
        done += 1
        if done % 25 == 0:
            OUT.write_text(json.dumps(overlay, ensure_ascii=False))
            print(f"specs {done}/{len(unique_hits)} overlay {len(overlay)}")
        time.sleep(0.04)

    searched = 0
    for base, items in groups.items():
        seed = items[0]
        if any(item["id"] in overlay for item in items):
            continue
        if seed["brand"].lower() not in MAJOR or searched >= 400:
            continue
        query = f"{seed['brand']} {seed['name']}"
        title = wiki_search(query, "en")
        lang = "en"
        searched += 1
        if not title:
            continue
        summary = wiki_summary(title, lang)
        infobox = parse_infobox(wiki_infobox(title, lang), seed["name"])
        payload = payload_from(None, seed, title, lang, summary, infobox)
        if not payload.get("image") and not payload.get("chipset"):
            continue
        for item in items:
            apply_to_overlay(overlay, item["id"], payload)
        if searched % 20 == 0:
            OUT.write_text(json.dumps(overlay, ensure_ascii=False))
            print(f"extra-search {searched} overlay {len(overlay)}")
        time.sleep(0.1)

    OUT.write_text(json.dumps(overlay, ensure_ascii=False, indent=2))
    mobile = ROOT / "mobile" / "assets" / "data" / "specs-overlay.json"
    mobile.write_text(OUT.read_text())
    with_image = sum(1 for v in overlay.values() if v.get("image"))
    with_chip = sum(1 for v in overlay.values() if v.get("chipset"))
    print(f"done overlay={len(overlay)} image={with_image} chipset={with_chip}")


if __name__ == "__main__":
    main()
