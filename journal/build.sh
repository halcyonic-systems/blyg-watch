#!/bin/sh
# Check every entry with Lean, then write the HTML into site/proof/journal/.
set -eu
cd "$(dirname "$0")"
lake build
lake exe generate-journal --output ../site/proof/journal
cp journal.css ../site/proof/journal/journal.css
