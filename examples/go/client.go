// Utilix REST API — Go examples using net/http
package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"time"
)

const (
	apiBase = "https://api.utilix.tech/v1"
	apiKey  = "utx_your_api_key_here"
)

// call makes an authenticated POST request and decodes the response into dest.
func call(path string, body any, dest any) error {
	payload, err := json.Marshal(body)
	if err != nil {
		return err
	}

	req, err := http.NewRequest("POST", apiBase+path, bytes.NewReader(payload))
	if err != nil {
		return err
	}
	req.Header.Set("Authorization", "Bearer "+apiKey)
	req.Header.Set("Content-Type", "application/json")

	client := &http.Client{Timeout: 30 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	raw, _ := io.ReadAll(resp.Body)
	if resp.StatusCode >= 400 {
		return fmt.Errorf("API error %d: %s", resp.StatusCode, raw)
	}

	return json.Unmarshal(raw, dest)
}

func main() {
	// --- Token estimation ---
	var estResult struct {
		Tokens int     `json:"tokens"`
		Cost   float64 `json:"cost"`
	}
	if err := call("/ai/estimate-tokens", map[string]any{
		"text":  "The quick brown fox jumps over the lazy dog.",
		"model": "gpt-4o",
	}, &estResult); err != nil {
		fmt.Println("Error:", err)
	} else {
		fmt.Printf("Tokens: %d, Cost: $%.8f\n", estResult.Tokens, estResult.Cost)
	}

	// --- PII detection ---
	var piiResult struct {
		Findings []struct {
			Type  string `json:"type"`
			Value string `json:"value"`
		} `json:"findings"`
	}
	text := "Contact alice@example.com or call 555-123-4567."
	if err := call("/ai/detect-pii", map[string]any{"text": text}, &piiResult); err != nil {
		fmt.Println("Error:", err)
	} else {
		fmt.Printf("\nPII findings: %d\n", len(piiResult.Findings))
		for _, f := range piiResult.Findings {
			fmt.Printf("  %s: %s\n", f.Type, f.Value)
		}
	}

	// --- Redact PII ---
	var redactResult struct {
		Text string `json:"text"`
	}
	if err := call("/ai/redact-pii", map[string]any{
		"text":        text,
		"replacement": "[REDACTED]",
	}, &redactResult); err != nil {
		fmt.Println("Error:", err)
	} else {
		fmt.Printf("Redacted: %s\n", redactResult.Text)
	}

	// --- JSON diff ---
	v1 := `{"plan":"free","limit":100}`
	v2 := `{"plan":"pro","limit":5000}`
	var diffResult struct {
		Entries []struct {
			Op       string `json:"op"`
			Path     string `json:"path"`
			OldValue any    `json:"oldValue"`
			NewValue any    `json:"newValue"`
		} `json:"entries"`
	}
	if err := call("/ai/diff-json", map[string]any{"before": v1, "after": v2}, &diffResult); err != nil {
		fmt.Println("Error:", err)
	} else {
		fmt.Println("\nDiff:")
		for _, e := range diffResult.Entries {
			if e.Op != "unchanged" {
				fmt.Printf("  %-8s %s: %v → %v\n", e.Op, e.Path, e.OldValue, e.NewValue)
			}
		}
	}

	// --- Hash ---
	var hashResult struct {
		Hash string `json:"hash"`
	}
	if err := call("/hash", map[string]any{
		"text":      "hello world",
		"algorithm": "sha256",
	}, &hashResult); err != nil {
		fmt.Println("Error:", err)
	} else {
		fmt.Printf("\nSHA-256: %s\n", hashResult.Hash)
	}

	// --- Rerank ---
	var rerankResult struct {
		Ranked []struct {
			Chunk string  `json:"chunk"`
			Score float64 `json:"score"`
		} `json:"ranked"`
	}
	if err := call("/ai/rerank", map[string]any{
		"query": "machine learning training",
		"chunks": []string{
			"Python was released in 1991.",
			"Supervised learning needs labeled data.",
			"The coffee machine needs descaling.",
			"Neural networks learn from datasets.",
		},
	}, &rerankResult); err != nil {
		fmt.Println("Error:", err)
	} else {
		fmt.Println("\nReranked:")
		for _, r := range rerankResult.Ranked {
			text := r.Chunk
			if len(text) > 50 {
				text = text[:50]
			}
			fmt.Printf("  %.3f  %s\n", r.Score, text)
		}
	}
}
