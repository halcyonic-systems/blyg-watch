# ── Candidate B: ranking inside the system of interest ──────────────
# Same pair of blygs as blygger-network.sl, with one change: Discovery
# and ranking services move from the environment into the system. The
# system of interest becomes the attention ecosystem around the blygs,
# not the blygs alone.
#
# What it tests. In the draft, concentration is something the
# environment does to the network. Here the ranker is a part, so its
# reading of archive indexes is an internal flow and only the ranking it
# hands People crosses the boundary. The loop still closes through
# People, who stay outside: a ranking changes what gets linked only by
# changing what people publish.
#
# Kept out for now: Clients, Hosts, the Public list and Unserved
# history, to keep the comparison with the draft about one move. No
# decomposition, so this file stands alone.
#
# Spec: Blygger protocol v0.4, a pre-1.0 draft. Section numbers refer
# to it.
system "Blygger attention ecosystem" : Concrete/Social
domain "Blygs linking to one another, together with the services that read their public files and publish an order over them"
description "The blygs and the rankers built on them as one system, so that a ranking taking hold is the system's own feedback rather than a push from outside."

level Structure

component "Responding blyg" interface
    description "Any blyg in the role of the one that quotes, stubs or forks another blyg's item."
component "Cited blyg" interface
    description "Any blyg in the role of the one drawn on."
component "Ranking service" interface
    description "A service that reads public files and publishes an order over blygs or items. The protocol never carries one (§16.6d, §16.8); here it is part of the system watched."

environment People
    description "Publishers and readers. Subscriptions are private (§11, §12.2)."

flow People -> "Responding blyg" : informational "publish event"
    description "An authoring act that creates a version (§2, §8, §9)."
flow People -> "Cited blyg" : informational "publish event"
    description "The same authoring acts on the cited side."

flow "Cited blyg" -> "Responding blyg" : informational "transclusion" substance transclusion
    description "A quote, pinned or not (§10.2)."
flow "Cited blyg" -> "Responding blyg" : informational "stub_of" substance stub_of
    description "A thread declaring itself a response to one target item (§10.6)."
flow "Cited blyg" -> "Responding blyg" : informational "forked_from" substance forked_from
    description "A new item started from a pinned version of another (§5.6)."
flow "Responding blyg" -> "Cited blyg" : informational "mention"
    description "A Webmention for each remote reference (§15.2), landing in an inbox the crawl cannot see."

flow "Cited blyg" -> "Ranking service" : informational "archive index"
    description "Every item ever published (§6.2), read by the ranker. Internal here."
flow "Responding blyg" -> "Ranking service" : informational "archive index"
    description "The responding blyg's archive index, read the same way (§6.2)."

flow "Ranking service" -> People : informational "ranking"
    description "The published order. The one crossing that could bring the attention loop back."
flow "Cited blyg" -> People : informational "feed" substance feed
    description "The feed and item documents a reader rebuilds a blyg from (§5, §7)."
flow "Responding blyg" -> People : informational "feed" substance feed
    description "The responding blyg's feed (§5, §7)."

@lens mobus
