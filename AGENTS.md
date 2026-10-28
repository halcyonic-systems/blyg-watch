# AGENTS.md — blyg-watch

Read this first, then `README.md`. One question drives the repo: will Blygger stay decentralized as it grows? Everything here serves that question or is left out.

## Order of work
Question, then concept, then math, then application:
1. **Concept:** the Facets models in `model/` (a single blyg, then the network of blygs). They name the parts, the flows between blygs, and where history is kept.
2. **Math:** the Lean in `Blygger/`. It states the spec's guarantees and proves which links between blygs a later crawl can recover and which only a dated snapshot keeps.
3. **Application:** the measurement in `crawl/` and `data/`, then the dashboard.

## Rules
- **Shingai writes the Lean.** Explain, point to the spec section, show the error and what it means; never write a proof or definition for him to paste.
- **Claims:** never call anything proven unless `lake build` passes on it. Say what is not claimed: the Lean models spec v0.4 as written (a pre-1.0 draft), not any client and not whether a publisher keeps a promise. Model runs are conditional.
- **Cite the spec by section** (`docs/protocol-v0.4.md` in github.com/blygger/blygger-spec), with a short quote.
- **No live crawling** until crawl etiquette is settled and written here. Develop against the conformance samples in blygger-spec (`conformance/schemas/samples/`).
- **Build on what exists.** The conformance toolkit (blygger-spec PR #11) already crawls the directory and draws a network report. Extend or reuse it before writing a new crawler, and credit it.
- **Snapshots are append-only.** A file under `data/` is never edited after its date.
- **Names match.** A measured series carries the name of the model flow it measures; a test checks this.
- **Public data only.** Everything read is published on the blygs themselves. Nothing private, no inferred identities.
- **Git:** commit at each working milestone, one line on what changed and a body on why. Never push, never change the repo's visibility, never post anywhere without Shingai's go at the time.
- **Plain register, no em dashes** in anything a reader outside the repo will see.
