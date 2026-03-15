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

# ── Placeholder images ────────────────────────────────────────────────────────
# Create missing images referenced in content.md so Pandoc has real files.
# Tries Pillow first, then ImageMagick, then skips with a notice.
make_placeholder() {
  local file="$1"
  local label="$2"
  local width="${3:-800}"
  local height="${4:-450}"

  if [[ -f "$file" ]]; then return; fi

  if python3 -c "from PIL import Image" &>/dev/null 2>&1; then
    python3 - "$file" "$label" "$width" "$height" <<'PY'
import sys
from PIL import Image, ImageDraw, ImageFont

file, label, w, h = sys.argv[1], sys.argv[2], int(sys.argv[3]), int(sys.argv[4])

img = Image.new("RGB", (w, h), "#EEF4FF")
d   = ImageDraw.Draw(img)

# Border
d.rectangle([0, 0, w - 1, h - 1], outline="#003366", width=3)

# Inner dashed border
pad = 20
d.rectangle([pad, pad, w - pad - 1, h - pad - 1], outline="#CCE0FF", width=1)

# Label (centre)
try:
    font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 28)
    small = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 16)
except Exception:
    font = small = ImageFont.load_default()

bbox = d.textbbox((0, 0), label, font=font)
tw, th = bbox[2] - bbox[0], bbox[3] - bbox[1]
d.text(((w - tw) // 2, (h - th) // 2 - 10), label, fill="#003366", font=font)

sub = "[placeholder image]"
sbbox = d.textbbox((0, 0), sub, font=small)
sw = sbbox[2] - sbbox[0]
d.text(((w - sw) // 2, (h - th) // 2 + th + 10), sub, fill="#6C7280", font=small)

img.save(file)
PY
  elif command -v convert &>/dev/null; then
    convert -size "${width}x${height}" xc:"#EEF4FF" \
      -stroke "#003366" -strokewidth 3 -draw "rectangle 0,0 $((width-1)),$((height-1))" \
      -fill "#003366" -font "DejaVu-Sans" -pointsize 28 \
      -gravity Center -annotate 0 "$label" \
      "$file" 2>/dev/null
  else
    echo "  (skipped $file — install python3-pil or imagemagick to generate)"
    return
  fi

  echo "  Created placeholder: $file"
}

echo "Checking images…"
make_placeholder architecture.png  "System Architecture Diagram"
make_placeholder metrics-chart.png "Metrics Chart"
echo ""

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
