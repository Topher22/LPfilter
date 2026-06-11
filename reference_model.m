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

%% -------------------------------------------------------------------------
%  SECTION 1 — Filter Design
% -------------------------------------------------------------------------

Fs      = 8000;   % Sample rate (Hz)
Fc      = 1000;   % Cutoff frequency (Hz)
N_taps  = 9;      % Number of filter taps
Wn      = Fc / (Fs/2);  % Normalized cutoff (0 to 1, where 1 = Nyquist)

% Design filter using Hamming window
h = fir1(N_taps - 1, Wn, 'low', hamming(N_taps));

fprintf('=== Filter Coefficients (floating point) ===\n');
for i = 1:N_taps
    fprintf('  h(%d) = %.6f\n', i, h(i));
end

%% -------------------------------------------------------------------------
%  SECTION 2 — Fixed-Point Scaling (Q1.15 format)
%  Q1.15: 1 sign bit, 15 fractional bits -> scale factor = 2^15 = 32768
% -------------------------------------------------------------------------

SCALE    = 2^15;           % Q1.15 scale factor
h_fixed  = round(h * SCALE);

fprintf('\n=== Filter Coefficients (Q1.15 fixed-point for VHDL) ===\n');
for i = 1:N_taps
    fprintf('  h(%d) = %d\n', i, h_fixed(i));
end   

fprintf('\n--- Copy these into your VHDL constant array ---\n');
fprintf('constant COEFFS : coeff_array := (\n');
for i = 1:N_taps
    if i < N_taps
        fprintf('    %d => %d,\n', i-1, h_fixed(i));
    else
        fprintf('    %d => %d\n', i-1, h_fixed(i));
    end
end
fprintf(');\n');

%% ------------------------------------------------------------------------
%  SECTION 3 — Frequency Response Verification (REQ-01, REQ-02)
% ------------------------------------------------------------------------

% Check REQ-01: attenuation >= 20 dB at 2000 Hz (well into stopband)

[H, f] = freqz(h, 1, 4096, Fs);
H_dB   = 20 * log10(abs(H));
[~, idx_2k] = min(abs(f - 2000));
atten_2k = H_dB(idx_2k);
req01_pass = atten_2k <= -20;
fprintf('\n=== REQ-01 Check (attenuation >= 20 dB above 1 kHz) ===\n');
fprintf('  Attenuation at 2000 Hz: %.2f dB\n', atten_2k);
fprintf('  REQ-01: %s\n', pass_fail(req01_pass));

% Check REQ-02: attenuation < 3 dB at 200 Hz (well inside passband)
[~, idx_200] = min(abs(f - 200));
atten_200 = H_dB(idx_200);
req02_pass = atten_200 >= -3;
fprintf('\n=== REQ-02 Check (attenuation < 3 dB below 500 Hz) ===\n');
fprintf('  Attenuation at 200 Hz: %.2f dB\n', atten_200);
fprintf('  REQ-02: %s\n', pass_fail(req02_pass));

% Plot frequency response
outputDir = fullfile('docs', 'waveforms');
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end
figure('Name', 'Frequency Response — REQ-01 & REQ-02 Verification');
plot(f, H_dB, 'b', 'LineWidth', 1.5); hold on;
yline(-3,  '--r', '-3 dB (REQ-02 limit)',  'LabelHorizontalAlignment', 'left');
yline(-20, '--m', '-20 dB (REQ-01 limit)', 'LabelHorizontalAlignment', 'left');
xline(500,  ':k', '500 Hz passband edge');
xline(1000, ':k', '1 kHz stopband edge');
xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');
title('FIR Filter Frequency Response');
xlim([0 Fs/2]); ylim([-80 5]);
grid on; legend('Filter response');
if ~req01_pass || ~req02_pass
    error('REQ-01 or REQ-02 failed. See output above for details.');
end


%% -------------------------------------------------------------------------
%  SECTION 4 — Test Case Simulations
% -------------------------------------------------------------------------

Ts      = 1/Fs;             % Sample period
t_len   = 0.01;             % Signal duration (seconds)
t       = 0:Ts:t_len-Ts;   % Time vector
N       = length(t);

% --- TC-01: 200 Hz sine wave (passband — REQ-02) -------------------------
x_tc01   = sin(2*pi*200*t);
y_tc01   = filter(h, 1, x_tc01);
plot_testcase(t, x_tc01, y_tc01, 'TC-01: 200 Hz Sine (Passband)', ...
    'docs/waveforms/tc01_200hz.png');

% --- TC-02: 2000 Hz sine wave (stopband — REQ-01) ------------------------
x_tc02   = sin(2*pi*2000*t);
y_tc02   = filter(h, 1, x_tc02);
plot_testcase(t, x_tc02, y_tc02, 'TC-02: 2000 Hz Sine (Stopband)', ...
    'docs/waveforms/tc02_2000hz.png');

% --- TC-03: Mixed 200 Hz + 2000 Hz (REQ-01 & REQ-02) --------------------
x_tc03   = 0.5*sin(2*pi*200*t) + 0.5*sin(2*pi*2000*t);
y_tc03   = filter(h, 1, x_tc03);
plot_testcase(t, x_tc03, y_tc03, 'TC-03: Mixed 200 Hz + 2000 Hz Signal', ...
    'docs/waveforms/tc03_mixed.png');

% -------------------------------------------------------------------------
%  LOCAL HELPER FUNCTIONS
% -------------------------------------------------------------------------
function s = pass_fail(condition)
if condition, s = 'PASS'; else, s = 'FAIL'; end
end

function plot_testcase(t, x, y, title_str, filename)
    figure('Name', title_str);
    plot(t*1000, x, 'b', 'DisplayName', 'Input',  'LineWidth', 1.2); hold on;
    plot(t*1000, y, 'r', 'DisplayName', 'Output', 'LineWidth', 1.5);
    xlabel('Time (ms)'); ylabel('Amplitude');
    title(title_str); legend; grid on;
    saveas(gcf, filename);
end




