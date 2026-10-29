import VersoBlog

open Verso Genre Blog

-- Shingai writes every Lean line in this journal.
-- THE SLOT: the plain fence under "The first Lean block" is a placeholder.
-- To fill it, change its opening line to ```lean entry1 and replace the placeholder
-- with your Lean. Verso refuses a `lean` fence that holds no Lean (not even a comment),
-- so the slot stays a plain, unchecked fence until it has a real line in it.

#doc (Post) "Entry 1: the first line" =>

%%%
authors := ["Shingai Thornton"]
date := {year := 2026, month := 10, day := 28}
%%%

```leanInit entry1
```

This entry holds the first Lean line of blyg-watch.

# The first Lean block

First line: what is the smallest thing to state first, and why?

Here are three potential candidates that I've been considering, with the third one being dropped after consideration. I'd like feedback on which option seems best, or if there are others I should consider before committing and moving forward. Open an issue (https://github.com/halcyonic-systems/blyg-watch/issues), or ping me in the SIGFPT Discord.

```lean entry1
structure Reference where
  origin : String
  id : String
  version : Nat
```
Our first candidate is that the smallest thing to state is a Reference. Because this protocol is referential in nature, referential by design, it's worth considering this as our first primitive. Fundamentally, what this journal needs to be tracking is links, and this requires reasoning about references.

```lean entry1
structure Item where
  id : String
  versions : List String
  withdrawn : Bool
```
Our second candidate is that fundamentally this journal is about the act of publishing. In this case, we are focused not on the references to items, but on the items themselves: the actual posts.


```lean entry1
structure Version where
  item : String
  number : Nat
  pinned : Bool
```
Our third considered candidate, which got dropped, is about versions. Because item is an ID with no origin, it has no way of saying which blyg a version lives on. Adding an origin would fix that, but then a Version is just a Reference plus a pinned flag, so it is not a noun of its own. And so this won't work for our purposes.
