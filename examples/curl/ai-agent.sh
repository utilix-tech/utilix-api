#!/usr/bin/env bash
# Utilix API — AI Agent tools (curl examples)

API="https://api.utilix.tech/v1"
KEY="utx_your_api_key_here"

# --- Token estimation ---
curl -s -X POST "$API/ai/estimate-tokens" \
  -H "Authorization: Bearer $KEY" \
  -H "Content-Type: application/json" \
  -d '{"text": "The quick brown fox jumps over the lazy dog.", "model": "gpt-4o"}' | jq .

# --- Trim to token budget ---
curl -s -X POST "$API/ai/trim-to-tokens" \
  -H "Authorization: Bearer $KEY" \
  -H "Content-Type: application/json" \
  -d '{"text": "Long document...", "maxTokens": 500, "strategy": "end"}' | jq .

# --- Chunk text ---
curl -s -X POST "$API/ai/chunk-text" \
  -H "Authorization: Bearer $KEY" \
  -H "Content-Type: application/json" \
  -d '{"text": "Your long document here...", "maxTokens": 256, "overlap": 32}' | jq '.chunks | length'

# --- Compress HTML ---
curl -s -X POST "$API/ai/compress-html" \
  -H "Authorization: Bearer $KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "html": "<html><head><script>track()</script><style>body{color:red}</style></head><body><h1>Hello</h1></body></html>",
    "removeScripts": true,
    "removeStyles": true,
    "collapseWhitespace": true
  }' | jq '{html: .html, savedPct: .savingsPct}'

# --- Detect PII ---
curl -s -X POST "$API/ai/detect-pii" \
  -H "Authorization: Bearer $KEY" \
  -H "Content-Type: application/json" \
  -d '{"text": "Contact alice@example.com or call 555-123-4567"}' | jq '.findings[] | {type, value}'

# --- Redact PII ---
curl -s -X POST "$API/ai/redact-pii" \
  -H "Authorization: Bearer $KEY" \
  -H "Content-Type: application/json" \
  -d '{"text": "Email: alice@example.com, SSN: 123-45-6789", "replacement": "[REDACTED]"}' | jq '.text'

# --- Detect secrets ---
curl -s -X POST "$API/ai/detect-secrets" \
  -H "Authorization: Bearer $KEY" \
  -H "Content-Type: application/json" \
  -d '{"text": "OPENAI_KEY=sk-proj-abc123xyzDEF456"}' | jq '.findings'

# --- Rerank chunks ---
curl -s -X POST "$API/ai/rerank" \
  -H "Authorization: Bearer $KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "machine learning training data",
    "chunks": [
      "Python was created in 1991.",
      "Supervised learning requires labeled training data.",
      "The coffee machine needs descaling.",
      "Neural networks learn from large datasets."
    ]
  }' | jq '.ranked[] | {score, chunk: .chunk[:50]}'

# --- JSON diff ---
curl -s -X POST "$API/ai/diff-json" \
  -H "Authorization: Bearer $KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "before": "{\"plan\": \"free\", \"limit\": 100}",
    "after":  "{\"plan\": \"pro\",  \"limit\": 5000}"
  }' | jq '.entries[] | select(.op != "unchanged")'
