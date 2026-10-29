# ── Candidate D: subsystems by function, not by role ────────────────
# A, B and C divide the network by role: a responding blyg and a cited
# blyg. Mobus decomposes a system by the work done inside its boundary.
# This candidate does that: the network is five work processes, with
# named pass-ways at the boundary so no part both passes and transforms.
#
# The five processes. Publishing combines authoring acts and resolved
# references into versions. Archive holds every version and index: the
# network's memory, a stock. Linking copies a snapshot of each quoted
# version at publish time (§10.2). Notification sends a Webmention for
# each remote reference (§15.2). Discovery is the public list and the
# blogrolls, the protocol's only ways to find an origin (§11).
#
# Publishing carries no primitive. Combining fits the idea, but in
# Facets a Combining process consumes matter or energy, and every flow
# here is a message, so the kernel warned that it would ignore them.
#
# Where governance sits. Mobus's complex adaptive system expects a
# governance subsystem. Blygger refuses one by design: no counts, no
# ranking, no central list in the protocol (§16.8). So none is drawn.
# The research question in these terms: does a Discovery and ranking
# service outside the boundary come to act as the missing governance?
#
# Spec: Blygger protocol v0.4, a pre-1.0 draft. Section numbers refer
# to it.
system "Blygger network, by function" : Concrete/Social
domain "Blygs on the public web, read as the work processes they carry out together: publishing, keeping, quoting, notifying and being found"
description "The network of blygs as five work processes and four pass-ways. The quote graph is the structure; the archive is its memory; discovery is where the attention loop could close."

level Structure

# ── Pass-ways at the boundary ───────────────────────────────────────
interface "Authoring inlet"
    description "Where authoring acts and client software enter: a publisher writing through a client (§2, §3.2)."
interface "Public files"
    description "The static file surface every blyg serves to anyone (§4): feeds, item documents, archive indexes."
interface "Inbox"
    description "Where Webmentions land. Not part of the public files, so a crawl cannot see it (§15)."
interface "Directory"
    description "The public list and blogrolls as readers meet them (§11)."
interface "Retirement"
    description "Where superseded unpinned versions and withdrawn links leave the served record (§8.4, §9)."

# ── The five work processes ─────────────────────────────────────────
component Publishing
    description "Blygs writing items: each authoring act, with the references it carries, becomes a new version (§2, §5)."
component Archive primitive Buffering stock versions
    description "Every version and every archive index the network holds (§6.2, §8). Pinned versions stay forever; unpinned older ones are not served (§8.4)."
component Linking primitive Copying
    description "Publish-time resolution: a quote bakes a snapshot of the source version into the quoting item (§10.2). Stubs and forks record a reference without copying content (§10.6, §5.6)."
component Notification primitive Propelling
    description "A Webmention sent to the target for each remote reference (§15.2)."
component Discovery
    description "blygs.opml and the blogrolls: the ways an origin is found inside the protocol. A blogroll claims no completeness, ever (§11)."

# ── Outside ─────────────────────────────────────────────────────────
environment People
    description "Publishers and readers. Subscriptions are private (§11, §12.2)."
environment Clients
    description "The software that writes blygs, named in each manifest's generator string (§3.2)."
    grounding asserted "11 distinct clients across the 25 listed blygs, probe 2026-10-28"
environment Hosts
    description "Whatever serves the static files (§4)."
    grounding asserted "Blygger Studio runs 12 of the 25 listed blygs, probe 2026-10-28"
environment "Discovery and ranking services"
    description "Services on top of the protocol that read public files and publish an order (§16.6d). The candidate for the missing governance."
sink "Unserved history"
    description "What no route serves: unpinned older versions (§8.4) and the links a withdrawal drops (§9)."

# ── Entering ────────────────────────────────────────────────────────
flow People -> "Authoring inlet" : informational "publish event" substance publish_event
flow "Authoring inlet" -> Publishing : informational "publish event" substance publish_event
flow Clients -> "Authoring inlet" : informational "generator" substance generator
    description "Indicators: dependence on one client, client diversity over time."
flow "Authoring inlet" -> Publishing : informational "generator" substance generator
flow Hosts -> "Public files" : energy "hosting" substance hosting
    description "Indicator: dependence on one host."
flow "Public files" -> Archive : energy "hosting" substance hosting

# ── Inside: the work ────────────────────────────────────────────────
flow Publishing -> Archive : informational "new version" substance version
    description "Every authoring act adds a version; nothing is deleted (§5.2, §9)."
flow Archive -> Linking : informational "pinned version" substance pinned_version
    description "A source version that stays fetchable forever (§8)."
flow Archive -> Linking : informational "unpinned version" substance unpinned_version
    description "A source version that can stop being served; a quote of it is a veto held by a stranger (§10.2)."
flow Linking -> Publishing : informational "transclusion" substance transclusion
    description "The baked snapshot. Indicator: share of quotes that point at unpinned versions."
flow Linking -> Publishing : informational "stub_of" substance stub_of
    description "A response to one target item (§10.6). Indicator: share of stubs with no words of their own."
flow Linking -> Publishing : informational "forked_from" substance forked_from
    description "A copy started from a pinned version (§5.6)."
flow Publishing -> Notification : informational "remote reference" substance reference
    description "Each reference to another origin (§5.9)."
flow Archive -> Discovery : informational "blogroll" substance blogroll
    description "The curated list a publisher chose to show (§11)."

# ── Leaving ─────────────────────────────────────────────────────────
flow Archive -> "Public files" : informational "feed" substance feed
flow "Public files" -> People : informational "feed" substance feed
    description "What readers rebuild a blyg from (§5, §7)."
flow Archive -> "Public files" : informational "archive index" substance archive_index
flow "Public files" -> "Discovery and ranking services" : informational "archive index" substance archive_index
    description "Every item ever published, public to any service (§6.2)."
flow Notification -> Inbox : informational "mention" substance mention
flow Inbox -> People : informational "mention" substance mention
    description "A list, never a count (Venkatesh Rao, 2026-09-28 talk)."
flow Discovery -> Directory : informational "blygs.opml and blogrolls" substance directory
flow Directory -> People : informational "blygs.opml and blogrolls" substance directory
    description "Indicator: blygs reachable through blogrolls against only through the public list."
flow Archive -> Retirement : informational "unpinned older version" substance unpinned_version
flow Retirement -> "Unserved history" : informational "unpinned older version" substance unpinned_version
    description "Only a dated snapshot keeps these (§8.4)."
flow "Discovery and ranking services" -> People : informational "ranking"
    description "The order the protocol never carries (§16.8). Closes the loop: People publish links to what they were shown."

@lens mobus
