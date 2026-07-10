# Utilix REST API

> 118+ deterministic developer utility tools over HTTP. No LLM calls, no side effects.

[![API Status](https://img.shields.io/badge/status-live-brightgreen)](https://api.utilix.tech)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**Base URL:** `https://api.utilix.tech/v1`

**[utilix.tech](https://utilix.tech)** · [Docs](https://www.utilix.tech/docs) · [API Reference](https://api.utilix.tech/docs) · [SDK](https://www.npmjs.com/package/@utilix-tech/sdk) · [MCP](https://www.npmjs.com/package/@utilix-tech/mcp)

---

## Authentication

All API requests require an API key passed in the `Authorization` header:

```
Authorization: Bearer utx_your_api_key_here
```

Get your API key at **[utilix.tech/dashboard](https://utilix.tech/dashboard)**.

---

## Rate Limits

| Plan    | Requests / day | Notes                        |
|---------|----------------|------------------------------|
| Free    | 1,000          | Shared across all API keys   |
| Pro     | 10,000         | Shared across all API keys   |
| Team    | Unlimited      | —                            |

**Headers returned on every response:**

```
X-RateLimit-Limit: 10000
X-RateLimit-Remaining: 9813
X-RateLimit-Reset: midnight UTC
```

When you exceed the limit, the API returns `429 Too Many Requests`. Retry after the number of seconds in the `Retry-After` header.

---

## Errors

All errors follow a consistent shape:

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Field 'text' is required.",
    "field": "text"
  }
}
```

| Status | Code                | Meaning                                      |
|--------|---------------------|----------------------------------------------|
| 400    | `VALIDATION_ERROR`  | Missing or invalid input                     |
| 401    | `UNAUTHORIZED`      | Missing or invalid API key                   |
| 413    | `PAYLOAD_TOO_LARGE` | Request body exceeds plan limit              |
| 422    | `PROCESSING_ERROR`  | Input valid but tool returned an error       |
| 429    | `RATE_LIMITED`      | Too many requests                            |
| 500    | `INTERNAL_ERROR`    | Server-side failure                          |

---

## Quick Start

### curl

```bash
curl -X POST https://api.utilix.tech/v1/ai/estimate-tokens \
  -H "Authorization: Bearer utx_your_key" \
  -H "Content-Type: application/json" \
  -d '{"text": "Hello, world!"}'
```

Response:

```json
{
  "tokens": 4,
  "chars": 13,
  "model": "gpt-4o",
  "cost": 0.00000006
}
```

---

## Endpoints by Category

### AI Agent

| Method | Path | Description |
|--------|------|-------------|
| POST | `/ai/estimate-tokens` | Token count + cost estimate |
| POST | `/ai/trim-to-tokens` | Trim text to token budget |
| POST | `/ai/chunk-text` | Split into overlapping chunks |
| POST | `/ai/compress-html` | Strip scripts/styles/comments |
| POST | `/ai/compress-markdown` | Collapse blanks, strip frontmatter |
| POST | `/ai/compress-json` | Remove nulls/empty fields |
| POST | `/ai/summarize` | Extractive summarization |
| POST | `/ai/extract-urls` | Extract all URLs |
| POST | `/ai/extract-json` | Pull JSON from unstructured text |
| POST | `/ai/extract-tables` | HTML tables → JSON |
| POST | `/ai/extract-entities` | NER: emails, phones, IPs, dates |
| POST | `/ai/rerank` | TF-IDF chunk reranking |
| POST | `/ai/score-relevance` | Score text relevance to query |
| POST | `/ai/expand-query` | Query expansion with synonyms |
| POST | `/ai/diff-json` | Structural JSON diff |
| POST | `/ai/validate-schema` | JSON Schema validation |
| POST | `/ai/repair-json` | Fix malformed JSON |
| POST | `/ai/flatten-json` | Flatten nested JSON |
| POST | `/ai/merge-json` | Deep-merge JSON objects |
| POST | `/ai/sanitize-html` | Remove dangerous tags |
| POST | `/ai/deduplicate-lines` | Remove duplicate lines |
| POST | `/ai/extract-keywords` | TF-IDF keyword extraction |
| POST | `/ai/detect-pii` | PII detection |
| POST | `/ai/redact-pii` | PII redaction |
| POST | `/ai/detect-secrets` | Leaked key/token detection |
| POST | `/ai/detect-prompt-injection` | Prompt injection scoring |

### JSON

| Method | Path | Description |
|--------|------|-------------|
| POST | `/json/format` | Format / prettify JSON |
| POST | `/json/minify` | Minify JSON |
| POST | `/json/to-csv` | JSON → CSV |
| POST | `/json/to-typescript` | JSON → TypeScript interface |
| POST | `/json/to-go` | JSON → Go struct |
| POST | `/json/to-python` | JSON → Python dataclass |
| POST | `/json/path` | JSONPath query |
| POST | `/json/validate` | JSON syntax validation |

### Encoding

| Method | Path | Description |
|--------|------|-------------|
| POST | `/encode/base64` | Base64 encode |
| POST | `/decode/base64` | Base64 decode |
| POST | `/encode/url` | URL encode |
| POST | `/decode/url` | URL decode |
| POST | `/encode/html` | HTML entity encode |
| POST | `/decode/html` | HTML entity decode |

### Hashing

| Method | Path | Description |
|--------|------|-------------|
| POST | `/hash` | MD5 / SHA-1 / SHA-256 / SHA-512 |
| POST | `/hash/password` | bcrypt hash |
| POST | `/hash/verify` | bcrypt verify |

### Text

| Method | Path | Description |
|--------|------|-------------|
| POST | `/text/word-count` | Word, char, sentence count |
| POST | `/text/case` | Case conversion |
| POST | `/text/slugify` | Slugify text |
| POST | `/text/diff` | Line diff |
| POST | `/text/html-to-markdown` | Convert HTML to Markdown |
| POST | `/text/line-ops` | Sort, reverse, shuffle lines |

### Time

| Method | Path | Description |
|--------|------|-------------|
| POST | `/time/from-unix` | Unix → human-readable |
| POST | `/time/cron-parse` | Parse cron expression |
| POST | `/time/cron-next` | Next N cron fire times |
| POST | `/time/date-diff` | Difference between two dates |
| POST | `/time/timezone` | Timezone conversion |

### Generators

| Method | Path | Description |
|--------|------|-------------|
| GET | `/generate/uuid` | UUID v4 |
| POST | `/generate/password` | Secure password |
| GET | `/generate/ulid` | ULID |
| POST | `/generate/qr` | QR code (PNG or SVG) |

### Color

| Method | Path | Description |
|--------|------|-------------|
| POST | `/color/parse` | Parse any color format |
| POST | `/color/contrast` | WCAG contrast ratio |
| POST | `/color/palette` | Generate color palette |
| POST | `/color/shades` | Generate color shades |

---

## Examples

See the [`examples/`](./examples/) directory for complete code:

- [`examples/curl/`](./examples/curl/) — shell scripts for every category
- [`examples/python/`](./examples/python/) — `requests` library
- [`examples/node/`](./examples/node/) — `fetch` / `axios`
- [`examples/go/`](./examples/go/) — `net/http`

---

## SDKs

If you prefer a typed SDK over raw HTTP:

| Language | Package | Install |
|----------|---------|---------|
| Node.js | [`@utilix-tech/sdk`](https://www.npmjs.com/package/@utilix-tech/sdk) | `npm i @utilix-tech/sdk` |
| Python | [`utilix-sdk`](https://pypi.org/project/utilix-sdk/) | `pip install utilix-sdk` |

---

## License

MIT
