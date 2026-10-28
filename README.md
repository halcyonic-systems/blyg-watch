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
