# Proof journal

The Lean in blyg-watch, written in public with Verso's blog genre (Verso `v4.28.0`, Lean `v4.28.0`). Each entry is a Verso post; its `lean` code blocks are checked when the journal builds. Shingai writes every Lean line.

Output goes to `site/proof/journal/`, linked from `site/proof.html`.

## Add an entry

1. Copy `Journal/Entries/Entry1.lean` to `Journal/Entries/Entry2.lean`. Change the `#doc (Post) "..."` title and the `date`, and give its `leanInit` and `lean` blocks a new name (for example `entry2`).
2. Import it in `Journal/Entries.lean`: `import Journal.Entries.Entry2`.
3. List it in `Main.lean` under `"entries" Journal.Entries with`, one line below `Journal.Entries.Entry1`.

A `lean` fence must hold real Lean: Verso fails on an empty one, and on one that holds only a comment. Until a slot has its line, keep it a plain fence (no language), as in Entry 1.

## Build and regenerate the HTML

```
cd journal
./build.sh
```

`build.sh` runs `lake build` (checks every entry), then `lake exe generate-journal --output ../site/proof/journal`, then copies `journal.css` next to the HTML. Refresh http://127.0.0.1:4410/proof/journal/ to see it. Hovers and proof states need the page served, not opened as a file.

## How long it takes (on this Mac, 2026-10-28)

| Step | Wall time |
|---|---|
| First `lake update` (clones Verso, SubVerso, MD4Lean, Plausible) | 100 s |
| Clean `lake build` (Verso and the journal) | 42 s |
| Rebuild after editing one entry | about 4 s |
| `lake exe generate-journal` | under 1 s |

No Mathlib, so there is no `lake exe cache get`.

## Styling

`journal.css` sits on top of `site/style.css` (linked as `../../style.css`), so the journal shares the site's tokens and top bar. Verso's own highlighting and hover styles are left alone.
