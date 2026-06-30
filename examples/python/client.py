"""
Utilix REST API — Python examples using requests
pip install requests
"""

import requests
import json

API = "https://api.utilix.tech/v1"
KEY = "utx_your_api_key_here"

HEADERS = {
    "Authorization": f"Bearer {KEY}",
    "Content-Type": "application/json",
}


def call(path: str, body: dict | None = None, method: str = "POST") -> dict:
    url = f"{API}{path}"
    resp = requests.request(method, url, headers=HEADERS, json=body)
    resp.raise_for_status()
    return resp.json()


# --- Token estimation ---
result = call("/ai/estimate-tokens", {"text": "The quick brown fox jumps over the lazy dog."})
print(f"Tokens: {result['tokens']}, Cost: ${result.get('cost', 0):.8f}")

# --- PII detection + redaction ---
text = "Contact alice@example.com or call 555-123-4567. SSN: 987-65-4321."
scan = call("/ai/detect-pii", {"text": text})
print(f"\nPII found: {len(scan['findings'])} items")
for f in scan["findings"]:
    print(f"  {f['type']}: {f['value']}")

redacted = call("/ai/redact-pii", {"text": text, "replacement": "[REDACTED]"})
print(f"Redacted: {redacted['text']}")

# --- Secret scanning ---
code = 'const key = "sk-proj-abc123xyzDEF456"\nconst token = "ghp_realtoken123"'
secrets = call("/ai/detect-secrets", {"text": code})
print(f"\nSecrets: {len(secrets['findings'])} found")
for s in secrets["findings"]:
    print(f"  {s['type']}: {s['redacted']}")

# --- JSON diff ---
v1 = json.dumps({"plan": "free", "limit": 100, "features": ["export"]})
v2 = json.dumps({"plan": "pro",  "limit": 5000, "features": ["export", "api", "webhooks"]})
diff = call("/ai/diff-json", {"before": v1, "after": v2})
changes = [e for e in diff["entries"] if e["op"] != "unchanged"]
print(f"\nDiff: {len(changes)} changes")
for c in changes:
    print(f"  {c['op']:8s}  {c['path']}")

# --- Chunk + rerank ---
long_text = "Vector databases store high-dimensional embeddings. " * 20
chunks_result = call("/ai/chunk-text", {"text": long_text, "maxTokens": 64, "overlap": 8})
chunks = [c["text"] for c in chunks_result["chunks"]]
print(f"\nChunked into {len(chunks)} pieces")

ranked = call("/ai/rerank", {
    "query": "vector database embeddings",
    "chunks": chunks[:5],  # top 5 for demo
})
for r in ranked["ranked"][:3]:
    print(f"  score={r['score']:.3f} | {r['chunk'][:60]}")

# --- Hashing ---
h = call("/hash", {"text": "hello world", "algorithm": "sha256"})
print(f"\nSHA-256: {h['hash']}")

# --- UUID ---
uuid_result = call("/generate/uuid", method="GET")
print(f"UUID: {uuid_result['uuid']}")

# --- Retry on rate limit ---
import time

def call_with_retry(path: str, body: dict | None = None, retries: int = 3) -> dict:
    for attempt in range(retries):
        try:
            return call(path, body)
        except requests.HTTPError as e:
            if e.response.status_code == 429 and attempt < retries - 1:
                wait = int(e.response.headers.get("Retry-After", 5))
                print(f"Rate limited. Retrying in {wait}s...")
                time.sleep(wait)
            else:
                raise
    raise RuntimeError("Max retries exceeded")
