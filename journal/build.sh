#!/bin/sh
# Check every entry with Lean, then write the HTML into site/proof/journal/.
set -eu
cd "$(dirname "$0")"
lake build
lake exe generate-journal --output ../site/proof/journal
cp journal.css ../site/proof/journal/journal.css

# Point the front page and the Proof page at the newest entry, so no link is kept by hand.
# Entry folders start with their date, so the last one in sort order is the newest.
latest=$(ls -d ../site/proof/journal/entries/*/ | sort | tail -n 1)
slug=$(basename "$latest")
title=$(sed -n 's:.*<title>\(.*\) · blyg-watch</title>.*:\1:p' "$latest/index.html" | head -n 1)
for page in ../site/index.html ../site/proof.html; do
  LINK="<a href=\"proof/journal/entries/$slug/\">$title</a>" perl -0pi -e \
    's{<!-- latest-entry -->.*?<!-- /latest-entry -->}{<!-- latest-entry -->$ENV{LINK}<!-- /latest-entry -->}s' "$page"
done
