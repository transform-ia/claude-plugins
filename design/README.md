# Design Plugin

Brand identity and visual design tools for any company or project.

## Skills

### `branding`

Thorough brand identity session. Asks 18 questions across foundation, audience,
personality, visual direction, and context, then generates a complete brand kit:
`brand.md` (strategy + guidelines), `brand-prompts.md` (Nano Banana 2 logo and
photography prompts), and `brand-tokens.json` (design tokens + CSS variables).

**Invoke:** `/design:branding`
**Output files:** `brand.md`, `brand-prompts.md`, `brand-tokens.json`

## Examples

### `examples/branded-pdf/`

Complete Pandoc + XeLaTeX pipeline for turning Markdown into a branded
professional PDF with Acme Corp corporate styling (#003366 blue).

| File | Purpose |
| --- | --- |
| `content.md` | Rich Markdown demo covering every supported feature |
| `template.latex` | Branded LaTeX template (custom title page, header/footer, fonts) |
| `generate.sh` | One-command PDF generation |

**Quick start:**

```bash
cd examples/branded-pdf
bash generate.sh          # produces branded.pdf
```

Requires: `pandoc >= 3.0`, `xelatex` (TeX Live or MiKTeX).
