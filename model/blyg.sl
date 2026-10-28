# ── One blyg, one level down ────────────────────────────────────────
# The child of the "Responding blyg" component in ./blygger-network.sl.
# Updated from the spec v0.3 model of 2026-10-08 ("Blygger Blyg", old
# vault export) to spec v0.4: stubs (stub_of, §10.6), lineage
# (forked_from, §5.6), the withdrawal endcap (§9), pins (§8) and the
# generator string (§3.2). Element names are the spec's own terms, so
# the Lean in journal/ and this model can share one vocabulary
# (README.md, "Shared vocabulary").
#
# The environment is the parent's neighbours of the Responding blyg,
# name for name, as the decomposition contract asks: People, Clients,
# Hosts, Cited blyg, Discovery and ranking services, and Unserved history. Eight flows come in and six
# go out, the same count and kinds as the parent component's.
#
# Nearly every part is marked interface because a blyg is its file
# tree at its origin, servable as plain static files (§4): the files
# are the boundary.
system "Responding blyg" : Concrete/Technical
domain "One blyg: a versioned static file tree at one origin, with items, pins, an archive index, a feed and an optional blogroll"
description "A single blyg in the role of the one that quotes, stubs or forks: how a publish event becomes versions and files, how references to another blyg are resolved at publish time, and where its own history is kept or lost."

level Structure

# ── The parent's neighbours ─────────────────────────────────────────
environment People
    description "Publishers and readers, standing for the parent's People: the publisher's authoring acts come in, the feed and blogroll go out."
environment Clients
    description "The parent's Clients: the software that writes this blyg and names itself in the generator string (§3.2)."
environment Hosts
    description "The parent's Hosts: whatever serves the static files (§4)."
environment "Cited blyg"
    description "The parent's Cited blyg: another origin whose item versions this blyg transcludes, stubs or forks, and which receives this blyg's mentions."
environment "Discovery and ranking services"
    description "The parent's Discovery and ranking services: anyone outside the protocol who reads the archive index and may order what it finds (§16.6d)."
sink "Unserved history"
    description "The parent's Unserved history: versions and links no route serves any more."

# ── Writing: from authoring act to versions ─────────────────────────
component "Publish event" primitive Copying interface
    description "The act that creates a version (§2). An edit makes version N+1 with a bare counter (§5.2, §16.8); a withdrawal makes an endcap; a pin promises one version forever. The write side is the client's own, never protocol (§16.6)."
component "Publish-time resolution" primitive Copying interface
    description "Fetches the referenced version of another blyg's item once, at publish time, and bakes it into the thread (§10.2). Every reference is the shape origin, id, version (§5.9). Nothing is fetched at read time (§10.4)."
component "Webmention sender" primitive Propelling interface
    description "Sends one mention for each remote reference in a new version (§15.2). Fire and forget: publishing never waits on it."

# ── State: the files the blyg serves ────────────────────────────────
component "Item document" primitive Buffering interface
    description "items/{id}.json, the canonical document for one item: its latest version, its kind (fragment, thread or withdrawn) and its references (§5). Served 200 forever once published, even after withdrawal (§4)."
component "Pinned version document" primitive Buffering
    description "items/{id}/v{n}.json, served only for pinned versions and then forever (§8). A pin is irrevocable and survives later edits and withdrawal (§8, §9). Only a pinned version can be named by forked_from (§5.6)."
component "Archive index" primitive Copying interface
    description "items/index.json: every item ever published, withdrawn ones included, with no window (§6.2). The surface a reader reconciles against."
component Feed primitive Copying interface
    description "feed.xml, RSS 2.0 with the blyg namespace (§7): a window on recent publish events, not the full record."
component Blogroll interface
    description "blogroll.opml, optional: the subscriptions the publisher chose to show. Curated, and it claims no completeness, ever (§11)."
component Manifest primitive Buffering interface
    description "blyg.json, the one fixed file name (§4, §6.1). It locates the rest of the surface and carries the generator string, name/version of the client (§3.2)."

# ── In: the eight crossings of the parent component ─────────────────
flow People -> "Publish event" : informational "publish event"
    description "An authoring act: a new item, an edit, a withdrawal, a reversal, or a pin."
flow Clients -> Manifest : informational "generator"
    description "The client writes its name and version into the manifest (§3.2). Readers must not gate any behaviour on it."
flow Hosts -> "Item document" : energy "hosting"
    description "Storage and serving for the static files (§4). Drawn into the item documents, the files that grow with every version."
flow "Cited blyg" -> "Publish-time resolution" : informational "pinned transclusion" substance pinned_transclusion
    description "A pinned version of a remote item, baked as a snapshot (§10.2). Its source stays fetchable forever (§8)."
flow "Cited blyg" -> "Publish-time resolution" : informational "unpinned transclusion" substance unpinned_transclusion
    description "An unpinned version of a remote item, baked the same way. The snapshot survives, but the source can stop being served (§10.2, §10.4)."
flow "Cited blyg" -> "Publish-time resolution" : informational "stub_of" substance stub_of
    description "The one target a stub declares itself a response to (§10.6). A thread only; a stub of a stub is nesting."
flow "Cited blyg" -> "Publish-time resolution" : informational "forked_from" substance forked_from
    description "The pinned version a new item was copied from (§5.6). Publishers should check the pin at publish time with one conditional fetch."
flow "Cited blyg" -> Feed : informational "re-emission" substance re-emission
    description "An imported item put in this blyg's own feed. Forbidden: imported items are never re-emitted (§13.5). Drawn so its indicator has a flow to name; it should stay empty."

# ── Inside: from publish event to files ─────────────────────────────
flow "Publish event" -> "Item document" : informational "new version" substance version
    description "Version N+1 of an item, written as its new canonical document (§5.2)."
flow "Publish event" -> "Item document" : informational "withdrawal endcap" substance endcap
    description "A version with empty content and kind withdrawn (§9). It empties transclusions, omits stub_of, keeps page and forked_from. Withdrawal is reversible by a later version."
flow "Publish event" -> "Pinned version document" : informational "pin" substance pin
    description "The promise to serve one named version forever (§8)."
flow "Item document" -> "Pinned version document" : informational "pinned version" substance version
    description "The version the pin freezes, copied out to its own file before later edits supersede it (§8)."
flow "Publish event" -> "Archive index" : informational "index entry" substance index_entry
    description "The item's id, kind and current version, added or updated in the archive index (§6.2)."
flow "Publish event" -> Feed : informational "feed entry" substance feed_entry
    description "The publish event announced in the feed (§7)."
flow "Publish event" -> Blogroll : informational "blogroll edit" substance blogroll
    description "Showing a subscription is a deliberate publishing act, opt-in per subscription (§11)."
flow "Publish-time resolution" -> "Item document" : informational "reference" substance reference
    description "The baked snapshot and the reference written into the new version: transclusions, stub_of or forked_from (§5.9, §10.2)."
flow "Publish-time resolution" -> "Webmention sender" : informational "remote reference" substance reference
    description "Each reference whose origin is not this blyg's own (§2, §15.2). Same-origin references send no mention."

# ── Out: the six crossings of the parent component ─────────────────
flow "Webmention sender" -> "Cited blyg" : informational "mention"
    description "A Webmention to the cited blyg's endpoint, if it has one (§15.1, §15.2). It lands in that blyg's inbox, not its public files."
flow "Archive index" -> "Discovery and ranking services" : informational "archive index" substance index
    description "The full archive index, public so any reader, crawler or service may read it (§6.2)."
flow Feed -> People : informational "feed" substance feed
    description "The feed document readers poll (§7, §12.3)."
flow Blogroll -> People : informational "blogroll" substance blogroll
    description "The published blogroll (§11)."
flow "Item document" -> "Unserved history" : informational "unpinned older version" substance unpinned_version
    description "A version superseded by an edit and never pinned. No route serves it again (§8.4)."
flow "Item document" -> "Unserved history" : informational "withdrawal endcap" substance endcap
    description "The transclusions and stub_of a withdrawal endcap drops (§9). Pinned versions keep theirs (§8)."

# ── Relations that are not transfers ────────────────────────────────
flow Manifest -> Feed "locates" mere
    description "The manifest says where the feed lives when it is not at the default path (§6.1)."
flow Manifest -> "Archive index" "locates" mere
    description "The manifest says where the archive index lives (§6.1)."

@lens mobus
