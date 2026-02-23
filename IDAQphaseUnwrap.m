function phaseDeg = IDAQphaseUnwrap(primary, secondary, fs)
% IDAQphaseUnwrap Computes phase difference (in degrees) between two signals
% using FFT-based dominant frequency extraction and wraps to [-180, 180].
%
% This function is specifically designed for LVDT calibration to handle
% the characteristic 180-degree phase shift at the null point.
%
% Inputs:
%   primary   - Excitation signal / Reference coil (vector or matrix)
%   secondary - LVDT output signal / Secondary coils (vector or matrix)
%   fs        - Sampling frequency (Hz)
%
% Output:
%   phaseDeg  - Phase difference (secondary - primary) in degrees.
%               Output is strictly constrained to the range [-180, 180].
%  
% This function is part of the Custom MATLAB Toolbox for MEE 2305:
% Instrumentation and Data Acquisition Lab at Temple University.
%
% Developed by: Dr. Osman Sayginer
% Department of Mechanical Engineering, Temple University

% 1. Data Type Casting
% Convert to double to ensure compatibility with Hanning window and FFT
% (Prevents integer-double multiplication errors from DAQ data)
primary = double(primary);
secondary = double(secondary);

% Get dimensions: N = samples per capture, numCaptures = number of data points
[N, numCaptures] = size(secondary);
phaseDeg = zeros(1, numCaptures);

% Pre-generate Hanning window to reduce spectral leakage
w = hann(N);

for i = 1:numCaptures
    % 2. Pre-processing
    % Extract current snapshot and remove DC offset
    x = primary(:, i) - mean(primary(:, i));
    y = secondary(:, i) - mean(secondary(:, i));
    
    % 3. Spectral Analysis
    % Apply window and compute Fast Fourier Transform
    X = fft(x .* w);
    Y = fft(y .* w);
    
    % Identify the dominant frequency bin (Carrier Frequency)
    [~, idx] = max(abs(X(1:floor(N/2))));
    
    % 4. Phase Calculation
    % Compute phase difference at the dominant frequency bin
    pRad = angle(Y(idx)) - angle(X(idx));
    pDeg = rad2deg(pRad);
    
    % 5. Wrapping Logic
    % Constrains output to [-180, 180] to handle circularity.
    % This correctly maps values like -350 deg to +10 deg.
    phaseDeg(i) = mod(pDeg + 180, 360) - 180;
end

end