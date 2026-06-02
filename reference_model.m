% =========================================================================
% reference_model.m
% FIR Low-Pass Filter — Coefficient Generation & Reference Model
%
% Purpose:
%   1. Design a 5-tap FIR low-pass filter using fir1()
%   2. Verify the frequency response meets REQ-01 and REQ-02
%   3. Generate fixed-point (Q1.15) coefficients for use in VHDL
%   4. Simulate filter output for each test case (TC-01 to TC-05)
%   5. Export output data for comparison against Aldec VHDL simulation
%
% Requirements covered:
%   REQ-01: Attenuation >= 20 dB above 1 kHz
%   REQ-02: Attenuation < 3 dB below 500 Hz
%   REQ-03: No overflow (verified by saturation check)
%   REQ-04: Latency <= 5 clock cycles (verified by impulse response)
%
% Tools: MATLAB R2021a or later, Signal Processing Toolbox
% =========================================================================

clear; clc; close all;

% Design a 5-tap FIR low-pass filter with a cutoff frequency of 0.25
fs = 8000; % Sampling frequency (Hz)
fc = 1000; % Cutoff frequency (Hz)
N_fil = 5 %Number of filter taps
Wn = fc/(fs/2); % Normalized cutoff frequency

% Generate FIR filter coefficients using the Hamming window

h = fir1(N_fil-1, Wn, 'low', hamming(N_fil));

fprintf('=== Filter Coefficients (floating point) ===\n');
for i = 1:N_fil
    fprintf('  h(%d) = %.6f\n', i, h(i));
end


%% -------------------------------------------------------------------------
%  SECTION 2 — Fixed-Point Scaling (Q1.15 format)
%  Q1.15: 1 sign bit, 15 fractional bits -> scale factor = 2^15 = 32768
% -------------------------------------------------------------------------

SCALE    = 2^15;           % Q1.15 scale factor
h_fixed  = round(h * SCALE);

fprintf('\n=== Filter Coefficients (Q1.15 fixed-point for VHDL) ===\n');
for i = 1:N_fil
    fprintf('  h(%d) = %d\n', i, h_fixed(i));
end

fprintf('\n--- Copy these into your VHDL constant array ---\n');
fprintf('constant COEFFS : coeff_array := (\n');
for i = 1:N_fil
    if i < N_fil
        fprintf('    %d => %d,\n', i-1, h_fixed(i));
    else
        fprintf('    %d => %d\n', i-1, h_fixed(i));
    end
end
fprintf(');\n');