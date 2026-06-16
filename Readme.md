# VHDL FIR Low-Pass Filter — Digital Design & Verification

[![MATLAB CI](https://github.com/Topher22/LPfilter/actions/workflows/matlab-ci.yml/badge.svg)](https://github.com/Topher22/LPfilter/actions/workflows/matlab-ci.yml)
> A hardware digital filter implemented in VHDL, tested and verified through structured testbenches and validated against a MATLAB reference model — following principles of DO-254 hardware design assurance.
> This project applies a simplified subset of DO-254 practices for educational purposes. Full compliance would require formal DAL assignment, bidirectional traceability, verification independence, and configuration management — aspects acknowledged but out of scope here.
> Assuming this filter were used in a non-essential display system, it would likely be classified as DAL D. At DAL A (flight-critical), all five lifecycle data items would be mandatory.
---

## Table of Contents
1. [Project Overview](#1-project-overview)
2. [Requirements](#2-requirements)
3. [Architechture](#3-architechture)
4. [Implementation](#4-implementation)
5. [Test Plan](#5-test-plan)


---

##  1.  Project Overview
This  project implements a 9-tap FIR (Finite Impulse Response) low-pass filter in VHDL, targeting digital signal conditioning for sensor data —  a common task in aerospace embedded systems, used constantly in aerospace sensor processing (IMUs, GPS, radar).

The goal is not only to implement the filter, but to **verify it rigorously**: feeding known inputs, asserting expected outputs, and comparing hardware simulation results against a software reference model.

**Key skills demonstrated**
- VHDL digital design (combinatorial and sequential logic)
- Structured testbench development with Aldec
- MATLAB-based filter design and reference modelling
- Hardware/software co-verification
- Engineering documentation practice

---

## 2. Requirements

The following requirements were defined before implementation, following a requirements-first design approach.

| ID | Requirement | Type |
|----|-------------|------|
| REQ-01 | The filter shall attenuate signals above 1 kHz by at least 20 dB | Functional |
| REQ-02 | The filter shall pass signals below 500 Hz with less than 3 dB attenuation | Functional |
| REQ-03 | The filter output shall never overflow its defined bit width | Safety |
| REQ-04 | The filter shall produce a valid output within 9 clock cycles of a valid input | Timing |
| REQ-05 | All requirements shall be verified by simulation testbench | Verification |

---

## 3. Architecture

### Block Diagram
┌──────────────────────────────────────────────────────┐
          │              FIR Filter (9-tap)                       │
          │                                                       │
x[n] ───► │  z⁻¹ ──► z⁻¹ ──► z⁻¹ ──► ··· ──► z⁻¹               │
          │   │        │        │              │                 │
          │  ×h₀      ×h₁      ×h₂     ···   ×h₈                │
          │   │        │        │              │                 │
          │   └────────┴────────┴──────────────┘                 │
          │                    Σ                                  │
          └─────────────────────┬───────────────────────────────┘
                                │
                              y[n] ───►


### Signal Description

| Signal | Direction | Width | Description |
|--------|-----------|-------|-------------|
| `clk` | Input | 1 bit | System clock |
| `rst` | Input | 1 bit | Synchronous reset |
| `x_in` | Input | 16 bit | Signed input sample |
| `y_out` | Output | 16 bit | Filtered output sample |
| `valid_in` | Input | 1 bit | Input sample valid flag |
| `valid_out` | Output | 1 bit | Output sample valid flag |


## 4. Implementation

### Repository Structure

```
LPfilter-vhdl/
├── src/
│   └── LPfilter.vhd          # Main filter entity
├── tb/
│   └── LPfilter_tb.vhd       # VHDL testbench
├── ref/
│   └── reference_model.m       # MATLAB reference model & coefficient generation
├── docs/
│   └── waveforms/              # Aldec waveform screenshots
└── README.md                   # This file
```

### Key Design Decisions

- **Fixed-point arithmetic (Q1.15):** Coefficients are scaled to 16-bit integers to avoid floating point, which is not natively supported in synthesizable VHDL.
- **Synchronous reset:** All registers reset on the rising edge of `clk` when `rst` is high, for predictable behavior in safety-critical contexts.
- **Overflow protection:** Output is saturated rather than allowed to wrap, satisfying REQ-03.

---

## 5. Test Plan

### Test Cases

| TC ID | Input Signal | Expected Behavior | Verifies |
|-------|-------------|-------------------|----------|
| TC-01 | 200 Hz sine wave | Output closely matches input (< 3 dB loss) | REQ-02 |
| TC-02 | 2000 Hz sine wave | Output amplitude reduced by ≥ 20 dB | REQ-01 |
| TC-03 | Mixed 200 Hz + 2000 Hz | High frequency component attenuated | REQ-01, REQ-02 |
| TC-04 | Maximum amplitude input | No overflow on output | REQ-03 |
| TC-05 | Single impulse | Output settles within 9 cycles | REQ-04 |

### Verification Method

Each test case is run in two ways:
1. **VHDL testbench** (Aldec) — asserts pass/fail, with waveforms captured for review
2. **MATLAB reference model** — same inputs processed in MATLAB using `filter()`, outputs compared numerically against VHDL simulation results

A test is considered **passed** only when both methods agree within a defined tolerance (±1 LSB for rounding).
All results and steps taken are documented in [Designlog](https://github.com/Topher22/LPfilter/blob/main/Designlog.md)

---
