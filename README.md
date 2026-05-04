# Digital Signal Processing Project

MATLAB project for a DSP assignment covering offline filtering and audio effects.

## Project Status

Current implementation:

- Part A: implemented
- Part C: implemented
- Part B: not yet implemented in the current codebase

The repository is accurate for the code that is currently present. If you need the full assignment, Part B still needs to be added.

## Files

- [DSP_Project_All_Tasks.m](DSP_Project_All_Tasks.m): Main script that runs Part A and Part C.
- [task1_partA_complete_v2.m](task1_partA_complete_v2.m): Earlier standalone Task 1 / Part A script.

## Requirements

The scripts expect these MATLAB capabilities and files:

- `recorded_full.wav` in the same folder as the script.
- MATLAB Audio Toolbox for `audioinfo`, `audioread`, `audiowrite`, `sound`, and filter design tools.
- A working audio device if you want to listen to playback.

## What the Code Does

### Part A - Basic Filtering on a Recorded Signal

The main script:

- Loads `recorded_full.wav`.
- Selects a 10-second segment.
- Converts the signal to mono and normalizes it.
- Designs a low-pass filter with `designfilt`.
- Shows the LPF response with `fvtool`.
- Adds white Gaussian noise to the clean segment.
- Applies the LPF to denoise the noisy signal.
- Plots a short section of the clean, noisy, and filtered signals.
- Designs and applies a notch filter to remove one chosen frequency.
- Saves the processed audio as WAV files.

Outputs from Part A:

- `task1_clean_seg.wav`
- `task1_noisy_seg.wav`
- `task1_lpf_filtered_seg.wav`
- `task1_notch_filtered_seg.wav`

### Part C - Echo, Flange, and Reverb

The same script also demonstrates:

- Echo
- Flange
- Reverb

For each effect, the script:

- Processes the selected audio segment.
- Plots a short window of the original and processed signal.
- Saves the processed output as a WAV file.

Outputs from Part C:

- `part3_original_10s.wav`
- `part3_echo_10s.wav`
- `part3_flange_10s.wav`
- `part3_reverb_10s.wav`

## How to Run

Open MATLAB in this folder and run:

```matlab
DSP_Project_All_Tasks
```

If you want to test the older Part A-only version, run:

```matlab
task1_partA_complete_v2
```

## Notes

- The current Part A implementation uses an offline recorded signal, not live microphone input.
- The current code does not include the 10-band real-time graphic equalizer from Part B.
- If you add Part B later, the README should be updated to document the real-time audio device workflow.