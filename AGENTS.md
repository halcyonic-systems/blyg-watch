# AGENTS.md: blyg-watch

Read this first, then `README.md`. One question drives the repo: will Blygger stay decentralized as it grows?

## Order of work
Question, then concept, then math, then application:
1. **Concept:** the Facets models in `model/` (a single blyg, then the network of blygs). They name the parts, the flows between blygs, and where history is kept.
2. **Math:** the Lean in the proof journal (`journal/`, a Verso package; the Lean lives in its entries). It states the spec's guarantees and proves which links between blygs a later crawl can recover and which only a dated snapshot keeps.
3. **Application:** the measurement in `crawl/` and `data/`, then the dashboard.

## Rules
- **Shingai writes the Lean.** Explain, point to the spec section, show the error and what it means; never write a proof or definition for Shingai to paste.
- **Claims:** never call anything proven unless `journal/build.sh` passes on it (it runs `lake build` in `journal/`). Say what is not claimed: the Lean models spec v0.4 as written (a pre-1.0 draft), not any client and not whether a publisher keeps a promise. Model runs are conditional.
- **Cite the spec by section** (`docs/protocol-v0.4.md` in github.com/blygger/blygger-spec), with a short quote.
- **Etiquette** (settled 2026-10-29, detail in `crawl/README.md`): a reader, never a blyg; weekly; one request at a time, at least 1 second apart; User-Agent `blyg-watch/0.1 (+https://halcyonic.systems/blyg-watch/)`; conditional requests; backoff that never tightens (§12.3); seeds from `blygs.opml` only. Develop against the samples in `crawl/tests/fixtures/`. A live run needs Shingai's go until the first full snapshot exists.
- **Build on what exists.** Reuse before writing, and credit what is reused. The watcher is new code by Shingai's ruling (2026-10-29): the conformance toolkit (blygger-spec PR #11, Aneesh Sathe) asks a broader question and reads v0.3 paths, so its sample blygs are the watcher's test fixtures instead (`crawl/README.md`).
- **An independent sensor.** blyg-watch watches the network from outside and stays out of the spec's design: it does not ask the spec's authors what to measure, and it publishes nothing into the network. Measurements live on the site, never on a blyg.
- **Detect, never feed.** Every indicator tracks a warning the spec names and cites it (README table). Never publish a ranking, leaderboard or per-blyg count of who is quoted, stubbed or forked.
- **Snapshots are append-only.** A file under `data/` is never edited after its date.
- **Names match.** A measured series carries the name of the model flow it measures; a test checks this.
- **Public data only.** Everything read is published on the blygs themselves. Nothing private, no inferred identities.
- **Site:** `site/` stays plain HTML and CSS, light first, Frost colours, radius 8px or less, no shadows, readable at 390px wide. The latest-entry links on the front page and the Proof page are written by `journal/build.sh`; never edit between the `latest-entry` markers by hand. It says only what the README says. The repo goes public, and Pages goes on, when the indicator list is offered to the protocol's authors, not before.
- **Git:** commit at each working milestone, one line on what changed and a body on why. Never push, never change the repo's visibility, never post anywhere without Shingai's go at the time.
- **Plain register, no em dashes** in anything a reader outside the repo will see.
