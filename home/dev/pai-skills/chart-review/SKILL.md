---
name: chart-review
description: Review ECharts clinical trial visualizations via JSON API. USE WHEN reviewing charts, checking review status, batch reviewing categories, or analyzing chart correctness in the announcements project.
---

# Chart Review - Agent-Driven Chart QA

Review clinical trial ECharts visualizations via the views-server JSON API. No browser needed.

**Requires:** views-server running with `DEV=1` (review routes are devMode-only).

---

## API Reference

Base URL: `http://localhost:8080`

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/charts/api` | GET | List all trials with chart definitions |
| `/charts/reviews/api` | GET | List all reviews |
| `/charts/review` | POST | Submit single review |
| `/charts/review/batch` | POST | Submit batch of reviews |
| `/charts/review/resolve` | POST | Resolve a review |
| `/charts/review/clear` | POST | Clear all reviews |

### Query Parameters for `/charts/api`

- `category` — Filter by category: `flow`, `primary`, `safety`, `baseline`, `secondary`, `geographic`, `other`
- `page` — Page number (default 1)
- `pageSize` — Trials per page (default 20)

---

## Workflow

### 1. Check Status

```bash
curl -s localhost:8080/charts/reviews/api | jq '{openCount, resolvedCount}'
```

### 2. List Charts by Category

```bash
curl -s 'localhost:8080/charts/api?category=safety&pageSize=5' | jq '.trials[] | {nctId, charts: [.charts[] | {id, title, type, category, reviewed}]}'
```

### 3. Inspect a Chart's ECharts Option

Each chart in the API response has an `option` field containing the full ECharts JSON config. Parse it to verify data correctness:

```bash
curl -s 'localhost:8080/charts/api?pageSize=1' | jq '.trials[0].charts[0].option | fromjson | {series: [.series[] | {name, type, data: .data[:3]}]}'
```

### 4. Submit Reviews

**Single:**
```bash
curl -s -X POST localhost:8080/charts/review \
  -H 'Content-Type: application/json' \
  -d '{"nctId":"NCT...","chartId":"ae-serious","tags":["looks-good"],"comment":"verified","user":"claude"}'
```

**Batch:**
```bash
curl -s -X POST localhost:8080/charts/review/batch \
  -H 'Content-Type: application/json' \
  -d '{"reviews":[
    {"nctId":"NCT...","chartId":"ae-serious","tags":["looks-good"],"comment":"verified","user":"claude"},
    {"nctId":"NCT...","chartId":"ae-all","tags":["needs-fix"],"comment":"Y-axis wrong","user":"claude"}
  ]}'
```

### 5. Resolve Reviews

```bash
curl -s -X POST localhost:8080/charts/review/resolve \
  -H 'Content-Type: application/json' \
  -d '{"nctId":"NCT...","chartId":"ae-serious","user":"claude"}'
```

---

## Review Tags

| Tag | When to Use |
|-----|-------------|
| `looks-good` | Chart renders correctly, data appears accurate |
| `needs-fix` | General issue requiring attention |
| `wrong-data` | Data values don't match source |
| `wrong-scale` | Axis scale misleading or incorrect |
| `missing-data` | Expected data series or categories missing |
| `layout-issue` | Labels cut off, overlap, or unreadable |
| `wrong-type` | Chart type inappropriate for the data |

---

## What to Check

When reviewing a chart's `option` JSON:

1. **Series data** — Are values present and reasonable? No NaN, no negatives where impossible
2. **Axis labels** — Do categories match the trial arms/groups?
3. **Title/subtitle** — Descriptive and not truncated
4. **Legend** — All series labeled correctly
5. **Chart type** — Appropriate for the data (bar for counts, forest for hazard ratios, etc.)
6. **Scale** — Y-axis starts at 0 for bar charts, reasonable range for all types

---

## Tips

- Use `jq` for all API interaction — structured output, easy filtering
- The `option` field is a JSON string (double-encoded) — use `fromjson` in jq to parse it
- Review by category to stay focused: safety charts have different concerns than baseline charts
- Forest plots: check that CI whiskers and point estimates are correctly positioned
- Bar charts: check that all arms/groups are represented
- Globe charts have no `option` (they use custom rendering) — skip or just verify site counts
