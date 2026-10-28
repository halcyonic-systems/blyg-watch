import VersoBlog
import Journal

open Verso Genre Blog Site Syntax

/-
Verso boilerplate: the page shell and the site map. No journal content lives here.
The shell reuses the main site's stylesheet (`site/style.css`) for its tokens and top bar,
then `journal.css` (copied in by `build.sh`) sets the journal's own layout.
Paths are relative to the journal root, `site/proof/journal/`, which `builtinHeader` sets as `<base>`.
-/
open Output Html Template Theme in
def theme : Theme := { Theme.default with
  primaryTemplate := do
    let postList :=
      match (← param? "posts") with
      | none => Html.empty
      | some html => {{ <section class="entries"> {{html}} </section> }}
    return {{
      <html lang="en">
        <head>
          <meta charset="utf-8"/>
          <meta name="viewport" content="width=device-width, initial-scale=1"/>
          <link rel="icon" href="data:,"/>
          <title>{{ (← param (α := String) "title") }} " · blyg-watch"</title>
          {{← builtinHeader }}
          <link rel="preconnect" href="https://fonts.googleapis.com"/>
          <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin="anonymous"/>
          <link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:wght@700&family=Inter:wght@400;500;600&family=JetBrains+Mono:wght@400&display=swap" rel="stylesheet"/>
          <link rel="stylesheet" href="../../style.css"/>
          <link rel="stylesheet" href="journal.css"/>
        </head>
        <body>
          <header class="bar">
            <div class="wrap bar-in">
              <a class="mark" href="../../index.html">"blyg-watch"</a>
              <nav aria-label="Path">
                <a class="n-question" href="../../question.html"><span class="n-num">"1"</span>"Question"</a>
                <a class="n-model" href="../../model.html"><span class="n-num">"2"</span>"Model"</a>
                <a class="n-proof" href="../../proof.html" aria-current="page"><span class="n-num">"3"</span>"Proof"</a>
                <a class="n-data" href="../../data.html"><span class="n-num">"4"</span>"Data"</a>
              </nav>
            </div>
          </header>
          <main class="sub-page s-proof journal">
            <div class="wrap">
              <p class="kicker k-step"><a href="./">"Proof journal"</a></p>
              {{← param "content" }}
              {{ postList }}
            </div>
          </main>
          <footer class="foot">
            <div class="wrap">
              <div class="foot-meta">
                <a href="../../proof.html">"Back to the Proof step"</a>
                <span>"Section numbers refer to Blygger spec v0.4, a pre-1.0 draft."</span>
              </div>
            </div>
          </footer>
        </body>
      </html>
    }}
  }

-- The front page, then the entries as a blog under `entries/`.
-- (At v4.28.0 a blog at the site root fails its traverse pass, so the entries sit one level down.)
def journal : Site := site Journal.FrontPage /
  "entries" Journal.Entries with
    Journal.Entries.Entry1

def main := blogMain theme journal
