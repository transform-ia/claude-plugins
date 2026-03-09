# Gemini + OCR Integration Patterns

## Gemini Go client
```go
import (
    "github.com/google/generative-ai-go/genai"
    "google.golang.org/api/option"
)

client, err := genai.NewClient(ctx, option.WithAPIKey(cfg.GeminiAPIKey))
defer client.Close()

model := client.GenerativeModel(cfg.GeminiModel) // "gemini-2.0-flash"
model.ResponseMIMEType = "application/json"
model.SystemInstruction = &genai.Content{
    Parts: []genai.Part{genai.Text(systemPrompt)},
}
```

## Image OCR flow (with Tesseract + Gemini)
1. Run Tesseract OCR on image bytes → raw text
2. Send to Gemini with BOTH image bytes AND OCR text as context
3. Gemini produces structured JSON

```go
parts := []genai.Part{
    genai.ImageData(mimeType, imageBytes),   // actual image
    genai.Text("OCR extracted text:\n" + rawText), // Tesseract context
    genai.Text("Please extract the invoice data."),
}
resp, err := model.GenerateContent(ctx, parts...)
```

## PDF flow (pdftotext → Gemini text-only)
- Use `pdftotext -layout input.pdf -` (poppler-utils) via `exec.Command`
- Send extracted text only to Gemini (no binary PDF — Go SDK doesn't support inline PDFs)

## Token usage — ALWAYS capture, even on error
```go
func ExtractInvoice(ctx, cfg, fileData, mimeType, rawText) (*InvoiceData, TokenUsage, error) {
    // ...
    resp, err := model.GenerateContent(ctx, parts...)

    // Capture usage BEFORE checking error
    usage := TokenUsage{}
    if resp != nil && resp.UsageMetadata != nil {
        usage.PromptTokens = int(resp.UsageMetadata.PromptTokenCount)
        usage.OutputTokens = int(resp.UsageMetadata.CandidatesTokenCount)
        usage.TotalTokens = int(resp.UsageMetadata.TotalTokenCount)
    }
    if err != nil {
        return nil, usage, fmt.Errorf("gemini: %w", err)
    }
    // ...
}
```

The processor MUST call `store.InsertGeminiUsage(...)` after every call, even on error.

## Structured JSON extraction
```go
model.ResponseMIMEType = "application/json"
// Parse response:
text := resp.Candidates[0].Content.Parts[0].(genai.Text)
var data InvoiceData
json.Unmarshal([]byte(text), &data)
```

## Issue conversation pattern
```go
chat := model.StartChat()
chat.History = existingMessages  // []genai.Content with role="user"/"model"
resp, err := chat.SendMessage(ctx, genai.Text(newUserMessage))
```

## Confidence score
- If `confidence_score < 0.7`, create a `low_confidence` issue in the DB

## Tesseract (gosseract)
```go
import "github.com/otiai10/gosseract/v2"
client := gosseract.NewClient()
defer client.Close()
client.SetImage(tmpFilePath) // needs a file path, not bytes
text, err := client.Text()
```
Requires CGO: `CGO_ENABLED=1` for build.
Install: `tesseract-ocr tesseract-ocr-eng` (Debian/Ubuntu)
