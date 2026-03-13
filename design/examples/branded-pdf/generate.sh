#!/usr/bin/env bash
# Generates branded.pdf from content.md using Pandoc + pdflatex
# Usage: bash generate.sh [input.md] [output.pdf]
#
# Ubuntu/Debian install (one-time):
#   sudo apt install pandoc \
#     texlive texlive-latex-extra \
#     texlive-fonts-recommended texlive-fonts-extra

set -euo pipefail

INPUT="${1:-content.md}"
OUTPUT="${2:-branded.pdf}"
TEMPLATE="template.latex"
HIGHLIGHT="tango"   # tango | pygments | breezeDark | espresso | kate

# ── Dependency check ──────────────────────────────────────────────────────────
for cmd in pandoc pdflatex; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "ERROR: '$cmd' not found." >&2
    case "$cmd" in
      pandoc)
        echo "  Ubuntu: sudo apt install pandoc" >&2
        echo "  Other:  https://pandoc.org/installing.html" >&2
        ;;
      pdflatex)
        echo "  Ubuntu: sudo apt install texlive texlive-latex-extra \\" >&2
        echo "                           texlive-fonts-recommended texlive-fonts-extra" >&2
        ;;
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
[[ -f "${INPUT}" ]]    || { echo "ERROR: ${INPUT} not found"    >&2; exit 1; }
[[ -f "${TEMPLATE}" ]] || { echo "ERROR: ${TEMPLATE} not found" >&2; exit 1; }

# ── Generate ──────────────────────────────────────────────────────────────────
pandoc "${INPUT}" \
  --template="${TEMPLATE}" \
  \
  --pdf-engine=pdflatex \
  --pdf-engine-opt="-interaction=nonstopmode" \
  --pdf-engine-opt="-halt-on-error" \
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
