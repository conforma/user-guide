## Retro filing

When running as the `retro` agent, invoke the `retro-filing-policy` skill
before writing output. It is loaded by the derived retro harness and is the
enforcement layer; this pointer is only reinforcement. Scores 0–3 are
summary-only, while scores 4–5 remain subject to the upstream duplicate and
recently-closed checks before filing.
