function task1_partA_complete_v2
% TASK 1 / PART A COMPLETE (v2)
% - Reads recorded_full.wav (10s segment)
% - Adds AWGN noise
% - Designs LPF using designfilt + shows fvtool
% - Filters noisy signal with LPF
% - Designs Notch filter using designfilt + shows fvtool
% - Applies notch to noisy signal
% - Saves WAV outputs and (optionally) plays audio

clc; close all;

%% ----------- USER SETTINGS -----------
inFile = "recorded_full.wav";
segmentStartSec = 0;
segmentDurSec   = 10;

% LPF
lpfCutoffHz = 8000;
useIIR = false;     % false = FIR, true = IIR (Butter)
firOrder = 80;
iirOrder = 8;

% Noise (SNR dB)
snrDB = 10;

% Notch
notchF0 = 1000;     % center frequency (Hz)
notchQ  = 35;       % higher => narrower

% Plot few samples
plotSamples = 2500;
%% ------------------------------------

%% Audio file info
info = audioinfo(inFile);
disp("=== audioinfo ===");
disp(info);

Fs = info.SampleRate;
fileDur = info.Duration;

% Adjust if file shorter than requested segment
if fileDur < segmentStartSec + segmentDurSec
    if fileDur <= segmentStartSec
        error("segmentStartSec (%.2f) is beyond the file duration (%.2f).", segmentStartSec, fileDur);
    end
    warning("File duration is %.2f s. Using segmentDurSec = %.2f s.", fileDur, fileDur-segmentStartSec);
    segmentDurSec = fileDur - segmentStartSec;
end

%% Load audio
[x, Fs2] = audioread(inFile);
if Fs2 ~= Fs
    warning("audioinfo Fs (%d) != audioread Fs (%d). Using audioread Fs.", Fs, Fs2);
    Fs = Fs2;
end

x = mean(x,2);                 % mono
x = x / max(abs(x)+1e-12);     % normalize

nyq = Fs/2;
if lpfCutoffHz >= nyq
    lpfCutoffHz = 0.9*nyq;
    warning("Adjusted LPF cutoff to %.0f Hz to be < Nyquist.", lpfCutoffHz);
end

%% Select segment
startSample = round(segmentStartSec*Fs) + 1;
endSample   = startSample + round(segmentDurSec*Fs) - 1;
endSample   = min(endSample, length(x));

clean = x(startSample:endSample);

fprintf("Using '%s' | Fs=%d Hz | Segment %.2f–%.2f sec | Samples=%d\n", ...
    inFile, Fs, segmentStartSec, segmentStartSec+segmentDurSec, length(clean));

%% Design LPF using designfilt
if ~useIIR
    lpf = designfilt("lowpassfir", ...
        "FilterOrder", firOrder, ...
        "CutoffFrequency", lpfCutoffHz, ...
        "SampleRate", Fs);
    lpfName = sprintf("FIR LPF (Order=%d, Cutoff=%.0f Hz)", firOrder, lpfCutoffHz);
else
    lpf = designfilt("lowpassiir", ...
        "DesignMethod", "butter", ...
        "FilterOrder", iirOrder, ...
        "HalfPowerFrequency", lpfCutoffHz, ...
        "SampleRate", Fs);
    lpfName = sprintf("IIR Butter LPF (Order=%d, Cutoff=%.0f Hz)", iirOrder, lpfCutoffHz);
end

fvtool(lpf); title("LPF Frequency Response");
disp("LPF designed. Screenshot fvtool.");

%% Add white Gaussian noise (manual AWGN)
Ps = mean(clean.^2);
Pn = Ps / (10^(snrDB/10));
noisy = clean + sqrt(Pn) * randn(size(clean));

%% Filter with LPF
filtered = filter(lpf, noisy);

%% Plot few samples (clean/noisy/filtered)
N = min(plotSamples, length(clean));
t = (0:N-1)/Fs;

figure("Name","Task 1 Part A: Clean / Noisy / Filtered");
subplot(3,1,1);
plot(t, clean(1:N)); grid on;
title("Original (clean) - few samples"); ylabel("Amplitude");

subplot(3,1,2);
plot(t, noisy(1:N)); grid on;
title(sprintf("Noisy (AWGN, SNR=%g dB) - few samples", snrDB)); ylabel("Amplitude");

subplot(3,1,3);
plot(t, filtered(1:N)); grid on;
title(sprintf("Filtered (LPF output) - %s", lpfName)); ylabel("Amplitude"); xlabel("Time (s)");

%% Save WAV outputs
cleanW    = clean    / max(abs(clean)+1e-12);
noisyW    = noisy    / max(abs(noisy)+1e-12);
filteredW = filtered / max(abs(filtered)+1e-12);

audiowrite("task1_clean_seg.wav", cleanW, Fs);
audiowrite("task1_noisy_seg.wav", noisyW, Fs);
audiowrite("task1_lpf_filtered_seg.wav", filteredW, Fs);

fprintf("Saved:\n  task1_clean_seg.wav\n  task1_noisy_seg.wav\n  task1_lpf_filtered_seg.wav\n");

%% Notch filter using designfilt (bandstopiir)
bw = notchF0/notchQ;
f1 = max(1, notchF0 - bw/2);
f2 = min(nyq-1, notchF0 + bw/2);

notch = designfilt("bandstopiir", ...
    "FilterOrder", 2, ...
    "HalfPowerFrequency1", f1, ...
    "HalfPowerFrequency2", f2, ...
    "SampleRate", Fs);

fvtool(notch);
title(sprintf("Notch Filter Frequency Response (center≈%.0f Hz)", notchF0));
disp("Notch designed. Screenshot fvtool.");

notched = filter(notch, noisy);

notchedW = notched / max(abs(notched)+1e-12);
audiowrite("task1_notch_filtered_seg.wav", notchedW, Fs);
fprintf("Saved:\n  task1_notch_filtered_seg.wav\n");

figure("Name","Task 1 Part A: Notch Effect (few samples)");
plot(t, noisy(1:N), "Color",[0.85 0.65 0.1]); hold on;
plot(t, notched(1:N), "b"); grid on;
xlabel("Time (s)"); ylabel("Amplitude");
title(sprintf("Noisy vs Notch-Filtered (%.0f Hz) - few samples", notchF0));
legend("Noisy","After Notch");

%% Safe playback (optional; may fail on MATLAB Online audio device)
safePlay(cleanW, Fs, "CLEAN");
safePlay(noisyW, Fs, "NOISY");
safePlay(filteredW, Fs, "LPF-FILTERED");
safePlay(notchedW, Fs, "NOTCH-FILTERED");

disp("TASK 1 / PART A COMPLETE (v2). ");
end

function safePlay(x, Fs, label)
try
    dur = length(x)/Fs;
    fprintf("Playing %s (%.2f s) ...\n", label, dur);
    sound(x, Fs);
    pause(dur + 0.25);
catch ME
    warning("Playback failed for %s: %s", label, ME.message);
    disp("Download and listen to the saved WAV files locally.");
end
end
