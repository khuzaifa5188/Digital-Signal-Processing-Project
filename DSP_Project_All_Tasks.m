function DSP_Project_All_Tasks
% ==========================================================
% DIGITAL SIGNAL PROCESSING PROJECT - ALL TASKS IN ONE FILE
%
% Includes:
%   TASK 1 / Part A: AWGN + LPF (designfilt/fvtool) + Notch (designfilt/fvtool)
%   TASK 3: Echo + Flange + Reverb (few-samples plots to clearly show effects)
%
% NOTE ABOUT TASK 2:
%   You did not provide Task 2 code in chat, so it is NOT included here.
%   Paste your Task 2 code and I will merge it into this same file.
%
% Input file required in same folder:
%   recorded_full.wav
% ==========================================================

clc; close all;

%% =========================
% SHARED INPUT SETTINGS
%% =========================
inFile = "recorded_full.wav";
segmentStartSec = 0;
segmentDurSec   = 10;    % 10 seconds

fprintf("\n===== DSP PROJECT (ALL TASKS) =====\n");
fprintf("Input file: %s\n\n", inFile);

%% Run Task 1
task1_partA(inFile, segmentStartSec, segmentDurSec);

%% Run Task 3
task3_part3_effects_few_samples(inFile, segmentStartSec, segmentDurSec);

disp("===== ALL DONE =====");
end

%% ==========================================================
% TASK 1 / PART A
%% ==========================================================
function task1_partA(inFile, segmentStartSec, segmentDurSec)
% TASK 1 / PART A
% - Reads recorded voice segment
% - Adds AWGN noise
% - LPF using designfilt + fvtool
% - Notch using designfilt + fvtool
% - Saves WAV outputs

disp("===== TASK 1 / PART A START =====");

%% ----------- USER SETTINGS -----------
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

if fileDur < segmentStartSec + segmentDurSec
    if fileDur <= segmentStartSec
        error("segmentStartSec (%.2f) is beyond file duration (%.2f).", segmentStartSec, fileDur);
    end
    warning("File duration %.2f s. Using shorter segment %.2f s.", fileDur, fileDur-segmentStartSec);
    segmentDurSec = fileDur - segmentStartSec;
end

%% Load audio
[x, Fs2] = audioread(inFile);
if Fs2 ~= Fs
    warning("audioinfo Fs (%d) != audioread Fs (%d). Using audioread Fs.", Fs, Fs2);
    Fs = Fs2;
end

x = mean(x,2);
x = x / max(abs(x)+1e-12);

nyq = Fs/2;
if lpfCutoffHz >= nyq
    lpfCutoffHz = 0.9*nyq;
    warning("Adjusted LPF cutoff to %.0f Hz (< Nyquist).", lpfCutoffHz);
end

%% Segment
startSample = round(segmentStartSec*Fs) + 1;
endSample   = startSample + round(segmentDurSec*Fs) - 1;
endSample   = min(endSample, length(x));
clean = x(startSample:endSample);

fprintf("Task 1 segment: %.2f–%.2f s | Fs=%d | N=%d\n", ...
    segmentStartSec, segmentStartSec+segmentDurSec, Fs, length(clean));

%% Design LPF
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

fvtool(lpf); title("TASK 1: LPF Frequency Response");

%% Add AWGN
Ps = mean(clean.^2);
Pn = Ps / (10^(snrDB/10));
noisy = clean + sqrt(Pn) * randn(size(clean));

%% LPF filter
filtered = filter(lpf, noisy);

%% Plot few samples
N = min(plotSamples, length(clean));
t = (0:N-1)/Fs;

figure("Name","TASK 1: Clean / Noisy / LPF Filtered (few samples)");
subplot(3,1,1);
plot(t, clean(1:N)); grid on;
title("Original (clean) - few samples"); ylabel("Amplitude");

subplot(3,1,2);
plot(t, noisy(1:N)); grid on;
title(sprintf("Noisy (AWGN, SNR=%g dB) - few samples", snrDB)); ylabel("Amplitude");

subplot(3,1,3);
plot(t, filtered(1:N)); grid on;
title(sprintf("Filtered (LPF output) - %s", lpfName));
ylabel("Amplitude"); xlabel("Time (s)");

%% Save WAVs
cleanW    = norm_audio(clean);
noisyW    = norm_audio(noisy);
filteredW = norm_audio(filtered);

audiowrite("task1_clean_seg.wav", cleanW, Fs);
audiowrite("task1_noisy_seg.wav", noisyW, Fs);
audiowrite("task1_lpf_filtered_seg.wav", filteredW, Fs);

%% Notch filter
bw = notchF0/notchQ;
f1 = max(1, notchF0 - bw/2);
f2 = min(nyq-1, notchF0 + bw/2);

notch = designfilt("bandstopiir", ...
    "FilterOrder", 2, ...
    "HalfPowerFrequency1", f1, ...
    "HalfPowerFrequency2", f2, ...
    "SampleRate", Fs);

fvtool(notch); title(sprintf("TASK 1: Notch Filter Response (center≈%.0f Hz)", notchF0));

notched = filter(notch, noisy);
notchedW = norm_audio(notched);

audiowrite("task1_notch_filtered_seg.wav", notchedW, Fs);

figure("Name","TASK 1: Notch Effect (few samples)");
plot(t, noisy(1:N), "Color",[0.85 0.65 0.1]); hold on;
plot(t, notched(1:N), "b"); grid on;
xlabel("Time (s)"); ylabel("Amplitude");
title(sprintf("Noisy vs Notch-Filtered (%.0f Hz) - few samples", notchF0));
legend("Noisy","After Notch");

disp("Saved Task 1 outputs:");
disp("  task1_clean_seg.wav");
disp("  task1_noisy_seg.wav");
disp("  task1_lpf_filtered_seg.wav");
disp("  task1_notch_filtered_seg.wav");

disp("===== TASK 1 / PART A END =====");
end

%% ==========================================================
% TASK 3 / PART 3 (few samples plots only)
%% ==========================================================
function task3_part3_effects_few_samples(inFile, segmentStartSec, segmentDurSec)
% TASK 3 / PART 3
% - Echo + Flange + Reverb
% - Few-samples overlay plots (Original vs Effect)
% - Saves WAV outputs

disp("===== TASK 3 / PART 3 START =====");

%% Effect settings (observable)
echoDelayMs = 500;
echoMix     = 0.90;
echoFB      = 0.65;

flangeBaseDelayMs = 10.0;
flangeDepthMs     = 8.0;
flangeLfoHz       = 0.25;
flangeMix         = 0.95;

revDelaysMs = [90 140 200 280 360 450];
revGains    = [0.75 0.60 0.50 0.40 0.32 0.25];
revFB       = 0.45;

% Few-samples plot settings
fewSec = 0.10;
rmsWinSec = 0.05;

%% Load + mono + segment
info = audioinfo(inFile);
Fs = info.SampleRate;

[x, Fs2] = audioread(inFile);
if Fs2 ~= Fs, Fs = Fs2; end

x = mean(x,2);
x = x / (max(abs(x))+1e-12);

fileDur = length(x)/Fs;
if fileDur < segmentStartSec + segmentDurSec
    segmentDurSec = max(0, fileDur - segmentStartSec);
end
if segmentDurSec <= 0
    error("Invalid segment for Task 3.");
end

i0 = round(segmentStartSec*Fs) + 1;
i1 = min(length(x), i0 + round(segmentDurSec*Fs) - 1);
orig = x(i0:i1);

fprintf("Task 3 segment: %.2f–%.2f s | Fs=%d | N=%d\n", ...
    segmentStartSec, segmentStartSec+segmentDurSec, Fs, length(orig));

%% Echo (feedback comb)
D = max(1, round(echoDelayMs*1e-3*Fs));
wetEcho = filter(1, [1 zeros(1,D-1) -echoFB], orig);
echoOut = (1-echoMix)*orig + echoMix*wetEcho;

%% Flanger (fast integer delay)
N = length(orig);
n = (0:N-1)';

baseD  = flangeBaseDelayMs*1e-3*Fs;
depthD = flangeDepthMs*1e-3*Fs;
d = round(baseD + depthD*sin(2*pi*flangeLfoHz*n/Fs));
d(d < 0) = 0;

flangeDelaySig = zeros(N,1);
for ii = 1:N
    jj = ii - d(ii);
    if jj >= 1
        flangeDelaySig(ii) = orig(jj);
    end
end

flangeWet = orig + flangeDelaySig;
flangeOut = (1-flangeMix)*orig + flangeMix*flangeWet;

%% Reverb (feedback tail + multitap)
dk = round(revDelaysMs*1e-3*Fs);
dk(dk < 1) = 1;
Dmax = max(dk);

tail = filter(1, [1 zeros(1,Dmax-1) -revFB], orig);

reverbOut = orig;
for k = 1:numel(dk)
    Dk = dk(k);
    reverbOut(Dk+1:end) = reverbOut(Dk+1:end) + revGains(k)*tail(1:end-Dk);
end

%% Save WAVs
origW   = norm_audio(orig);
echoW   = norm_audio(echoOut);
flangeW = norm_audio(flangeOut);
reverbW = norm_audio(reverbOut);

audiowrite("part3_original_10s.wav", origW, Fs);
audiowrite("part3_echo_10s.wav",     echoW, Fs);
audiowrite("part3_flange_10s.wav",   flangeW, Fs);
audiowrite("part3_reverb_10s.wav",   reverbW, Fs);

disp("Saved Task 3 outputs:");
disp("  part3_original_10s.wav");
disp("  part3_echo_10s.wav");
disp("  part3_flange_10s.wav");
disp("  part3_reverb_10s.wav");

%% Loudest region for few-samples plot
fewN = max(10, round(fewSec*Fs));
win = max(32, round(rmsWinSec*Fs));

rmsEnv = sqrt(movmean(orig.^2, win));
[~, idxMax] = max(rmsEnv);

startIdx = max(1, idxMax - floor(fewN/2));
endIdx   = min(length(orig), startIdx + fewN - 1);
startIdx = max(1, endIdx - fewN + 1);

tFew = ((startIdx:endIdx) - startIdx)/Fs;

%% Plots (few samples overlays)
figure("Name","TASK 3: Echo (few samples)");
plot(tFew, orig(startIdx:endIdx), "k", "LineWidth", 1.0); hold on;
plot(tFew, echoOut(startIdx:endIdx), "b", "LineWidth", 1.0);
grid on; xlabel("Time (s)"); ylabel("Amplitude");
title(sprintf("Echo: delay=%d ms", echoDelayMs));
legend("Original","Echo output");
xlim([0 fewSec]);

figure("Name","TASK 3: Flange (few samples)");
plot(tFew, orig(startIdx:endIdx), "k", "LineWidth", 1.0); hold on;
plot(tFew, flangeOut(startIdx:endIdx), "b", "LineWidth", 1.0);
grid on; xlabel("Time (s)"); ylabel("Amplitude");
title(sprintf("Flange: base=%.1f ms depth=%.1f ms", flangeBaseDelayMs, flangeDepthMs));
legend("Original","Flange output");
xlim([0 fewSec]);

figure("Name","TASK 3: Reverb (few samples)");
plot(tFew, orig(startIdx:endIdx), "k", "LineWidth", 1.0); hold on;
plot(tFew, reverbOut(startIdx:endIdx), "b", "LineWidth", 1.0);
grid on; xlabel("Time (s)"); ylabel("Amplitude");
title(sprintf("Reverb: delays=[%s] ms", num2str(revDelaysMs)));
legend("Original","Reverb output");
xlim([0 fewSec]);

disp("===== TASK 3 / PART 3 END =====");
end

%% ==========================================================
% Small helper
%% ==========================================================
function y = norm_audio(x)
y = x ./ (max(abs(x)) + 1e-12);
end