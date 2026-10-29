"""One weekly read of every listed blyg, written as a dated snapshot.

Per blyg: resolve (§12), read the manifest and the archive index (§6.2),
read the blogroll if the manifest names one (§11), then fetch only the item
documents whose version rose since the last snapshot. The index is "the
reconciliation surface ... complete by construction" (§6.2), so the feed is
not needed at a weekly cadence. The first run reads every item once: the
backfill §13.1 rule 6 asks of a new subscriber.
"""
import json
import xml.etree.ElementTree as ET
from datetime import date
from pathlib import Path
from urllib.parse import urljoin

from .edges import item_record
from .net import USER_AGENT, FetchError
from .resolve import ResolveError, index_url, item_url, resolve

SEEDS = "https://blygger.com/blygs.opml"


def run(fetch, data_dir, day=None, seeds=SEEDS, limit=None):
    data_dir = Path(data_dir)
    day = day or date.today().isoformat()
    out = data_dir / f"{day}.json"
    if out.exists():
        raise FileExistsError(f"{out} exists; snapshots are append-only")
    previous = _previous(data_dir, day)

    listings = _outlines(fetch.get(seeds))[:limit]
    blygs = [_read_blyg(fetch, html, feed, previous) for html, feed in listings]
    snapshot = {
        "snapshot": day,
        "watcher": USER_AGENT,
        "seeds": seeds,
        "requests": fetch.requests,
        "blygs": blygs,
    }
    data_dir.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(snapshot, indent=1, sort_keys=True) + "\n")
    return out


def _read_blyg(fetch, html_url, feed_url, previous):
    row = {"listed": html_url}
    try:
        origin, manifest, server = resolve(fetch, html_url, feed_url)
        row.update(origin=origin, server=server,
                   **{k: manifest.get(k) for k in ("blyg", "level", "generator", "generator_url")})
        index = json.loads(fetch.get(index_url(origin, manifest)).body)
        known = {i["id"]: i for i in previous.get(origin, [])}
        items = []
        for entry in index["items"]:
            old = known.get(entry["id"])
            if old and old["version"] == entry["version"]:
                items.append(old)
                continue
            r = fetch.get(item_url(origin, manifest, entry["id"]))
            try:
                if r.status != 200:
                    raise ValueError(r.status)
                items.append(item_record(json.loads(r.body), origin))
            except (ValueError, KeyError) as e:
                items.append({"id": entry["id"], "version": entry["version"], "error": str(e)})
        row["items"] = items
        if manifest.get("blogroll"):
            row["blogroll"] = sorted(h for h, _ in _outlines(fetch.get(urljoin(origin, manifest["blogroll"]))))
    except (ResolveError, FetchError, ValueError, KeyError) as e:
        # Recorded, not papered over: a blyg that could not be read this
        # week has no items in this snapshot, and the last one still stands.
        row["error"] = str(e)
    return row


def _outlines(r):
    """(htmlUrl, xmlUrl) for each entry of an OPML file (§11)."""
    if r.status != 200:
        return []
    root = ET.fromstring(r.body)
    return [((o.get("htmlUrl") or o.get("xmlUrl")).strip(), o.get("xmlUrl"))
            for o in root.iter("outline") if o.get("htmlUrl") or o.get("xmlUrl")]


def _previous(data_dir, day):
    """Items by origin from the latest snapshot before `day`."""
    older = sorted(p for p in data_dir.glob("*.json") if p.stem < day)
    if not older:
        return {}
    snap = json.loads(older[-1].read_text())
    return {b["origin"]: [i for i in b["items"] if "error" not in i]
            for b in snap["blygs"] if "items" in b}
