"""python3 -m blygwatch [--limit N] [--data ../data]  (run from crawl/)"""
import argparse
from pathlib import Path

from .net import Fetcher
from .watch import run

here = Path(__file__).resolve().parent.parent
p = argparse.ArgumentParser(prog="blygwatch", description="Write this week's snapshot of the listed blygs.")
p.add_argument("--data", default=here.parent / "data", help="snapshot folder (default: the repo's data/)")
p.add_argument("--limit", type=int, help="read only the first N listings (a smoke test)")
args = p.parse_args()

fetch = Fetcher(here / ".cache")
out = run(fetch, args.data, limit=args.limit)
print(f"{out}: {fetch.requests} requests")
