# ── The Blygger publishing network, Mobus lens ──────────────────────
# blyg-watch's first question: will Blygger stay decentralized as it
# grows? The model does not answer it. It names the flows the crawl
# measures and shows where history is kept or lost, so a measured
# series can carry the name of the flow it measures (AGENTS.md, "Names
# match").
#
# Spec: Blygger protocol v0.4, a pre-1.0 draft
# (github.com/blygger/blygger-spec, docs/protocol-v0.4.md). Section
# numbers below refer to it.
#
# How to read it. The system is the network of blygs. Any blyg plays
# both roles, so the network is drawn as one pair: a Responding blyg
# that quotes, stubs and forks, and a Cited blyg it draws on. The links
# between them are the three link kinds (transclusion, stub_of,
# forked_from) and the mention sent back. Concentration is how unevenly
# those links fall across cited blygs as the network grows.
#
# The question shows up as one loop through the outside. The protocol
# carries no counts, no follower graph and no ranking (§16.8), and it
# leaves discovery to services on top (§16.6d). A Discovery and ranking
# service reads the Cited blyg's public files and hands People a
# ranking; People then publish, through the Responding blyg, links to
# what they were shown. If that loop takes hold, links concentrate. The
# dependence the indicators measure enters from Clients (the generator
# string, §3.2) and Hosts (§4). History the crawl cannot recover leaves
# for Unserved history.
#
# One level down: the Responding blyg decomposes into ./blyg.sl. Only
# one of the pair decomposes because a child model is checked against
# one parent component's neighbours by name; the Cited blyg has the
# same interior seen from the other side.
#
# Flows carry no amounts. The probe facts of 2026-10-28 are counts of
# things, not rates, so they sit in groundings, not on flows.
system "Blygger network" : Concrete/Social
domain "Blygs on the public web linking to one another by transclusion, stub_of and forked_from, with discovery and ranking left to services outside the protocol"
description "The network of blygs as one system: what enters it (publish events, clients, hosting), what passes between blygs (the three link kinds and mentions), what leaves (feeds, blogrolls, and history no route serves)."

level Structure

# ── The pair of blygs: the system's interior ────────────────────────
component "Responding blyg" interface decomposes "Responding blyg" @2WuyUSwaBz3ZwZssBFPysf
    description "Any blyg in the role of the one that quotes, stubs or forks another blyg's item. It publishes versions, sends mentions, and may publish a blogroll. Its interior is ./blyg.sl."
component "Cited blyg" interface
    description "Any blyg in the role of the one drawn on: the target of a transclusion, a stub_of or a forked_from. It serves its feed and archive index to anyone, and keeps or drops older versions by whether they are pinned (§8)."

# ── Outside: the people, the dependence, the attention loop ─────────
environment People
    description "Publishers and readers. A publisher controls an origin and writes items; a reader subscribes, which is private client-local state (§11, §12.2). The same person is often both."
environment Clients
    description "The software that produces blygs. Each names itself in the manifest's generator string, which the spec calls the only census of the ecosystem that exists without anyone registering anything (§3.2)."
    grounding asserted "11 distinct clients across the blygs on blygs.opml, probe 2026-10-28"
environment Hosts
    description "Whatever serves a blyg's static files. The spec asks only that the whole surface be servable as plain static files (§4), so anything that can serve files can serve a blyg (§1)."
    grounding asserted "Blygger Studio runs 12 of the 25 listed blygs on Cloudflare Workers, probe 2026-10-28"
environment "Public list"
    description "blygger.com's blygs.opml, the list the crawl starts from. It is a directory outside the protocol. Blygs not on it are invisible to the crawl."
    grounding asserted "25 blygs on blygs.opml, 3,056 items across them, probe 2026-10-28"
environment "Discovery and ranking services"
    description "Services built on top of the protocol that read public files and order what they find. The protocol allows a reader to order things locally provided nothing derived is published (§16.6d); a service that publishes its order is where the attention loop could return from."
sink "Unserved history"
    description "What no route serves: older versions that were never pinned (§8.4) and the links a withdrawal endcap drops (§9). A crawl after the fact cannot recover these; only a dated snapshot keeps them."

# ── Into the blygs: authoring, software, hosting ────────────────────
flow People -> "Responding blyg" : informational "publish event"
    description "An authoring act that creates a version: a new item, an edit, a withdrawal, a reversal of a withdrawal, or a pin (§2, §8, §9)."
flow People -> "Cited blyg" : informational "publish event"
    description "The same authoring acts on the cited side."
flow Clients -> "Responding blyg" : informational "generator"
    description "The client that writes this blyg's surface, named in the manifest's generator string (§3.2). Indicators: dependence on one client, and client diversity over time."
flow Clients -> "Cited blyg" : informational "generator"
    description "The client behind the cited blyg, named the same way (§3.2)."
flow Hosts -> "Responding blyg" : energy "hosting"
    description "Storage and serving for this blyg's static files (§4). Indicator: dependence on one host."
flow Hosts -> "Cited blyg" : energy "hosting"
    description "Storage and serving for the cited blyg's static files (§4)."

# ── Between blygs: the three link kinds and the mention ─────────────
flow "Cited blyg" -> "Responding blyg" : informational "pinned transclusion" substance pinned_transclusion
    description "A quote of a pinned version: the snapshot is baked at publish time (§10.2) and the source version stays fetchable forever (§8)."
flow "Cited blyg" -> "Responding blyg" : informational "unpinned transclusion" substance unpinned_transclusion
    description "A quote of a version that is not pinned. The snapshot stays in the quoting thread (§10.4), but the source version can later stop being served; the spec calls every unpinned remote quote a veto held by a stranger (§10.2)."
flow "Cited blyg" -> "Responding blyg" : informational "stub_of" substance stub_of
    description "A thread declaring itself a response to exactly one target item (§10.6). The protocol has no reply primitive (§16.8). A stub with no words of its own is a repost (§2, §15.4)."
flow "Cited blyg" -> "Responding blyg" : informational "forked_from" substance forked_from
    description "A new item started as a copy of a pinned version of another item (§5.6). The lineage is immutable and survives withdrawal (§5.6 rules 3 and 4, §9)."
flow "Cited blyg" -> "Responding blyg" : informational "re-emission" substance re-emission
    description "An imported item published again as one's own. The spec forbids it: imported items are never re-emitted (§13.5). Drawn so the indicator that watches for it has a flow to name; it should stay empty."
flow "Responding blyg" -> "Cited blyg" : informational "mention"
    description "A Webmention sent for each remote reference (§15.2). It lands in the cited blyg's inbox, not in its public files, so the crawl cannot see who links to a blyg."

# ── Out to people: what readers can find ────────────────────────────
flow "Responding blyg" -> People : informational "feed" substance feed
    description "The feed and the item documents behind it (§5, §7), from which a reader rebuilds the blyg's state."
flow "Cited blyg" -> People : informational "feed" substance feed
    description "The cited blyg's feed and item documents (§5, §7)."
flow "Responding blyg" -> People : informational "blogroll" substance blogroll
    description "An optional curated list of subscriptions the publisher chose to show. It claims no completeness, ever (§11). Indicator: blygs reachable through blogrolls against those reachable only through the public list."
flow "Public list" -> People : informational "blygs.opml"
    description "The directory's list of blygs, the other way a reader or the crawl finds an origin."

# ── The attention loop, outside the protocol ────────────────────────
flow "Cited blyg" -> "Discovery and ranking services" : informational "archive index"
    description "Every item ever published, withdrawn ones included, with no window (§6.2). Public, so any service may read it."
flow "Responding blyg" -> "Discovery and ranking services" : informational "archive index"
    description "The responding blyg's archive index, public in the same way (§6.2)."
flow "Discovery and ranking services" -> People : informational "ranking"
    description "An order over blygs or items, derived and published outside the protocol. The protocol never carries one (§16.6d, §16.8). This is the flow that could bring back the attention loop; blyg-watch watches for it and never publishes one."

# ── Where history leaves the record ─────────────────────────────────
flow "Cited blyg" -> "Unserved history" : informational "unpinned older version" substance unpinned_version
    description "A superseded version that was never pinned. No route ever serves it (§8.4), so a quote that pointed at it can no longer be checked against its source."
flow "Responding blyg" -> "Unserved history" : informational "unpinned older version" substance unpinned_version
    description "The responding blyg's own superseded unpinned versions, and the links they carried (§8.4)."
flow "Responding blyg" -> "Unserved history" : informational "withdrawal endcap" substance endcap
    description "The links a withdrawal drops: the endcap empties transclusions and omits stub_of, while keeping page and forked_from (§9). Remote copies and snapshots survive it."

@lens mobus
