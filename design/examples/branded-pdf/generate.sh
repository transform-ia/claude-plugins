#!/usr/bin/env bash
# Generates branded.pdf from content.md using Pandoc + XeLaTeX
# Usage: bash generate.sh [input.md] [output.pdf]
# Requires: pandoc >= 3.0, xelatex (TeX Live / MiKTeX)

set -euo pipefail

INPUT="${1:-content.md}"
OUTPUT="${2:-branded.pdf}"
TEMPLATE="template.latex"
HIGHLIGHT="tango"          # tango | pygments | breezeDark | espresso

# Font preferences (fallback chain is in the template itself)
MAINFONT="Helvetica Neue"  # macOS built-in; Linux: install ttf-mscorefonts-installer
MONOFONT="JetBrains Mono"  # https://www.jetbrains.com/lp/mono/ (free)

# ── Dependency check ──────────────────────────────────────────────────────────
for cmd in pandoc xelatex; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "ERROR: '$cmd' not found." >&2
    case "$cmd" in
      pandoc)  echo "  Install: https://pandoc.org/installing.html" >&2 ;;
      xelatex) echo "  Install: https://tug.org/texlive/ or MiKTeX" >&2 ;;
    esac
    exit 1
  fi
done

PANDOC_VER=$(pandoc --version | head -1 | awk '{print $2}')
echo "Pandoc   : ${PANDOC_VER}"
echo "Input    : ${INPUT}"
echo "Template : ${TEMPLATE}"
echo "Output   : ${OUTPUT}"
echo ""

# ── Validate input files ───────────────────────────────────────────────────────
[[ -f "${INPUT}" ]]    || { echo "ERROR: ${INPUT} not found" >&2; exit 1; }
[[ -f "${TEMPLATE}" ]] || { echo "ERROR: ${TEMPLATE} not found" >&2; exit 1; }

# ── Generate ──────────────────────────────────────────────────────────────────
pandoc "${INPUT}" \
  --template="${TEMPLATE}" \
  \
  --pdf-engine=xelatex \
  --pdf-engine-opt="-interaction=nonstopmode" \
  --pdf-engine-opt="-halt-on-error" \
  \
  --variable "mainfont=${MAINFONT}" \
  --variable "sansfont=${MAINFONT}" \
  --variable "monofont=${MONOFONT}" \
  --variable "fontsize=12pt" \
  \
  --highlight-style="${HIGHLIGHT}" \
  \
  --toc \
  --toc-depth=3 \
  --number-sections \
  \
  --standalone \
  --dpi=300 \
  \
  --output="${OUTPUT}"

echo ""
echo "Done: ${OUTPUT}"
