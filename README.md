# blyg-watch

Watching the Blygger publishing network (https://blygger.org) as a system.

## The first question

Will Blygger stay decentralized as it grows?

Blygger refuses replies, counts, a follower graph and ranking. It leaves discovery and ranking to services built on top, so the attention loop it removes can come back from outside the protocol. We measure how concentrated the links between blygs are (quotes, stubs, forks) and how that changes over time.

## Three parts, each needed by the others

| Part | What it does | Folder |
|---|---|---|
| Lean | States the protocol's guarantees from spec v0.4 and proves which links a later crawl can recover and which only a dated snapshot keeps | `Blygger/` (not yet) |
| Facets models | The single blyg and the network of blygs; names the flows the dashboard measures | `model/` (not yet) |
| Measurement | Crawls the public blyg list, saves dated snapshots, computes concentration | `crawl/`, `data/` (not yet) |

The dashboard and the written chapter (Verso, its own package) come later. Agents: read `AGENTS.md`; models: `llms.txt`.

## What is claimed and what is not

- The Lean files model the spec as written, a pre-1.0 draft. They say nothing about any client or about whether a publisher keeps its promises (hosting can lapse).
- Model runs are conditional: if this structure and these numbers, then this.
- Measurements cover the blygs on the public list at the time of each snapshot, not every blyg that exists.

Nothing here is proven until `lake build` checks it.
