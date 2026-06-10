# Design Log — FIR Filter Refinement

This document tracks design iterations as filter parameters (tap count, cutoff frequency) are adjusted to meet requirements.

---

## Iteration 1 — Initial Design (5 taps, Fc = 1000 Hz)

**Date:** [07.06.2026]  
**Parameters:**
- N_taps = 5
- Fc = 1000 Hz
- Wn = 0.25

**Results:**
- REQ-01 (≥20 dB @ 2000 Hz): **FAIL** — Attenuation = [-7.27] dB
- REQ-02 (<3 dB @ 200 Hz): **PASS** — Attenuation = [-0.07] dB
- REQ-04 (latency ≤ 5 cycles): **PASS** (by design — 5 taps = 5 cycles)

**Decision:**
- Adjusting parameters: N_filter --> 7
- HF attenuation not sufficient (REQ-01)

**Artifacts:**
- `docs/waveforms/frequency_response_iter1.png`
- Coefficients: h = 
[ h(1) = 805
  h(2) = 7680
  h(3) = 15798
  h(4) = 7680
  h(5) = 805]

---

## Iteration 2 — [5 taps, Fc = 1000 Hz]

**Date:** [09.06.2026]  
**Parameters:**
- N_taps = [7]
- Fc = [1000] Hz
- Wn = [Wn = 0.25]

**Results:**
- REQ-01: **FAIL** — Attenuation = [-13.39] dB
- REQ-02: **PASS** — Attenuation = [-0.13] dB

**Decision:**
- Adjusting parameters: N_taps --> 9
- HF attenuation not sufficient (REQ-01)

**Artifacts:**
- `docs/waveforms/frequency_response_iter2.png`
- Coefficients: h = 
[ h(1) = 278
  h(2) = 2286
  h(3) = 8029
  h(4) = 11582
  h(5) = 8029
  h(6) = 2286
  h(7) = 278]

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