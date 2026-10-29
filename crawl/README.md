# crawl/

The watcher: a reader that subscribes to every listed blyg and writes one dated snapshot a week into `data/`. Python standard library only. Section numbers refer to Blygger spec v0.4, a pre-1.0 draft.

## Why a reader, not a crawler or a blyg

The choice was between a crawler, a watcher that is itself a blyg, and a reader that subscribes to every blyg. In the spec's terms a subscriber is a reader: "Subscribing is invisible, client-local state" (§11), and nothing requires a reader to have an origin of its own. So this is a reader. It publishes nothing into the network: a watcher that published its measurements as blyg items would feed what it watches, and §16.6d lets a reader order what it finds only "provided nothing derived is published".

It is new code rather than an extension of the conformance toolkit (blygger-spec `conformance/live`, Aneesh Sathe), for three reasons. That tool asks a broader question, conformance, and a cold run of it is about 2,700 requests where this needs about one per item once. It was written against v0.3, so it reads fixed paths where v0.4 manifests may relocate them (§6.1). And a reader small enough to read end to end is easier to check against the spec. The toolkit's sample blygs are this code's test fixtures (`tests/fixtures/conformance-samples/`, MIT, source commit in `SOURCE`).

## What one run does

| Step | Spec | Requests per blyg |
|---|---|---|
| Resolve the listing to a manifest: probe `blyg.json` at the listed page, else follow the feed's `<blyg:manifest>` | §12.1 steps 2 and 3 | 1 to 3 |
| Read the archive index | §6.2 | 1 |
| Fetch each item document whose version rose since the last snapshot, at the manifest's `item` template | §6.1, §13.2 | 0 when nothing changed |
| Read the blogroll, if the manifest names one | §11 | 0 or 1 |

The first run reads every item once, the backfill §13.1 asks of a new subscriber ("SHOULD backfill from `items/index.json`"). After that a quiet week costs two or three requests per blyg. The feed is not read: at a weekly cadence the index, "complete by construction" (§6.2), tells the watcher everything the feed would.

## Etiquette

| Rule | Value | Spec |
|---|---|---|
| Cadence | Once a week | Sets no rate |
| Pace | One request at a time, at least 1 second apart | |
| User-Agent | `blyg-watch/0.1 (+https://halcyonic.systems/blyg-watch/)` | §12.3 |
| Conditional requests | `If-None-Match` and `If-Modified-Since`, validators cached in `.cache/` (not committed) | §12.3 |
| Failure | Three tries, waits doubling from 2 seconds; `Retry-After` honoured on 429 and 503, up to 5 minutes, else the blyg is skipped this week. Never polls faster after a failure. | §12.3 |
| Redirects | At most 5; the final URL is the blyg's identity | §12.2 |
| Seeds | blygger.com's `blygs.opml` only. Blogroll entries are recorded as URLs and not fetched. | §11 |

## What a snapshot keeps

`data/YYYY-MM-DD.json`, written once and never edited. Per blyg: the listed URL, the identity origin, the manifest's `blyg`, `level`, `generator` and `generator_url`, the `Server` header of the manifest response (for host dependence; inferred, since a header is not proof of a host), the blogroll's URLs, and per item its `id`, `kind`, `version`, pinned versions and edges. An edge is a kind (`transclusion`, `stub_of`, `forked_from`, each the label of a flow in `model/`) and a target `{origin, id, version}`, or `{url}` for a plain-web stub.

No item text, no `cited` captions, no author names. A blyg that could not be read is recorded with its error and no items; nothing is carried forward from an earlier week. Edges from an item later withdrawn stay in the snapshots taken before the withdrawal: a snapshot is a record of what was public on its date, and the spec says "snapshots survive withdrawal" (§9).

## What it misses

- Unpinned versions from before the first run, and versions published and replaced within one week (§8.4).
- Plain links (`links[]`, §10.3a) and generation sources (`generated[].sources[]`, §5.7). Not captured yet.
- Mentions: they "never enter the feed, the archive index, or any item document" (§15.5).
- Who follows whom (§11), and blygs not on the list.

## Run

```
cd crawl
python3 -m unittest            # offline, against the sample blygs
python3 -m blygwatch --limit 2 # live: the first two listings only
python3 -m blygwatch           # live: this week's snapshot of every listing
```

Live runs need Shingai's go until the first full snapshot exists (AGENTS.md).
