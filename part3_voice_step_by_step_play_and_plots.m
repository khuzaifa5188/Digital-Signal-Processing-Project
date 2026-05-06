function part3_voice_step_by_step_play_and_plots
% ==========================================================
% PART 3 – Voice Effects (10 seconds) – Step-by-step:
% 1) Play ORIGINAL + show ORIGINAL graph
% 2) Play ECHO     + show ECHO graph
% 3) Play FLANGE   + show FLANGE graph
% 4) Play REVERB   + show REVERB graph
%
% Notes:
% - Uses continuous playback (no chunking) to avoid gaps/pause artifacts.
% - MATLAB Online may still fail audio device sometimes; WAVs are saved.
% ==========================================================

clc; close all;

%% -------- SETTINGS --------
inFile = "recorded_full.wav";
segmentStartSec = 0;
segmentDurSec   = 10;

% Echo (obvious)
echoDelayMs = 500;
echoMix     = 0.90;
echoFB      = 0.65;

% Flanger (obvious)
flangeBaseDelayMs = 10.0;
flangeDepthMs     = 8.0;
flangeLfoHz       = 0.25;
flangeMix         = 0.95;

% Reverb (obvious)
revDelaysMs = [90 140 200 280 360 450];
revGains    = [0.75 0.60 0.50 0.40 0.32 0.25];
revFB       = 0.45;

% Graph display options
plotFull10Sec = true;       % show full 10-second waveform
overlayLoudest2Sec = true;  % additionally show loudest 2 sec overlay (optional)
overlayWindowSec = 2.0;
%% -------------------------

%% Load voice and take 10s segment
info = audioinfo(inFile);
Fs = info.SampleRate;

[x, Fs2] = audioread(inFile);
if Fs2 ~= Fs, Fs = Fs2; end

x = mean(x,2);
x = x / (max(abs(x)) + 1e-12);

fileDur = length(x)/Fs;
if fileDur < segmentStartSec + segmentDurSec
    segmentDurSec = max(0, fileDur - segmentStartSec);
end
if segmentDurSec <= 0
    error("Invalid segment. Check segmentStartSec and file duration.");
end

i0 = round(segmentStartSec*Fs) + 1;
i1 = min(length(x), i0 + round(segmentDurSec*Fs) - 1);
orig = x(i0:i1);
t = (0:length(orig)-1)/Fs;

fprintf("Loaded '%s' | Fs=%d | Segment %.2f–%.2f s | N=%d\n", ...
    inFile, Fs, segmentStartSec, segmentStartSec+segmentDurSec, length(orig));

%% ========== Generate Effects ==========
% Echo (feedback comb)
D = max(1, round(echoDelayMs*1e-3*Fs));
wetEcho = filter(1, [1 zeros(1,D-1) -echoFB], orig);
echoOut = (1-echoMix)*orig + echoMix*wetEcho;

% Flanger (fast integer delay)
N = length(orig);
n = (0:N-1)';
baseD  = flangeBaseDelayMs*1e-3*Fs;
depthD = flangeDepthMs*1e-3*Fs;
d = round(baseD + depthD*sin(2*pi*flangeLfoHz*n/Fs));
d(d<0) = 0;

flangeDelaySig = zeros(N,1);
for ii = 1:N
    jj = ii - d(ii);
    if jj >= 1
        flangeDelaySig(ii) = orig(jj);
    end
end
flangeWet = orig + flangeDelaySig;
flangeOut = (1-flangeMix)*orig + flangeMix*flangeWet;

% Reverb (feedback tail + multitap)
dk = round(revDelaysMs*1e-3*Fs); dk(dk<1)=1;
Dmax = max(dk);
tail = filter(1, [1 zeros(1,Dmax-1) -revFB], orig);

reverbOut = orig;
for k = 1:numel(dk)
    Dk = dk(k);
    reverbOut(Dk+1:end) = reverbOut(Dk+1:end) + revGains(k)*tail(1:end-Dk);
end

%% Normalize + Save WAVs (10 seconds each)
origW   = norm_audio(orig);
echoW   = norm_audio(echoOut);
flangeW = norm_audio(flangeOut);
reverbW = norm_audio(reverbOut);

audiowrite("part3_original_10s.wav", origW, Fs);
audiowrite("part3_echo_10s.wav",     echoW, Fs);
audiowrite("part3_flange_10s.wav",   flangeW, Fs);
audiowrite("part3_reverb_10s.wav",   reverbW, Fs);

disp("Saved:");
disp("  part3_original_10s.wav");
disp("  part3_echo_10s.wav");
disp("  part3_flange_10s.wav");
disp("  part3_reverb_10s.wav");

%% ========== Step-by-step: plot + play ==========
stepPlotAndPlay(orig,   origW,   Fs, t, "ORIGINAL (Clean/Input)", "k", plotFull10Sec);
stepPlotAndPlay(echoOut, echoW,  Fs, t, "ECHO Output",           "b", plotFull10Sec);
stepPlotAndPlay(flangeOut, flangeW, Fs, t, "FLANGE Output",      "b", plotFull10Sec);
stepPlotAndPlay(reverbOut, reverbW, Fs, t, "REVERB Output",      "b", plotFull10Sec);

%% Optional overlay plot (loudest 2 seconds) for report screenshots
if overlayLoudest2Sec
    plotOverlayLoudest(orig, echoOut, flangeOut, reverbOut, Fs, overlayWindowSec);
end

disp("PART 3 COMPLETE.");
end

%% ===== helpers =====
function stepPlotAndPlay(yRaw, yPlay, Fs, t, titleText, color, plotFull)
% Show the graph, then play the sound continuously.

figure("Name", titleText);
if plotFull
    plot(t, yRaw, color); grid on;
    xlabel("Time (s)"); ylabel("Amplitude");
    title(titleText);
else
    % If you ever want a shorter view:
    N = min(length(yRaw), round(2*Fs));
    plot(t(1:N), yRaw(1:N), color); grid on;
    xlabel("Time (s)"); ylabel("Amplitude");
    title([titleText " (first 2 seconds)"]);
end

drawnow; % make sure graph appears before playback

safePlayFull(yPlay, Fs, titleText);
end

function safePlayFull(x, Fs, label)
try
    dur = length(x)/Fs;
    fprintf("Playing %s (%.2f s) ...\n", label, dur);
    sound(x, Fs);
    pause(dur + 0.25);  % wait until finished (continuous playback)
catch ME
    warning("Playback failed for %s: %s", label, ME.message);
    disp("Download and listen to the saved WAV files locally.");
end
end

function y = norm_audio(x)
y = x ./ (max(abs(x)) + 1e-12);
end

function plotOverlayLoudest(orig, echoOut, flangeOut, reverbOut, Fs, winSec)
% Overlay plot on loudest region so differences are easy to see
N = length(orig);
win = max(32, round(0.05*Fs));
rmsEnv = sqrt(movmean(orig.^2, win));
[~, idxMax] = max(rmsEnv);

overlayN = min(N, round(winSec*Fs));
s0 = max(1, idxMax - floor(overlayN/2));
s1 = min(N, s0 + overlayN - 1);
s0 = max(1, s1 - overlayN + 1);

tO = ((s0:s1)-1)/Fs;

figure("Name","Overlay (loudest region): Original vs Effects");
plot(tO, orig(s0:s1), "k", "LineWidth", 1.2); hold on;
plot(tO, echoOut(s0:s1),   "r");
plot(tO, flangeOut(s0:s1), "g");
plot(tO, reverbOut(s0:s1), "b");
grid on;
xlabel("Time (s)"); ylabel("Amplitude");
title("Overlay on loudest region (Original vs Echo vs Flange vs Reverb)");
legend("Original","Echo","Flange","Reverb");
end
