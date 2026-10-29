"""From a listing in blygs.opml to a blyg's identity origin and manifest
(spec v0.4 §12), and from the manifest to its file locations (§6.1)."""
import json
import xml.etree.ElementTree as ET
from urllib.parse import urljoin, urlsplit, urlunsplit

BLYG_NS = "{https://blygger.org/ns/0.1}"


class ResolveError(Exception):
    pass


def resolve(fetch, html_url, feed_url):
    """Return (origin, manifest, server). Runs §12.1 steps 2 and 3 only:
    the direct probe at the listed page, then the feed's <blyg:manifest>.
    Every listed blyg so far resolves by one of the two."""
    tried = []
    candidate = _normalize(html_url) + "blyg.json"
    tried.append(candidate)
    r = fetch.get(candidate)
    manifest = _manifest(r)
    if manifest is None and feed_url:
        tried.append(feed_url)
        hook = _feed_hook(fetch.get(feed_url))
        if hook:
            tried.append(hook)
            r = fetch.get(hook)
            manifest = _manifest(r)
    if manifest is None:
        raise ResolveError("no manifest; tried " + ", ".join(tried))
    # §12.2: identity is the final fetch URL minus its last path segment.
    origin = r.url.rsplit("/", 1)[0] + "/"
    return origin, manifest, r.server


def index_url(origin, manifest):
    return urljoin(origin, manifest.get("items") or "items/index.json")


def item_url(origin, manifest, item_id):
    # §6.1: an RFC 6570 level-1 template with the variable `id`. Ids are
    # Crockford base32 (§5.1), so they need no escaping.
    return urljoin(origin, manifest.get("item") or "items/{id}.json").replace("{id}", item_id)


def _normalize(url):
    # §12.1 step 1: strip query and fragment, end the path in "/".
    s = urlsplit(url.strip())
    path = s.path if s.path.endswith("/") else s.path + "/"
    return urlunsplit((s.scheme, s.netloc, path, "", ""))


def _manifest(r):
    # §12.1 step 2: "parse-success is the test", not Content-Type.
    if r.status != 200:
        return None
    try:
        doc = json.loads(r.body)
    except ValueError:
        return None
    return doc if isinstance(doc, dict) and "blyg" in doc else None


def _feed_hook(r):
    if r.status != 200:
        return None
    try:
        el = ET.fromstring(r.body).find(f"channel/{BLYG_NS}manifest")
    except ET.ParseError:
        return None
    return el.text.strip() if el is not None and el.text else None
