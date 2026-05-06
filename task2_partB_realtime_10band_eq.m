function task2_partB_realtime_10band_eq
% ==========================================================
% TASK 2 / PART B – REAL-TIME GRAPHIC EQUALIZER (10-band)
%
% Requirements met:
% - 10 bands centered around: 32, 64, 125, 250, 500, 1k, 2k, 4k, 8k, 16k Hz
% - Gains in dB (example range -20 to +20)
% - Uses: audioDeviceReader, audioDeviceWriter, graphicEQ, equalizer.Gains
% - Optional device listing with daq.getDevices
% - Visualizes input vs EQ output spectrum for ~30 seconds
%
% How to use:
% 1) Connect phone -> PC (AUX/TRRS/USB interface) so it appears as input device
% 2) Run this function
% 3) Play music on phone
% 4) You should hear equalized output on speakers/headphones
% ==========================================================

clc; close all;

%% ---- USER SETTINGS ----
Fs = 44100;                 % try 44100 first (common). If your device uses 48000, set 48000.
frameSize = 1024;           % audio block size
runSec = 30;                % visualize for ~30 seconds

% 10-band center frequencies (Hz)
bandCenters = [32 64 125 250 500 1000 2000 4000 8000 16000];

% Example gains (dB) - change these live by editing and re-running
% (Must be 10 values)
gainsDB = [0 0 0 0 0 0 0 0 0 0];     % flat
% gainsDB = [-10 -6 -3 0 2 4 4 2 0 -3];  % example curve

% Spectrum plot settings
plotEveryNFrames = 3;       % update plot every N frames (reduce CPU)
smoothing = 0.6;            % 0..1 (higher = smoother traces)
%% ------------------------

%% (Optional) check devices
% If you are using DAQ audio devices, this can help you confirm system devices.
% Safe: wrap in try.
try
    d = daq.getDevices;
    disp("=== daq.getDevices ===");
    disp(d);
catch
    disp("daq.getDevices not available on this setup (OK).");
end

%% Real-time I/O objects
deviceReader = audioDeviceReader( ...
    "SampleRate", Fs, ...
    "SamplesPerFrame", frameSize);

deviceWriter = audioDeviceWriter( ...
    "SampleRate", Fs);

% Create equalizer object
eq = graphicEQ( ...
    "SampleRate", Fs, ...
    "CenterFrequencies", bandCenters);

% Set gains (dB)
eq.Gains = gainsDB;

fprintf("Running real-time 10-band EQ for %g seconds...\n", runSec);
fprintf("Band centers (Hz): %s\n", mat2str(bandCenters));
fprintf("Gains (dB):        %s\n", mat2str(eq.Gains));

%% Plot setup
NFFT = 4096;
f = (0:NFFT/2-1) * (Fs/NFFT);

fig = figure("Name","TASK 2: Real-time Graphic EQ Spectrum (Input vs Output)");
ax = axes(fig);
hold(ax,"on"); grid(ax,"on");

hIn  = plot(ax, f, -120*ones(size(f)), "Color",[0.90 0.65 0.10], "LineWidth", 1.0);
hOut = plot(ax, f, -120*ones(size(f)), "b", "LineWidth", 1.0);

xlabel(ax,"Frequency (Hz)");
ylabel(ax,"Magnitude (dB)");
title(ax, sprintf("EQ Spectrum | t=0.00s | Gains(dB)=%s", mat2str(eq.Gains)));
legend(ax, "Input frame", "EQ output frame", "Location", "northeast");
xlim(ax, [0 Fs/2]);
ylim(ax, [-120 10]);

% magnitude buffers (for smoothing)
magInPrev  = -120*ones(size(f));
magOutPrev = -120*ones(size(f));

%% Main loop
tic;
k = 0;
while toc < runSec && ishandle(fig)
    x = deviceReader();             % NxC
    x = mean(x,2);                  % mono

    y = eq(x);                      % equalized

    deviceWriter(y);                % play out

    k = k + 1;
    if mod(k, plotEveryNFrames)==0
        % Spectrum
        Xin = fft(x, NFFT);
        Yin = fft(y, NFFT);

        magIn  = 20*log10(abs(Xin(1:NFFT/2)) + 1e-12);
        magOut = 20*log10(abs(Yin(1:NFFT/2)) + 1e-12);

        % Smooth (EMA)
        magInPrev  = smoothing*magInPrev  + (1-smoothing)*magIn;
        magOutPrev = smoothing*magOutPrev + (1-smoothing)*magOut;

        set(hIn,  "YData", magInPrev);
        set(hOut, "YData", magOutPrev);

        title(ax, sprintf("EQ Spectrum | t=%.2fs | Gains(dB)=%s", toc, mat2str(eq.Gains)));
        drawnow limitrate;
    end
end

release(deviceReader);
release(deviceWriter);

disp("TASK 2 / PART B COMPLETE.");
end
