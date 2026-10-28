import Lake
open Lake DSL

-- Core Lean only: no Mathlib, no SSF. Keep it that way until a theorem needs more.
package «blyg-watch» where
  leanOptions := #[
    ⟨`autoImplicit, false⟩
  ]

@[default_target]
lean_lib «Blygger» where
  srcDir := "."
