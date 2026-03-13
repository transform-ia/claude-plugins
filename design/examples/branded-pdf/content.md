---
title: "Modern Software Engineering"
subtitle: "A Complete Pandoc Markdown Feature Showcase"
author:
  - "Alexandra Chen — Principal Engineer"
  - "Marcus Webb — Technical Writer"
date: "2026-03-13"
abstract: |
  This reference document demonstrates every Markdown feature supported by
  Pandoc for PDF generation: headings, emphasis, lists, tables, code blocks
  with syntax highlighting in multiple languages, mathematical typesetting,
  blockquotes, footnotes, definition lists, images, and special characters.
keywords: [pandoc, markdown, latex, reference, pdf]
lang: en-US
toc: true
toc-depth: 3
numbersections: true
---

# Introduction

Software engineering has evolved dramatically over the past two decades.
From waterfall methodologies to continuous delivery, from monolithic
architectures to microservices, and from bare-metal deployments to
serverless functions — the industry has undergone a complete transformation.

This document demonstrates **every Markdown feature** supported by Pandoc's
PDF pipeline, serving as both a living reference and a visual regression test
for branded document generation workflows.

> This document was automatically generated using Pandoc + XeLaTeX with
> a custom corporate template. The source is a single Markdown file.

## Purpose and Scope

The goals of this showcase are threefold:

1. Demonstrate every Markdown element supported by Pandoc
2. Serve as a visual regression test for custom LaTeX templates
3. Provide a copy-paste starting point for real technical documents

## How to Read This Document

Each section introduces a Markdown feature and shows it in use. The source
file `content.md` should be read alongside the rendered PDF to understand
how each construct translates to the printed page.

---

# Text Formatting and Typography

## Basic Emphasis

Markdown supports four levels of text emphasis:

- **Bold text** is produced with `**double asterisks**`
- *Italic text* uses `*single asterisks*` or `_underscores_`
- ***Bold and italic*** combined: `***triple asterisks***`
- ~~Strikethrough~~ text uses `~~double tildes~~`

Combinations work naturally in prose: the ***critically important***
observation that ~~legacy code is always someone else's fault~~ technical
debt accumulates when **velocity is prioritized** over *sustainability*.

## Inline Code and Monospace

Use `inline code` with backticks for variable names like `user_id`,
function calls like `getData()`, command-line tools like `git rebase -i`,
file paths like `/etc/nginx/nginx.conf`, and HTTP verbs like `POST /api/v2/users`.

## Links and References

Inline links: [Pandoc documentation](https://pandoc.org) and
[the LaTeX project](https://www.latex-project.org).

Reference-style links: visit [GitHub][gh] for source code.

[gh]: https://github.com "GitHub — Where the world builds software"

Auto-links: <https://pandoc.org> and email: <team@acmecorp.example>

## Footnotes

Pandoc supports inline footnotes^[This is a simple inline footnote.] that
appear at the bottom of the page. Named footnotes are also supported.[^named]

[^named]: This is a named footnote. It can contain **rich formatting**,
  code like `pandoc --version`, and even multiple paragraphs.

  Second paragraph of the named footnote.

---

# Lists and Structure

## Unordered Lists

Simple unordered list:

- Containerization with Docker and Kubernetes
- Infrastructure as Code using Terraform and Pulumi
- Observability through distributed tracing and structured logging
- GitOps workflows with ArgoCD and Flux

Multi-level unordered list:

- **Frontend Technologies**
  - React 19 with concurrent rendering
  - TypeScript 5.x for type safety
    - Strict mode enabled
    - Path aliases configured
  - Vite for fast development builds
- **Backend Technologies**
  - Go for high-performance services
  - PostgreSQL as the primary data store
    - PgBouncer for connection pooling
    - Read replicas for analytics workloads
  - Redis for caching and session storage

## Ordered Lists

Ordered lists auto-number correctly regardless of the numbers used:

1. Define the problem statement
2. Gather requirements from stakeholders
3. Design the architecture
4. Write the implementation
5. Write tests
6. Deploy to staging
7. Run acceptance tests
8. Deploy to production
9. Monitor and iterate

## Task Lists

Project status for Q1 2026:

- [x] Define API contracts (OpenAPI 3.1 spec)
- [x] Set up CI/CD pipeline (GitHub Actions)
- [x] Implement authentication service (JWT + refresh tokens)
- [x] Database migrations (12 completed)
- [ ] Implement payment service (in progress)
- [ ] Rate limiting and throttling
- [ ] Admin dashboard
- [ ] Performance testing (k6 load tests)
- [ ] Security audit
- [ ] Production launch

## Definition Lists

API Gateway
:   A server that acts as an API front-end, receiving API calls,
    enforcing throttling and security policies, passing requests
    to the back-end service, and then returning the response.

Eventual Consistency
:   A consistency model that guarantees that, if no new updates
    are made to a given data item, eventually all accesses to that
    item will return the last updated value.
:   Compare with *strong consistency*, where all nodes see the
    same data at the same time.

Circuit Breaker
:   A design pattern that automatically detects failures and
    prevents cascading failures by stopping requests to a failing
    service. Named after the electrical component.

Service Mesh
:   A dedicated infrastructure layer for handling service-to-service
    communication, providing load balancing, service discovery,
    and observability.

---

# Code and Technical Content

## Python — Async Pipeline

```python
"""Async data processing pipeline with retry logic."""

from __future__ import annotations

import asyncio
import logging
from dataclasses import dataclass, field
from datetime import datetime, UTC

logger = logging.getLogger(__name__)


@dataclass
class PipelineConfig:
    """Configuration for the data processing pipeline."""

    batch_size: int = 100
    max_retries: int = 3
    retry_delay: float = 1.0
    concurrency: int = 10
    tags: list[str] = field(default_factory=list)


@dataclass
class ProcessingResult:
    """Result of a single processing attempt."""

    item_id: str
    success: bool
    processed_at: datetime = field(default_factory=lambda: datetime.now(UTC))
    error: str | None = None


async def process_batch(
    items: list[dict],
    config: PipelineConfig,
) -> list[ProcessingResult]:
    """Process items with concurrency control and exponential backoff."""
    semaphore = asyncio.Semaphore(config.concurrency)

    async def process_one(item: dict) -> ProcessingResult:
        async with semaphore:
            for attempt in range(config.max_retries):
                try:
                    await asyncio.sleep(0.01)  # simulate I/O
                    return ProcessingResult(item_id=item["id"], success=True)
                except Exception as exc:
                    if attempt == config.max_retries - 1:
                        return ProcessingResult(
                            item_id=item["id"],
                            success=False,
                            error=str(exc),
                        )
                    await asyncio.sleep(config.retry_delay * 2**attempt)
            raise RuntimeError("unreachable")

    return await asyncio.gather(*[process_one(i) for i in items])
```

## JavaScript — React Component

```javascript
// BrandTokenProvider.jsx
// Injects design tokens from brand-tokens.json into CSS custom properties

import { createContext, useContext, useEffect, useState } from "react";

const BrandContext = createContext(null);

/**
 * Loads brand tokens and injects them as CSS custom properties.
 * @param {{ tokens: object, children: React.ReactNode }} props
 */
export function BrandProvider({ tokens, children }) {
  const [loaded, setLoaded] = useState(false);

  useEffect(() => {
    if (!tokens?.css) return;
    const style = document.createElement("style");
    style.id = "brand-tokens";
    style.textContent = tokens.css;
    document.head.appendChild(style);
    setLoaded(true);
    return () => document.getElementById("brand-tokens")?.remove();
  }, [tokens]);

  return (
    <BrandContext.Provider value={{ tokens, loaded }}>
      {children}
    </BrandContext.Provider>
  );
}

export function useBrand() {
  const ctx = useContext(BrandContext);
  if (!ctx) throw new Error("useBrand must be used within BrandProvider");
  return ctx;
}
```

## Shell — Blue/Green Deployment

```bash
#!/usr/bin/env bash
# deploy.sh — Zero-downtime blue/green deployment
set -euo pipefail

ENVIRONMENT="${1:?Usage: $0 <env> <tag>}"
IMAGE_TAG="${2:?Usage: $0 <env> <tag>}"
APP_NAME="acme-api"
NAMESPACE="${APP_NAME}-${ENVIRONMENT}"

log()  { echo "[$(date -u +%H:%M:%SZ)] $*"; }
fail() { echo "ERROR: $*" >&2; exit 1; }

[[ "$ENVIRONMENT" =~ ^(staging|production)$ ]] \
  || fail "Environment must be 'staging' or 'production'"

CURRENT=$(kubectl get service "${APP_NAME}" -n "$NAMESPACE" \
  -o jsonpath='{.spec.selector.slot}' 2>/dev/null || echo "blue")
NEW_SLOT=$([[ "$CURRENT" == "blue" ]] && echo "green" || echo "blue")

log "Deploying to slot: $NEW_SLOT (current: $CURRENT)"

kubectl set image deployment/"${APP_NAME}-${NEW_SLOT}" \
  "${APP_NAME}=registry.acmecorp.example/${APP_NAME}:${IMAGE_TAG}" \
  -n "$NAMESPACE"

kubectl rollout status deployment/"${APP_NAME}-${NEW_SLOT}" \
  -n "$NAMESPACE" --timeout=300s

kubectl patch service "${APP_NAME}" -n "$NAMESPACE" \
  --type=merge \
  -p "{\"spec\":{\"selector\":{\"slot\":\"${NEW_SLOT}\"}}}"

log "Traffic switched to ${NEW_SLOT} (${IMAGE_TAG})"
```

## SQL — Analytics Query

```sql
-- Monthly revenue with year-over-year comparison (PostgreSQL 15+)

WITH monthly_revenue AS (
    SELECT
        date_trunc('month', o.created_at)        AS month,
        p.category,
        SUM(oi.quantity * oi.unit_price)          AS revenue,
        COUNT(DISTINCT o.customer_id)             AS unique_customers
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.id
    JOIN products    p  ON p.id = oi.product_id
    WHERE o.status = 'completed'
      AND o.created_at >= date_trunc('year', NOW()) - INTERVAL '1 year'
    GROUP BY 1, 2
),
yoy AS (
    SELECT
        cy.month,
        cy.category,
        cy.revenue                                        AS revenue_cy,
        py.revenue                                        AS revenue_py,
        ROUND((cy.revenue - COALESCE(py.revenue, 0))
              / NULLIF(py.revenue, 0) * 100, 2)           AS yoy_pct,
        SUM(cy.revenue) OVER (
            PARTITION BY cy.category
            ORDER BY cy.month
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        )                                                 AS cumulative
    FROM monthly_revenue cy
    LEFT JOIN monthly_revenue py
           ON py.month    = cy.month - INTERVAL '1 year'
          AND py.category = cy.category
)
SELECT
    to_char(month, 'YYYY-MM') AS period,
    category,
    revenue_cy,
    revenue_py,
    yoy_pct,
    RANK() OVER (PARTITION BY month ORDER BY revenue_cy DESC) AS rank,
    cumulative
FROM yoy
ORDER BY month DESC, revenue_cy DESC;
```

---

# Tables

## Simple Comparison Table

| Feature          | Kubernetes  | Nomad    | ECS       |
|:-----------------|:-----------:|:--------:|:---------:|
| Learning curve   | High        | Medium   | Low       |
| Multi-cloud      | Yes         | Yes      | AWS only  |
| GPU support      | Yes         | Yes      | Yes       |
| Stateful apps    | Yes         | Limited  | Yes       |
| Service mesh     | Istio/Envoy | Consul   | App Mesh  |
| Cost overhead    | High        | Low      | Medium    |
| CNCF project     | Yes         | No       | No        |

: Orchestration platform comparison

## Metrics Table

| Metric        | P50   | P95   | P99   | SLO       |
|:--------------|------:|------:|------:|----------:|
| API latency   | 12 ms | 45 ms | 89 ms | < 100 ms  |
| DB query      | 3 ms  | 18 ms | 52 ms | < 50 ms   |
| Error rate    | ---   | ---   | ---   | < 0.1%    |
| Throughput    | ---   | ---   | ---   | > 1000 rps|

: System performance metrics (last 30 days)

## Table with Merged Cells (Raw LaTeX)

```{=latex}
\begin{table}[H]
\centering
\caption{Regional Sales Performance (Q1 vs Q2 2026)}
\renewcommand{\arraystretch}{1.4}
\begin{tabular}{>{\bfseries}llrr}
\toprule
\rowcolor{TableHead}
\color{white}Region &
\color{white}Market &
\color{white}Q1 Revenue &
\color{white}Q2 Revenue \\
\midrule
\multirow{3}{*}{Americas}
  & United States  & \$4.2M & \$4.8M \\
  & Canada         & \$0.9M & \$1.1M \\
  & Latin America  & \$0.5M & \$0.7M \\
\midrule
\multirow{3}{*}{EMEA}
  & United Kingdom & \$2.1M & \$1.9M \\
  & Germany        & \$1.8M & \$2.2M \\
  & Rest of EMEA   & \$1.2M & \$1.4M \\
\midrule
\multirow{2}{*}{APAC}
  & Japan          & \$1.5M & \$1.6M \\
  & Australia      & \$0.8M & \$0.9M \\
\midrule
\multicolumn{2}{l}{\textbf{Total}} & \textbf{\$13.0M} & \textbf{\$14.6M} \\
\bottomrule
\end{tabular}
\end{table}
```

---

# Mathematics

## Inline Mathematics

The time complexity of quicksort is $O(n \log n)$ on average, though
$O(n^2)$ in the worst case. For a hash map with load factor $\alpha$,
the expected lookup time is $\Theta(1 + \alpha)$.

Euler's identity $e^{i\pi} + 1 = 0$ connects five fundamental constants.
The normal distribution PDF is
$f(x) = \frac{1}{\sigma\sqrt{2\pi}} e^{-\frac{1}{2}\left(\frac{x-\mu}{\sigma}\right)^2}$.

## Display Mathematics

The gradient descent update rule:

$$\theta_{t+1} = \theta_t - \eta \nabla_\theta \mathcal{L}(\theta_t)$$

The softmax function used in multi-class classification:

$$\sigma(\mathbf{z})_i = \frac{e^{z_i}}{\sum_{j=1}^{K} e^{z_j}}
\quad \text{for } i = 1, \ldots, K$$

Singular value decomposition of $\mathbf{A} \in \mathbb{R}^{m \times n}$:

$$\mathbf{A} = \mathbf{U} \boldsymbol{\Sigma} \mathbf{V}^{\top}$$

The Navier--Stokes equations (conservation form):

$$\begin{aligned}
\frac{\partial \rho}{\partial t} + \nabla \cdot (\rho \mathbf{v})
  &= 0 \\
\frac{\partial (\rho \mathbf{v})}{\partial t}
  + \nabla \cdot (\rho \mathbf{v} \otimes \mathbf{v})
  &= -\nabla p + \mu \nabla^2 \mathbf{v} \\
\frac{\partial E}{\partial t} + \nabla \cdot ((E + p)\,\mathbf{v})
  &= 0
\end{aligned}$$

---

# Blockquotes

Simple blockquote:

> "The most dangerous kind of waste is the waste we do not recognize."
> --- Shigeo Shingo

Nested blockquotes:

> The question of whether machines can think is about as interesting as
> the question of whether submarines can swim.
>
> > --- Edsger W. Dijkstra
>
> This quote highlights that anthropomorphism leads to confused thinking
> about the nature of computation.

Multi-paragraph blockquote:

> **On Technical Debt**
>
> Shipping first-time code is like going into debt. A little debt speeds
> development so long as it is paid back promptly with a rewrite.
>
> The danger occurs when the debt is not repaid. Every minute spent on
> not-quite-right code counts as interest on that debt.
>
> --- Ward Cunningham, 1992

---

# Images

![System architecture diagram placeholder](architecture.png){width=80%}

Images support captions, size attributes, and labels:

![Scatter plot showing correlation between deployment frequency and mean time
to recovery. Teams deploying more frequently show lower
MTTR.](metrics-chart.png){width=90% #fig:metrics}

*Note: replace `architecture.png` and `metrics-chart.png` with actual image
files in the same directory.*

---

# Special Features

## Horizontal Rules

Produced by three dashes on their own line:

---

## Headings H4 Through H6

#### H4: Implementation Details

This is an H4 heading, used for fine-grained sections within a subsection.

##### H5: Edge Case Handling

H5 headings are used for detailed technical specifications and sub-topics.

###### H6: Internal Notes

H6 is the smallest heading level, rarely used in practice but available.

---

# Summary

This document demonstrated the full range of Pandoc Markdown features:

| Feature                           | Status |
|:----------------------------------|:------:|
| Headings H1 through H6            | Done   |
| Bold, italic, strikethrough       | Done   |
| Ordered and unordered lists       | Done   |
| Nested lists (3 levels)           | Done   |
| Task lists                        | Done   |
| Definition lists                  | Done   |
| Inline and fenced code            | Done   |
| Syntax highlighting (4 languages) | Done   |
| Markdown tables                   | Done   |
| Merged cells (raw LaTeX)          | Done   |
| Display and inline math           | Done   |
| Blockquotes (nested)              | Done   |
| Footnotes                         | Done   |
| Links (inline + reference)        | Done   |
| Images with captions              | Done   |
| Horizontal rules                  | Done   |
| YAML frontmatter                  | Done   |

: Complete feature checklist

The generated PDF is produced with a single command: `bash generate.sh`
