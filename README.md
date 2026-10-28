# blyg-watch

Watching the Blygger publishing network (https://blygger.org) as a system.

## The first question

**Is the thicket concentrating?** Will Blygger stay decentralized as it grows? Part of the answer the protocol forgets on purpose.

**Your job: check what can be seen, and what can't.** The crawl sees every blyg on the public list, every item in each archive index, and the links inside each item's latest version and its pinned versions. It cannot see:

| Not visible | Why |
|---|---|
| Older versions of an item, unless pinned | No route serves an unpinned older version (spec v0.4 §8.4) |
| Quotes and stubs in an item later withdrawn | Withdrawal drops `stub_of`, `generated` and `transclusions` (§9) |
| Who links *to* a blyg | Mentions go to each blyg's inbox, not to its public files |
| Who follows whom | Subscriptions are private; there is no follower graph by design (§16.8) |
| Blygs not on the public list | The crawl starts from blygger.com's `blygs.opml` |

Snapshots on a schedule recover part of what a single later crawl would miss.

Blygger refuses replies, counts, a follower graph and ranking. It leaves discovery and ranking to services built on top, so the attention loop it removes can come back from outside the protocol. We measure how concentrated the links between blygs are (quotes, stubs, forks) and how that changes over time.

## Three parts, each needed by the others

| Part | What it does | Folder |
|---|---|---|
| Lean | States the protocol's guarantees from spec v0.4 and proves which links a later crawl can recover and which only a dated snapshot keeps | `Blygger/` (not yet) |
| Facets models | The single blyg and the network of blygs; names the flows the dashboard measures | `model/` (not yet) |
| Measurement | Crawls the public blyg list, saves dated snapshots, computes concentration | `crawl/`, `data/` (not yet) |

The dashboard and the written chapter (Verso, its own package) come later. Agents: read `AGENTS.md`; models: `llms.txt`.

## The path through it

The repo and its site follow one path, in Bunge's order: a problem stated in terms of measurement, then the concept, the math, and the application.

1. **The question:** what is being asked and how it is measured.
2. **The model:** a blyg, then the network of blygs, and where history sits.
3. **The proof:** which part of the network's history the protocol keeps.
4. **The data:** what the crawls show, and what they cannot see.

## Builds on

The Blygger conformance toolkit (github.com/blygger/blygger-spec, PR #11, by Aneesh Sathe) already crawls the directory and draws a network report. Its question is conformance: do blygs follow the spec? This repo asks a different one, about concentration and history over time, and reuses that work where it can.

## What is claimed and what is not

- The Lean files model the spec as written, a pre-1.0 draft. They say nothing about any client or about whether a publisher keeps its promises (hosting can lapse).
- Model runs are conditional: if this structure and these numbers, then this.
- Measurements cover the blygs on the public list at the time of each snapshot, not every blyg that exists.

Nothing here is proven until `lake build` checks it.
