# ── Candidate C: the fewest flows that still ask the question ───────
# The draft (blygger-network.sl) carries 22 flows. This candidate keeps
# only what the research question needs: the links between blygs and
# the one loop through the outside that could concentrate them.
#
# What it tests. Whether the draft is over-built for the first
# presentation. Dropped: Clients and Hosts (dependence indicators), the
# Public list and blogrolls (reachability), Unserved history (what is
# lost), re-emission (a flow that should stay empty), and the
# pinned/unpinned split of quotes. Each dropped piece is an indicator
# this model cannot name, so C is a reading aid, not a replacement.
#
# Spec: Blygger protocol v0.4, a pre-1.0 draft. Section numbers refer
# to it.
system "Blygger network, minimal" : Concrete/Social
domain "Blygs linking to one another, with discovery and ranking left to services outside the protocol"
description "The links between blygs and the one loop through the outside that could concentrate them, and nothing else."

level Structure

component "Responding blyg" interface
    description "Any blyg in the role of the one that quotes, stubs or forks another blyg's item."
component "Cited blyg" interface
    description "Any blyg in the role of the one drawn on."

environment People
    description "Publishers and readers."
environment "Discovery and ranking services"
    description "Services on top of the protocol that read public files and order what they find (§16.6d)."

flow People -> "Responding blyg" : informational "publish event"
    description "An authoring act that creates a version (§2)."
flow People -> "Cited blyg" : informational "publish event"
    description "The same on the cited side."

flow "Cited blyg" -> "Responding blyg" : informational "transclusion" substance transclusion
    description "A quote (§10.2)."
flow "Cited blyg" -> "Responding blyg" : informational "stub_of" substance stub_of
    description "A response to one target item (§10.6)."
flow "Cited blyg" -> "Responding blyg" : informational "forked_from" substance forked_from
    description "A copy started from a pinned version (§5.6)."
flow "Responding blyg" -> "Cited blyg" : informational "mention"
    description "A Webmention, invisible to the crawl (§15.2)."

flow "Cited blyg" -> "Discovery and ranking services" : informational "archive index"
    description "Every item ever published (§6.2)."
flow "Discovery and ranking services" -> People : informational "ranking"
    description "The published order the protocol never carries (§16.8)."
flow "Responding blyg" -> People : informational "feed" substance feed
    description "What readers read (§7)."

@lens mobus
