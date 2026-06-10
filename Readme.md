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
6. [Test Results](#6-results)
7. [Review/DO-254 Considerations](#7-review--do-254-considerations)
8. [Tools & References](#8-tools--references)

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

```
          ┌─────────────────────────────────────────┐
          │            FIR Filter (5-tap)            │
          │                                          │
x[n] ───► │  z⁻¹ ──► z⁻¹ ──► z⁻¹ ──► z⁻¹          │
          │   │        │        │        │           │
          │  ×h0      ×h1      ×h2      ×h3   ×h4   │
          │   │        │        │        │      │    │
          │   └────────┴────────┴────────┴──────┘   │
          │                    Σ                     │
          └─────────────────────────┬───────────────┘
                                    │
                                  y[n] ───►
```


