# Requirements Rationale

> This document explains the origin, intent, and engineering reasoning behind each requirement defined for the VHDL FIR Low-Pass Filter project. It is a supplementary document to the main [README](./README.md).

---

## Table of Contents
1. [How Requirements Were Derived](#1-how-requirements-were-derived)
2. [Requirement Categories](#2-requirement-categories)
3. [Individual Requirement Rationale](#3-individual-requirement-rationale)
4. [Simplifications vs. DO-254](#4-simplifications-vs-do-254)
5. [What a Real Requirements Flow Would Look Like](#5-what-a-real-requirements-flow-would-look-like)

---

## 1. How Requirements Were Derived

In a real aerospace project, requirements flow **top-down** from aircraft-level needs:

```
Aircraft Need
    └── System Requirement
            └── Hardware Requirement  ← this project starts here
                    └── Implementation
                            └── Verification
```

For example:
- **Aircraft need:** Pilot must receive accurate altitude data
- **System requirement:** Sensor module shall output a clean signal with SNR > 40 dB
- **Hardware requirement:** Filter shall attenuate noise above 1 kHz by ≥ 20 dB ← REQ-01

Since this is a standalone portfolio project with no parent system above it, requirements were derived **bottom-up** by identifying the four fundamental questions that must be answered for any digital hardware design:

| Question | Category | Requirement |
|----------|----------|-------------|
| Does it do its job? | Functional | REQ-01, REQ-02 |
| Can it cause harm downstream? | Safety | REQ-03 |
| Does it behave in time? | Timing | REQ-04 |
| Can any of the above be proven? | Verification | REQ-05 |

---

## 2. Requirement Categories

### Functional Requirements
Define **what the hardware does** — the intended behaviour under normal operating conditions. Every design must have at least one functional requirement or it has no defined purpose.

### Safety Requirements
Define **what the hardware must never do** — constraints that prevent downstream harm. In aerospace, silent data corruption (e.g. overflow wrap-around) can be more dangerous than an outright failure, because the system continues operating with wrong data.

### Timing Requirements
Define **how fast the hardware must respond**. In real-time embedded systems, a correct output that arrives too late is equivalent to no output at all.

### Verification Requirements
Define **how confidence in the design is established**. Without a verification requirement, there is no obligation to prove the other requirements are met. DO-254 mandates this explicitly at all Design Assurance Levels.

---

## 3. Individual Requirement Rationale

### REQ-01 — Attenuate signals above 1 kHz by ≥ 20 dB

**What it means:** Frequencies above 1 kHz must be reduced to at most 10% of their original amplitude at the filter output.

**Why 20 dB:** 20 dB is a standard, meaningful engineering threshold. It corresponds to a 10× reduction in amplitude — enough to make high-frequency noise negligible in most sensor applications while remaining achievable with a low-tap-count FIR.

**Why 1 kHz:** Chosen as a clean, unambiguous stopband edge. Combined with REQ-02's 500 Hz passband edge, it defines a transition band of 500 Hz — intentionally wide to remain achievable with a 5-tap filter.

**What it covers:** Stopband attenuation — the primary functional purpose of a low-pass filter.

---

### REQ-02 — Pass signals below 500 Hz with < 3 dB attenuation

**What it means:** Frequencies below 500 Hz must retain at least ~70% of their original amplitude at the output.

**Why 3 dB:** 3 dB (a factor of √2 in amplitude) is the universal engineering convention for the boundary of acceptable signal loss. It is used consistently across filter design, RF engineering, and control systems — making it a meaningful and defensible threshold.

**Why 500 Hz:** Chosen to provide a clear separation from the 1 kHz stopband edge defined in REQ-01. The resulting 500 Hz transition band is deliberately generous, matching what a 5-tap FIR can realistically achieve.

**What it covers:** Passband flatness — ensuring the useful signal is preserved.

---

### REQ-03 — The filter output shall never overflow its defined bit width

**What it means:** The output register must never exceed its maximum representable value, regardless of input amplitude.

**Why this matters:** In fixed-point arithmetic, integer overflow causes **wrap-around** — a large positive value instantaneously becomes a large negative one. In an aerospace sensor processing chain, this silent corruption could propagate incorrect data to flight control systems without triggering any fault flag.

**Design response:** The implementation uses **saturation arithmetic** — when a computed value exceeds the bit width, it is clamped to the maximum (or minimum) representable value rather than wrapping. This is a deliberate, detectable failure mode rather than a silent one.

**What it covers:** Arithmetic safety — a foundational concern in any fixed-point hardware design.

---

### REQ-04 — The filter shall produce a valid output within 5 clock cycles of a valid input

**What it means:** The pipeline latency from input sample to valid output sample must not exceed 5 clock cycles.

**Why 5 cycles:** A 5-tap FIR filter requires exactly 5 input samples to fill its internal delay line before producing a fully valid output. This requirement is therefore **tight but achievable by design** — it validates that no unnecessary pipeline stages have been introduced and that the implementation matches the theoretical minimum latency.

**Why latency matters:** In a closed-loop control system, filter latency contributes directly to control loop delay. Excessive latency can cause instability. Even in open-loop sensor chains, latency must be bounded and known for system timing analysis.

**What it covers:** Timing behaviour — essential for real-time embedded system integration.

---

### REQ-05 — All requirements shall be verified by simulation testbench

**What it means:** For every requirement defined (REQ-01 through REQ-04), at least one testbench assertion or measurable simulation result must exist that demonstrates compliance.

**Why this is a requirement:** Without an explicit verification requirement, there is no obligation to prove the other requirements are met. A design could satisfy REQ-01 to REQ-04 on paper while having no simulation evidence. REQ-05 closes this gap by making verification itself a traceable, mandatory deliverable.

**DO-254 parallel:** This mirrors the concept of **verification coverage** in DO-254, where every hardware requirement must be traced to at least one verification activity. At DAL A, 100% coverage is mandatory.

**What it covers:** Verification completeness — the meta-requirement that makes all other requirements meaningful.

---

## 4. Simplifications vs. DO-254

This project applies a **simplified subset** of DO-254 practices for educational purposes. The following table is an honest comparison:

| Aspect | This Project | Full DO-254 |
|--------|-------------|-------------|
| Requirement format | Plain English table in Markdown | Formal, uniquely identified entries in a requirements management tool (e.g. IBM DOORS, Polarion) |
| Requirement hierarchy | Single level | Aircraft → System → Hardware item (multi-level, bidirectional) |
| Traceability | Test cases map to requirements | Full bidirectional traceability matrix — every requirement traces down to tests and up to system requirements |
| Verification independence | MATLAB as separate tool | Separate **person or team** must perform verification; tool independence alone is insufficient |
| Safety classification | Not formally assigned | Every hardware item is assigned a **Design Assurance Level (DAL A–E)** based on failure consequence |
| Review process | None | Formal peer reviews with sign-off at each lifecycle stage |
| Configuration management | Git version control | Formal CM plan with baseline control and change control board |

### Hypothetical DAL Assignment

If this filter were used in a non-essential cockpit display system, it would likely be classified as **DAL D** (minor failure effect). At **DAL A** (catastrophic failure effect, e.g. primary flight control), all five DO-254 lifecycle data items would be mandatory and verification independence would be strictly enforced.

---

## 5. What a Real Requirements Flow Would Look Like

For reference, the following illustrates how REQ-01 would be derived in a real DO-254 project:

```
[Aircraft Level]
  The aircraft shall maintain altitude awareness under all normal flight conditions.
        │
        ▼
[System Level]
  The avionics sensor module shall provide altitude data with SNR ≥ 40 dB
  across the 0–500 Hz signal band under all operating conditions.
        │
        ▼
[Hardware Item Level — this project]
  REQ-01: The FIR filter shall attenuate input signals above 1 kHz
  by at least 20 dB relative to the passband.
        │
        ▼
[Verification]
  TC-02: Apply a 2000 Hz sine wave at full amplitude.
  Assert output amplitude ≤ 10% of input amplitude.
  Verify against MATLAB reference model output within ±1 LSB.
```

In a real project this chain would be formally captured, reviewed, and signed off before any implementation begins.
