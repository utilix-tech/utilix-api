/**
 * Utilix REST API — Node.js examples using fetch
 * Node 18+ (native fetch), or install node-fetch for older versions
 */

const API = 'https://api.utilix.tech/v1'
const KEY = 'utx_your_api_key_here'

async function call<T = unknown>(path: string, body?: object, method = 'POST'): Promise<T> {
  const res = await fetch(`${API}${path}`, {
    method,
    headers: {
      'Authorization': `Bearer ${KEY}`,
      'Content-Type': 'application/json',
    },
    body: body ? JSON.stringify(body) : undefined,
  })

  if (!res.ok) {
    const err = await res.json().catch(() => ({}))
    throw Object.assign(new Error(`${res.status} ${res.statusText}`), { status: res.status, body: err })
  }

  return res.json() as T
}

// --- Token estimation ---
const est = await call<{ tokens: number; cost: number }>('/ai/estimate-tokens', {
  text: 'The quick brown fox jumps over the lazy dog.',
  model: 'gpt-4o',
})
console.log(`Tokens: ${est.tokens}, Cost: $${est.cost?.toFixed(8)}`)

// --- PII detection + redaction ---
const text = 'Contact alice@example.com or call 555-123-4567.'
const scan = await call<{ findings: Array<{ type: string; value: string }> }>('/ai/detect-pii', { text })
console.log(`\nPII: ${scan.findings.length} findings`)
scan.findings.forEach(f => console.log(`  ${f.type}: ${f.value}`))

const redacted = await call<{ text: string }>('/ai/redact-pii', { text, replacement: '[REDACTED]' })
console.log(`Redacted: ${redacted.text}`)

// --- JSON diff ---
const diff = await call<{ entries: Array<{ op: string; path: string; oldValue?: unknown; newValue?: unknown }> }>('/ai/diff-json', {
  before: JSON.stringify({ plan: 'free', limit: 100 }),
  after: JSON.stringify({ plan: 'pro', limit: 5000 }),
})
const changes = diff.entries.filter(e => e.op !== 'unchanged')
console.log(`\nDiff: ${changes.length} changes`)
changes.forEach(c => console.log(`  ${c.op.padEnd(8)} ${c.path}: ${c.oldValue} → ${c.newValue}`))

// --- Rerank chunks ---
const ranked = await call<{ ranked: Array<{ chunk: string; score: number }> }>('/ai/rerank', {
  query: 'machine learning training',
  chunks: [
    'Python was released in 1991.',
    'Supervised learning needs labeled data.',
    'The coffee machine needs descaling.',
    'Neural networks learn from datasets.',
  ],
})
console.log('\nReranked:')
ranked.ranked.forEach(r => console.log(`  ${r.score.toFixed(3)}  ${r.chunk.slice(0, 50)}`))

// --- UUID ---
const uuidResult = await call<{ uuid: string }>('/generate/uuid', undefined, 'GET')
console.log(`\nUUID: ${uuidResult.uuid}`)

// --- Retry helper ---
async function callWithRetry<T>(path: string, body?: object, retries = 3): Promise<T> {
  for (let i = 0; i < retries; i++) {
    try {
      return await call<T>(path, body)
    } catch (err: unknown) {
      const e = err as { status?: number }
      if (e.status === 429 && i < retries - 1) {
        console.log(`Rate limited, retrying in 5s...`)
        await new Promise(r => setTimeout(r, 5000))
      } else throw err
    }
  }
  throw new Error('Max retries exceeded')
}

export { call, callWithRetry }
