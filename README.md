# blyg-watch

Watching the Blygger publishing network (https://blygger.org) as a system.

## Research question 1

**Will Blygger stay decentralized as it grows?**

Blygger refuses replies, counts, a follower graph and ranking. It leaves discovery and ranking to services built on top, so the attention loop it removes can come back from outside the protocol. We measure how concentrated the links between blygs are (quotes, stubs, forks) and how that changes over time. The protocol forgets part of the answer by design.

**Your job: check what can be seen, and what can't.** The crawl sees every blyg on the public list, every item in each archive index, and the links in each item's latest version and its pinned versions. It cannot see:

| Not visible | Why |
|---|---|
| Older versions of an item, unless pinned | No route serves an unpinned older version (spec v0.4 §8.4) |
| Quotes and stubs in an item later withdrawn | Withdrawal drops `stub_of`, `generated` and `transclusions` (§9) |
| Who links *to* a blyg | Mentions go to each blyg's inbox, not to its public files |
| Who follows whom | Subscriptions are private; there is no follower graph (§16.8) |
| Blygs not on the public list | The crawl starts from blygger.com's `blygs.opml` |

Snapshots on a schedule recover part of what a single later crawl would miss.

## Measuring without bringing back counts

Blygger refuses counts on purpose. A machine-readable list of who responded is "the first surface a count could attach to" (§16.6d), and a reader may order what it reads provided "nothing derived is published" (§16.6d). A public leaderboard of who is quoted would bring back the loop the protocol removes.

So this tool detects that loop and never feeds it. Every indicator tracks a warning the spec itself names, and cites it:

| The spec's warning | Where | Indicator |
|---|---|---|
| "Anything that can serve files can serve a blyg" | §1, §4 | How many blygs depend on one client or one host |
| The generator string is "the only census of the ecosystem that exists without anyone registering anything" | §3.2 | Client diversity over time |
| "every unpinned remote quote is a veto held by a stranger" | §10.2 | Share of cross-blyg quotes that point at unpinned versions |
| Stubs without a response fill "every target's response signal with non-responses" | §10.6 | Share of stubs with no editorial content |
| An aggregator "never re-emits" and never stubs for its members | §13.5 | Items that re-emit others' content |
| The blogroll "claims no completeness" | §11 | Blygs reachable only through the public list, against blygs reachable through blogrolls |
| Attention concentrating on a few origins | §16.8 | One network-wide measure of how skewed links are, with no names |

No indicator ranks a person or a blyg. With 25 blygs even an unnamed concentration figure points at someone, so the last row is shown as a trend only until the network is larger. The indicator list was offered to the protocol's authors on 2026-10-29. The indicators are blyg-watch's own choice, kept independent of the spec, so the watch does not shape what it watches.

## An independent sensor

blyg-watch is a sensor outside the thing it measures. Its indicators are its own choice, kept apart from the spec's design so the watch does not shape what it watches. It reads the network as any subscriber does and publishes nothing into it: measurements appear on this site, never as blyg items.

## The path

In Bunge's order: a problem stated in terms of measurement, then the concept, the math, the application.

1. **The question**, above.
2. **The model** (`model/`, drafted, in review): Facets models of a blyg and of the network. They name the flows the measurement counts and show where history sits.
3. **The proof** (`journal/`, begun): Lean statements of the spec's guarantees, proving which links a later crawl can recover and which only a dated snapshot keeps.
4. **The data** (`crawl/` built, `data/` from the first snapshot): a reader that subscribes to every listed blyg writes one dated snapshot a week (`crawl/README.md`), and the concentration is measured from them. The dashboard grows out of this step.

## The site

`site/` is plain HTML and CSS with no build step: a short front page, one page per step of the path (`question.html`, `model.html`, `proof.html`, `data.html`), and the proof journal, which Verso generates into `site/proof/journal/` (see `journal/README.md`). A GitHub Actions workflow publishes `site/` to GitHub Pages once the repo is public. Later, the Data step becomes the dashboard, drawing its charts from `data/*.json`. It will be served at halcyonic.systems/blyg-watch/, under the organization's existing custom domain.

Agents read `AGENTS.md`; language models start at `llms.txt`.

## Builds on

The Blygger conformance toolkit (github.com/blygger/blygger-spec, PR #11, by Aneesh Sathe) already crawls the directory and draws a network report. Its question is conformance: do blygs follow the spec? This repo asks about concentration and history over time, and reuses that work where it can.

## What is not claimed

- The Lean models spec v0.4 as written, a pre-1.0 draft. It says nothing about any client or about whether a publisher keeps its promises (hosting can lapse).
- Model runs are conditional: if this structure and these numbers, then this.
- Measurements cover the blygs on the public list at each snapshot, not every blyg that exists.

Nothing here is proven until `lake build` in `journal/` checks it.
