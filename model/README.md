# model/

Facets models of the Blygger network, in Facets' system language (SL). They name the flows the crawl measures and show where history is kept or lost. They answer nothing on their own. Section numbers refer to Blygger spec v0.4, a pre-1.0 draft.

| File | What it is |
|---|---|
| `blygger-network.sl` | The network as the system of interest. Inside: one pair of blygs, a Responding blyg and a Cited blyg (any blyg plays both roles). Outside: People, Clients, Hosts, the Public list (blygs.opml), Discovery and ranking services, and Unserved history. |
| `blyg.sl` | One blyg, one level down: the interior of the Responding blyg (`decomposes`), updated from the spec v0.3 model to v0.4. |
| `candidate-b-ranking-inside.sl` | Candidate: Discovery and ranking services inside the boundary, so the system of interest is the attention ecosystem and concentration reads as its own feedback. |
| `candidate-d-functional.sl` | Candidate: the network as five work processes (Publishing, Archive as a stock, Linking, Notification, Discovery) with named pass-ways and no governance subsystem. Shows how the network works, not between whom. |

The two candidates sit beside the draft until Shingai rules on which reading leads. A minimal candidate (links and the one loop only) was dropped on 2026-10-29: it could not name five of the seven indicators.

The question shows up as one loop through the outside: Cited blyg → `archive index` → Discovery and ranking services → `ranking` → People → `publish event` → Responding blyg, which draws on the Cited blyg again. The protocol carries no ranking (§16.6d, §16.8); if one published outside it takes hold, links concentrate.

## Flows and indicators

A measured series carries the name of the flow it measures (AGENTS.md).

| Indicator (site/question.html) | Flow(s) it measures |
|---|---|
| How many blygs depend on one client or one host | `generator`, `hosting` |
| Client diversity over time | `generator` |
| Share of cross-blyg quotes that point at unpinned versions | `unpinned transclusion` against `pinned transclusion` |
| Share of stubs with no editorial content | `stub_of` (the share that are reposts, §15.4) |
| Items that re-emit others' content | `re-emission` (forbidden by §13.5; should stay empty) |
| Blygs reachable only through the public list, against those reachable through blogrolls | `blygs.opml` against `blogroll` |
| One network-wide measure of how skewed links are, with no names | `pinned transclusion`, `unpinned transclusion`, `stub_of`, `forked_from` together |

Not measurable by the crawl, and drawn so the gap shows: `mention` (lands in an inbox, §15), `ranking` (outside the protocol), and everything into Unserved history (`unpinned older version`, §8.4; `withdrawal endcap`, §9).

## Shared vocabulary

Element and flow names use the spec's own terms so the Lean in `journal/` and these models can be read against each other. The last column is Shingai's to fill as the journal names things.

| Spec term | Section | SL element or flow | Lean name (journal) |
|---|---|---|---|
| origin | §2, §4 | each blyg component (a blyg is its file tree at its origin) | |
| item | §2, §5 | `Item document` (blyg.sl) | |
| fragment, thread | §2, §5.3 | kinds held in `Item document` | |
| version | §2, §5.2 | flow `new version` (blyg.sl) | |
| publish event | §2 | `Publish event` (blyg.sl); flow `publish event` | |
| pin | §8 | flow `pin`; `Pinned version document` (blyg.sl) | |
| historical versions, pinned-only | §8.4 | flow `unpinned older version` → `Unserved history` | |
| withdrawal, endcap | §9 | flow `withdrawal endcap` (both files) | |
| archive index | §6.2 | `Archive index` (blyg.sl); flow `archive index` | |
| feed | §7 | `Feed` (blyg.sl); flow `feed` | |
| manifest | §6.1 | `Manifest` (blyg.sl) | |
| generator | §3.2 | flow `generator` | |
| transclusion | §10, §10.2 | flows `pinned transclusion`, `unpinned transclusion`; `Publish-time resolution` | |
| reference | §5.9 | flow `reference`, `remote reference` (blyg.sl) | |
| stub, `stub_of` | §10.6 | flow `stub_of` | |
| lineage, `forked_from` | §5.6 | flow `forked_from` | |
| mention | §15 | flow `mention`; `Webmention sender` (blyg.sl) | |
| blogroll | §11 | `Blogroll` (blyg.sl); flow `blogroll` | |
| re-emission | §13.5 | flow `re-emission` | |

## Validate

From the Facets design branch (`~/Desktop/halcyonic-projects/active/facets-wt-design`):

```
just facets verdict <path>/model/blygger-network.sl --lens mobus   # also --lens bunge, --lens klir
just facets verdict <path>/model/blyg.sl --lens mobus
```

Exit 0 means the kernel found no error. As of 2026-10-28 both files exit 0 under all three lenses, with warnings only:

- Network, Mobus: one `interface_does_work` warning (the Responding blyg is its own pass-way and also turns links into feeds).
- Blyg, Mobus: six `interface_does_work` warnings (the files are the boundary, §4, so they both serve and store) and two `dead_end` warnings (`Pinned version document`, `Manifest`: nothing reads them at this grain).
- Bunge reads both as `system`. Klir places the network at S²E (one element decomposed) and the blyg at SE.

The CLI does not check the seam between the two files. To check it, join them into one file with the `@id` removed from the `decomposes` line and open it with File → Open in the Facets app (`just dev`); the app showed "seams hold" for the Responding blyg on 2026-10-28. The `@id` in `blygger-network.sl` was minted by hand for the CLI; the app stamps its own when it opens the joined file.
