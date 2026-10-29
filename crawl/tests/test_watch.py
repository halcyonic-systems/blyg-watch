"""The watch run against the conformance samples (fixtures/conformance-samples,
from blygger-spec conformance/schemas/samples by Aneesh Sathe, MIT), served
offline: no network."""
import json
import re
import tempfile
import unittest
from pathlib import Path

from blygwatch.edges import KINDS, edges
from blygwatch.net import Response
from blygwatch.resolve import item_url, resolve
from blygwatch.watch import run

HERE = Path(__file__).parent
SAMPLES = HERE / "fixtures" / "conformance-samples"
ORIGINS = {"https://studio.example/": SAMPLES / "studio",
           "https://source.example/": SAMPLES / "fake-remote"}
SEEDS = "https://directory.example/blygs.opml"
OPML = b"""<?xml version="1.0"?><opml version="2.0"><body>
<outline type="rss" text="s" xmlUrl="https://studio.example/feed.xml" htmlUrl="https://studio.example/" />
<outline type="rss" text="r" xmlUrl="https://source.example/feed.xml" htmlUrl="https://source.example" />
</body></opml>"""


class Samples:
    """Serves the sample trees by URL, the same interface as net.Fetcher."""

    def __init__(self, extra=None):
        self.requests = 0
        self.extra = extra or {}

    def get(self, url):
        self.requests += 1
        if url in self.extra:
            return Response(url, 200, self.extra[url])
        for origin, root in ORIGINS.items():
            if url.startswith(origin):
                path = root / url[len(origin):]
                if path.is_file():
                    return Response(url, 200, path.read_bytes(), "fixture")
        return Response(url, 404, b"")


def studio_doc(item_id):
    return json.loads((SAMPLES / "studio" / "items" / f"{item_id}.json").read_text())


class TestEdges(unittest.TestCase):
    def test_thread_quotes_scoped_to_origin(self):
        got = edges(studio_doc("3vg46z8hj2n560wedjgg1z3nyz"), "https://studio.example/")
        self.assertEqual([e["to"]["origin"] for e in got],
                         ["https://studio.example/", "https://source.example/", "https://source.example/"])
        self.assertTrue(all(e["kind"] == "transclusion" for e in got))

    def test_stub_and_quote_on_one_item(self):
        got = edges(studio_doc("6qhwqarymq55b76bt0z0e5zh78"), "https://studio.example/")
        self.assertEqual(sorted(e["kind"] for e in got), ["stub_of", "transclusion"])

    def test_plain_web_stub_keeps_only_the_url(self):
        got = edges(studio_doc("1ne2c1zfgmqsjbfcjvbgg9kkpd"), "https://studio.example/")
        self.assertEqual(got, [{"kind": "stub_of", "to": {"url": "https://plain.example/post"}}])

    def test_withdrawn_item_keeps_its_fork(self):
        # §9: "The endcap keeps page and forked_from".
        got = edges(studio_doc("17sq2wrc2g0x4ea40ypspbt9dj"), "https://studio.example/")
        self.assertEqual([e["kind"] for e in got], ["forked_from"])


class TestResolve(unittest.TestCase):
    def test_direct_probe_and_identity(self):
        origin, manifest, _ = resolve(Samples(), "https://source.example", None)
        self.assertEqual(origin, "https://source.example/")
        self.assertEqual(manifest["title"], "Fake Source Blyg")

    def test_feed_upgrade_when_the_page_has_no_manifest(self):
        origin, _, _ = resolve(Samples(), "https://elsewhere.example/blog/", "https://studio.example/feed.xml")
        self.assertEqual(origin, "https://studio.example/")

    def test_item_template(self):
        m = {"item": "https://x.example/wp-json/blyg/v1/items/{id}"}
        self.assertEqual(item_url("https://x.example/wp-json/blyg/v1/", m, "abc"),
                         "https://x.example/wp-json/blyg/v1/items/abc")


class TestRun(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.data = Path(self.tmp.name)

    def tearDown(self):
        self.tmp.cleanup()

    def first(self):
        fetch = Samples({SEEDS: OPML})
        out = run(fetch, self.data, day="2026-11-01", seeds=SEEDS)
        return fetch, json.loads(out.read_text())

    def test_backfill_reads_every_item(self):
        fetch, snap = self.first()
        studio, source = snap["blygs"]
        self.assertEqual(len(studio["items"]), 13)
        self.assertEqual(len(source["items"]), 3)
        self.assertEqual(studio["generator"], "blygger-studio/0.21.0")
        self.assertNotIn("error", studio)

    def test_no_text_leaves_the_blyg(self):
        _, snap = self.first()
        dumped = json.dumps(snap)
        for key in ("content_md", "content_html", "cited", "excerpt", "author"):
            self.assertNotIn(f'"{key}"', dumped)

    def test_second_week_fetches_only_changed_items(self):
        first, _ = self.first()
        again = Samples({SEEDS: OPML})
        run(again, self.data, day="2026-11-08", seeds=SEEDS)
        # Seeds, then per blyg: a manifest probe and the index. No items.
        self.assertEqual(again.requests, 1 + 2 * 2)
        self.assertLess(again.requests, first.requests)

    def test_snapshots_are_append_only(self):
        self.first()
        with self.assertRaises(FileExistsError):
            run(Samples({SEEDS: OPML}), self.data, day="2026-11-01", seeds=SEEDS)

    def test_unreachable_blyg_is_recorded_not_invented(self):
        opml = OPML.replace(b"https://source.example", b"https://gone.example")
        snap = json.loads(run(Samples({SEEDS: opml}), self.data, day="2026-11-01", seeds=SEEDS).read_text())
        gone = snap["blygs"][1]
        self.assertIn("error", gone)
        self.assertNotIn("items", gone)


class TestNamesMatch(unittest.TestCase):
    def test_every_edge_kind_is_a_model_flow(self):
        # AGENTS.md: a measured series carries the name of the model flow it measures.
        model = HERE.parent.parent / "model"
        labels = set()
        for sl in model.glob("*.sl"):
            labels |= set(re.findall(r'^flow .*: \w+ "([^"]+)"', sl.read_text(), re.M))
        for kind in KINDS:
            self.assertIn(kind, labels, f"{kind} is not a flow label in model/")


if __name__ == "__main__":
    unittest.main()
