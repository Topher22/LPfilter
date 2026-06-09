# Design Log — FIR Filter Refinement

This document tracks design iterations as filter parameters (tap count, cutoff frequency) are adjusted to meet requirements.

---

## Iteration 1 — Initial Design (5 taps, Fc = 1000 Hz)

**Date:** [Date]  
**Parameters:**
- N_taps = 5
- Fc = 1000 Hz
- Wn = 0.25

**Results:**
- REQ-01 (≥20 dB @ 2000 Hz): **[PASS/FAIL]** — Attenuation = [X] dB
- REQ-02 (<3 dB @ 200 Hz): **[PASS/FAIL]** — Attenuation = [X] dB
- REQ-04 (latency ≤ 5 cycles): **PASS** (by design — 5 taps = 5 cycles)

**Decision:**
- [Continue to VHDL / Adjust parameters]
- [Reason if adjusted]

**Artifacts:**
- `docs/waveforms/frequency_response_iter1.png`
- Coefficients: h = [?, ?, ?, ?, ?]

---

## Iteration 2 — [Description if needed]

**Date:** [Date]  
**Parameters:**
- N_taps = [X]
- Fc = [X] Hz
- Wn = [X]

**Results:**
- REQ-01: **[PASS/FAIL]** — Attenuation = [X] dB
- REQ-02: **[PASS/FAIL]** — Attenuation = [X] dB

**Decision:**
- [Continue / Adjust]

**Artifacts:**
- `docs/waveforms/frequency_response_iter2.png`
- Coefficients: h = [?, ?, ?, ?, ?]

---

## Final Design (approved)

**Date:** [Date]  
**Parameters:**
- N_taps = 5
- Fc = 1000 Hz
- All requirements PASS

**Frequency Response Plot:** `docs/waveforms/frequency_response.png`

**Final Coefficients (Q1.15):**
```
h0 = [X]
h1 = [X]
h2 = [X]
h3 = [X]
h4 = [X]
```

Ready for VHDL implementation.