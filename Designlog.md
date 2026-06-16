# Design Log — FIR Filter Refinement (MATLAB SIM)

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
- REQ-03 (no overflow):  NOT CONSIDERED
- REQ-04 (latency ≤ 5 cycles): NOT CONSIDERED


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
- REQ-03 (no overflow):  NOT CONSIDERED
- REQ-04 (latency ≤ 5 cycles): NOT CONSIDERED

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

## Iteration 3 — [7 taps, Fc = 1000 Hz]

**Date:** [10.06.2026]  
**Parameters:**
- N_taps = [9]
- Fc = [1000] Hz
- Wn = [Wn = 0.25]

**Results:**
- REQ-01: **PASS** — Attenuation = [--20.67] dB
- REQ-02: **PASS** — Attenuation = [-0.17] dB
- REQ-03 (no overflow):  NOT CONSIDERED
- REQ-04 (latency ≤ 5 cycles): NOT CONSIDERED

**Decision:**
- Accepted filter number
- HF attenuation sufficient (REQ-01)

**Artifacts:**
- `docs/waveforms/frequency_response_iter3.png`
- Coefficients: h = 
[ h(1) = 0
  h(2) = 626
  h(3) = 3338
  h(4) = 7565
  h(5) = 9711
  h(6) = 7565
  h(7) = 3338
  h(8) = 626
  h(9) = 0]

---

## Final Design (approved)

**Date:** [11.06.2026]  
**Parameters:**
- N_taps = 9
- Fc = 1000 Hz
- All requirements PASS

**Frequency Response Plots:** 
- `docs/waveforms/frequency_response_iter3.png`
- `docs/waveforms/TC-01: 200 Hz Sine (Passband).png`
- `docs/waveforms/TC-02: 2000 Hz Sine (Stopband).png`
- `docs/waveforms/TC-03: Mixed 200 Hz + 2000 Hz Signal.png`
- `docs/waveforms/TC-05: Impulse Response — REQ-04 Verification.png`

**Final Coefficients (Q1.15):**
```
h(1) = 0
h(2) = 626
h(3) = 3338
h(4) = 7565
h(5) = 9711
h(6) = 7565
h(7) = 3338
h(8) = 626
h(9) = 0

```
Ready for VHDL implementation.

# Design Log — FIR Filter Refinement (VHDL Testbench)

Aldec will be used to simulate the FPGA and testbench. A pipelined structure was decided upon as it ensure the 9 cycles are completed before the Sums and Products are processed as pushed to the output port.
The VHDL design whas been implemented and tested with its testbench correspondent. 


## TC01 - 200 Hz Sinewave
**Date:** [15.06.2026]  
**Parameters:**
- Expected Outcome: Signal is let through i.e. replicated at output with attenuation < -3dB
- TC-01 focuses on a low frequency 200HZ sine wave
- All requirements were fulfilled

**Waveform:** 
- 
**Final Coefficients (Q1.15):**
```

