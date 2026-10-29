"""The links one item document carries, named for the model's flows.

Only the three link kinds the question measures (README): quotes
(`transclusions`, §10.3), stubs (`stub_of`, §10.6) and forks
(`forked_from`, §5.6). Each kind is the label of a flow in `model/`, and
tests/test_names.py fails if one drifts. Not captured yet: plain links
(`links[]`, §10.3a) and generation sources (`generated[].sources[]`, §5.7).

Nothing else from the document is kept: no content, no `cited` (it carries
an excerpt and an author's name), no author.
"""

KINDS = ("transclusion", "stub_of", "forked_from")


def item_record(doc, origin):
    """One snapshot row for an item document fetched from `origin`."""
    return {
        "id": doc["id"],
        "kind": doc["kind"],
        "version": doc["version"],
        "pinned": sorted(c["version"] for c in doc.get("changelog", []) if c.get("pinned")),
        "edges": edges(doc, origin),
    }


def edges(doc, origin):
    out = [_edge("transclusion", ref, origin) for ref in doc.get("transclusions", [])]
    for kind in ("stub_of", "forked_from"):
        if doc.get(kind):
            out.append(_edge(kind, doc[kind], origin))
    return out


def _edge(kind, ref, origin):
    if "url" in ref and "id" not in ref:
        # A plain-web stub target (§10.6): a page, not a blyg item.
        return {"kind": kind, "to": {"url": ref["url"]}}
    # §10.3: an omitted origin means own-origin. Ids are scoped to their
    # origin before anything else is done with them (§13.1).
    return {"kind": kind,
            "to": {"origin": ref.get("origin") or origin, "id": ref["id"], "version": ref["version"]}}
