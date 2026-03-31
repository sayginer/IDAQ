function [f, A] = IDAQfft(t, x)
% IDAQfft Computes the single-sided amplitude spectrum of a time-domain signal.
%
% This function performs a Fast Fourier Transform (FFT) on the input signal,
% removes the DC component, applies a Hanning window to minimize spectral 
% leakage, and returns the physical frequency axis and peak amplitude.
%
% Inputs:
%   t - Time vector (seconds)
%   x - Raw data signal (vector)
%
% Outputs:
%   f - Frequency axis (Hz)
%   A - Single-sided amplitude spectrum (Magnitude)
%
% Example Usage:
%   fs = 1000;                     % Sampling frequency (1 kHz)
%   t = 0:1/fs:1-1/fs;             % 1-second time vector
%   x = 5*sin(2*pi*50*t);          % 50 Hz sine wave with 5V amplitude
%   [f, A] = IDAQfft(t, x);        % Run FFT
%   plot(f, A);                    % Plot results
%   xlabel('Frequency (Hz)'); ylabel('Amplitude');
%
% This function is part of the Custom MATLAB Toolbox for MEE 2305:
% Instrumentation and Data Acquisition Lab at Temple University.
%
% Developed by: Dr. Osman Sayginer
% Department of Mechanical Engineering, Temple University

% 1. Data Type Casting and Formatting
% Ensure input is a double-precision column vector
x = double(x(:));
t = double(t(:));

% 2. Sampling Parameters
N = length(x);              % Number of samples
dt = t(2) - t(1);           % Sampling interval
fs = 1 / dt;                % Sampling frequency

% 3. Pre-processing
% Remove DC offset to prevent a large spike at 0 Hz
x = x - mean(x);

% Apply Hanning window to reduce spectral leakage (sidelobes)
w = hann(N);
x_win = x .* w;

% 4. Spectral Analysis
% Compute the FFT
X = fft(x_win);

% 5. Amplitude and Frequency Calculation
% Calculate the single-sided magnitude spectrum
% We multiply by 2 to account for the energy in the negative frequencies
% We divide by sum(w) to normalize for the window's coherent gain
A_full = (2 * abs(X)) / sum(w);

% Extract only the first half of the spectrum (Single-Sided)
A = A_full(1:floor(N/2)+1);

% Generate the frequency axis
f = (0:floor(N/2)) * (fs / N);

end