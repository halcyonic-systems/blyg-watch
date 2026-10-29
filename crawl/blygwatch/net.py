"""Polite HTTP for the watch (spec v0.4 §12.3).

One request at a time, at least `interval` seconds apart, with an
identifying User-Agent and conditional requests. Retries back off and never
tighten: "MUST NOT tighten their polling interval in response to failure."
"""
import hashlib
import json
import time
import urllib.error
import urllib.request
from dataclasses import dataclass
from pathlib import Path

USER_AGENT = "blyg-watch/0.1 (+https://halcyonic.systems/blyg-watch/)"
MAX_REDIRECTS = 5  # §12.2: "follow a bounded number (RECOMMENDED: 5)"
RETRIES = 3
MAX_WAIT = 300  # seconds; a longer Retry-After means try next week


@dataclass
class Response:
    url: str  # the final URL after redirects, which is what identity uses (§12.2)
    status: int
    body: bytes
    server: str | None = None


class FetchError(Exception):
    pass


class _Redirects(urllib.request.HTTPRedirectHandler):
    max_redirections = MAX_REDIRECTS


class Fetcher:
    """Fetches over the network, caching validators in `cache_dir` so a
    second read of an unchanged file is a 304."""

    def __init__(self, cache_dir, interval=1.0):
        self.cache = Path(cache_dir)
        self.cache.mkdir(parents=True, exist_ok=True)
        self.interval = interval
        self.requests = 0
        self._last = 0.0
        self._open = urllib.request.build_opener(_Redirects()).open

    def get(self, url):
        meta_path, body_path = self._paths(url)
        meta = json.loads(meta_path.read_text()) if meta_path.exists() else None
        headers = {"User-Agent": USER_AGENT}
        if meta and meta.get("etag"):
            headers["If-None-Match"] = meta["etag"]
        if meta and meta.get("last_modified"):
            headers["If-Modified-Since"] = meta["last_modified"]

        wait = 2
        for attempt in range(RETRIES):
            self._pace()
            try:
                with self._open(urllib.request.Request(url, headers=headers), timeout=30) as r:
                    body = r.read()
                    meta = {"url": r.geturl(), "etag": r.headers.get("ETag"),
                            "last_modified": r.headers.get("Last-Modified"),
                            "server": r.headers.get("Server")}
                    meta_path.write_text(json.dumps(meta))
                    body_path.write_bytes(body)
                    return Response(meta["url"], r.status, body, meta["server"])
            except urllib.error.HTTPError as e:
                if e.code == 304 and meta:
                    return Response(meta["url"], 200, body_path.read_bytes(), meta.get("server"))
                if e.code in (429, 503) and attempt < RETRIES - 1:
                    wait = max(wait, _retry_after(e.headers.get("Retry-After")))
                    if wait > MAX_WAIT:
                        raise FetchError(f"{url}: {e.code}, Retry-After {wait}s") from e
                    time.sleep(wait)
                    wait *= 2
                    continue
                if 400 <= e.code < 500:
                    return Response(url, e.code, b"")
                if attempt < RETRIES - 1:
                    time.sleep(wait)
                    wait *= 2
                    continue
                raise FetchError(f"{url}: {e.code}") from e
            except (urllib.error.URLError, TimeoutError) as e:
                if attempt < RETRIES - 1:
                    time.sleep(wait)
                    wait *= 2
                    continue
                raise FetchError(f"{url}: {e}") from e

    def _pace(self):
        gap = time.monotonic() - self._last
        if gap < self.interval:
            time.sleep(self.interval - gap)
        self._last = time.monotonic()
        self.requests += 1

    def _paths(self, url):
        key = hashlib.sha256(url.encode()).hexdigest()[:32]
        return self.cache / f"{key}.json", self.cache / f"{key}.body"


def _retry_after(value):
    try:
        return int(value)
    except (TypeError, ValueError):
        return 60
