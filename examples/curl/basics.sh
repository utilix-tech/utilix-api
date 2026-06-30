#!/usr/bin/env bash
# Utilix API — Common utilities (curl examples)

API="https://api.utilix.tech/v1"
KEY="utx_your_api_key_here"

# --- Hashing ---
curl -s -X POST "$API/hash" \
  -H "Authorization: Bearer $KEY" \
  -H "Content-Type: application/json" \
  -d '{"text": "hello world", "algorithm": "sha256"}' | jq '.hash'

# --- Base64 encode/decode ---
curl -s -X POST "$API/encode/base64" \
  -H "Authorization: Bearer $KEY" \
  -H "Content-Type: application/json" \
  -d '{"text": "Hello, Utilix!"}' | jq '.encoded'

curl -s -X POST "$API/decode/base64" \
  -H "Authorization: Bearer $KEY" \
  -H "Content-Type: application/json" \
  -d '{"text": "SGVsbG8sIFV0aWxpeCE="}' | jq '.decoded'

# --- UUID ---
curl -s "$API/generate/uuid" \
  -H "Authorization: Bearer $KEY" | jq '.uuid'

# --- Password generator ---
curl -s -X POST "$API/generate/password" \
  -H "Authorization: Bearer $KEY" \
  -H "Content-Type: application/json" \
  -d '{"length": 24, "symbols": true, "numbers": true}' | jq '.password'

# --- JSON format ---
curl -s -X POST "$API/json/format" \
  -H "Authorization: Bearer $KEY" \
  -H "Content-Type: application/json" \
  -d '{"json": "{\"name\":\"Alice\",\"age\":30}"}' | jq -r '.formatted'

# --- Case conversion ---
curl -s -X POST "$API/text/case" \
  -H "Authorization: Bearer $KEY" \
  -H "Content-Type: application/json" \
  -d '{"text": "hello world example", "to": "camelCase"}' | jq '.result'

# --- Unix time ---
curl -s -X POST "$API/time/from-unix" \
  -H "Authorization: Bearer $KEY" \
  -H "Content-Type: application/json" \
  -d '{"timestamp": 1720000000}' | jq .

# --- Cron next runs ---
curl -s -X POST "$API/time/cron-next" \
  -H "Authorization: Bearer $KEY" \
  -H "Content-Type: application/json" \
  -d '{"expression": "0 9 * * 1-5", "count": 5, "timezone": "America/New_York"}' | jq '.runs'

# --- JWT decode ---
curl -s -X POST "$API/jwt/decode" \
  -H "Authorization: Bearer $KEY" \
  -H "Content-Type: application/json" \
  -d '{"token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkFsaWNlIn0.fake"}' | jq '.payload'

# --- Color parse ---
curl -s -X POST "$API/color/parse" \
  -H "Authorization: Bearer $KEY" \
  -H "Content-Type: application/json" \
  -d '{"color": "#4f46e5"}' | jq '{hex, rgb, hsl}'

# --- WCAG contrast check ---
curl -s -X POST "$API/color/contrast" \
  -H "Authorization: Bearer $KEY" \
  -H "Content-Type: application/json" \
  -d '{"foreground": "#1a1a2e", "background": "#ffffff"}' | jq '{ratio, passesAA, passesAAA}'
