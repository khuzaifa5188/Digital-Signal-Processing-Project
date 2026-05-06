<!--
  Digital Signal Processing Project
  Professional README (HTML-enhanced) — includes overview, files, usage, and troubleshooting.
-->

<h1>Digital Signal Processing Project</h1>

<p><strong>MATLAB</strong> repository demonstrating offline signal processing (filter design, noise, and time-domain effects) and a real-time graphic equalizer example. This project collects coursework-style tasks into runnable scripts and helpers so readers can reproduce, listen to, and visualize audio processing results.</p>

<hr/>

<h2>Project Overview</h2>

<ul>
  <li><strong>Task 1 / Part A</strong> — offline filtering: AWGN, low-pass filter design and application, notch filter, short-time plots and WAV exports.</li>
  <li><strong>Task 2 / Part B</strong> — real-time 10-band graphic equalizer (separate function using <code>audioDeviceReader</code>, <code>audioDeviceWriter</code>, and <code>graphicEQ</code>).</li>
  <li><strong>Task 3</strong> — audio effects (echo, flanger, reverb): both short demonstration plots and a 10-second step-by-step play + plots routine with WAV exports.</li>
</ul>

<hr/>

<h2>Key Files</h2>

<ul>
  <li><a href="DSP_Project_All_Tasks.m">DSP_Project_All_Tasks.m</a> — consolidated driver script with flags to run Task 1, Task 2 (real-time EQ), and Task 3 variants.</li>
  <li><a href="task1_partA_complete_v2.m">task1_partA_complete_v2.m</a> — Task 1 standalone script (filtering & notch demo).</li>
  <li><a href="task2_partB_realtime_10band_eq.m">task2_partB_realtime_10band_eq.m</a> — real-time 10-band graphic equalizer (use with audio devices).</li>
  <li><a href="part3_voice_step_by_step_play_and_plots.m">part3_voice_step_by_step_play_and_plots.m</a> — Part 3: 10s play, plot, and save WAVs for Original, Echo, Flange, Reverb.</li>
  <li><a href="/">recorded_full.wav</a> (expected) — input recording required in repository root for offline examples.</li>
</ul>

<hr/>

<h2>Requirements</h2>

<ul>
  <li>MATLAB (R2019b or later recommended).</li>
  <li>MATLAB Audio Toolbox for: <code>audioinfo</code>, <code>audioread</code>, <code>audiowrite</code>, <code>sound</code>, <code>audioDeviceReader</code>, <code>audioDeviceWriter</code>, and <code>graphicEQ</code>.</li>
  <li>An audio input device (microphone or line-in) and output device (speakers/headphones) when using real-time features.</li>
</ul>

<hr/>

<h2>Quick Start</h2>

<ol>
  <li>Place your input file <code>recorded_full.wav</code> in the project root (same folder as the scripts).</li>
  <li>Open MATLAB and set the Current Folder to this repository.</li>
  <li>Run the consolidated driver to execute desired parts:
    <pre><code>DSP_Project_All_Tasks</code></pre>
    Toggle the flags at the top of the script to enable/disable Task 2 realtime execution.
  </li>
  <li>Alternatively, run single helpers directly (examples):
    <ul>
      <li><code>task1_partA_complete_v2</code> — run Task 1 only.</li>
      <li><code>task2_partB_realtime_10band_eq</code> — start real-time EQ (set <code>runTask2Realtime</code> true in the driver to call it).</li>
      <li><code>part3_voice_step_by_step_play_and_plots</code> — produces WAVs and plays/plots the 10s effects sequence.</li>
    </ul>
  </li>
</ol>

<hr/>

<h2>Outputs</h2>

<p>Scripts save WAV files and open figures for inspection. Typical output files include (but are not limited to):</p>

<ul>
  <li><code>task1_clean_seg.wav</code>, <code>task1_noisy_seg.wav</code>, <code>task1_lpf_filtered_seg.wav</code>, <code>task1_notch_filtered_seg.wav</code></li>
  <li><code>part3_original_10s.wav</code>, <code>part3_echo_10s.wav</code>, <code>part3_flange_10s.wav</code>, <code>part3_reverb_10s.wav</code></li>
</ul>

<hr/>

<h2>Real-time EQ Notes (Task 2)</h2>

<p>The real-time 10-band equalizer uses MATLAB's <code>audioDeviceReader</code> and <code>audioDeviceWriter</code> to read and play audio frames while applying a <code>graphicEQ</code> object. This code is intended for local MATLAB desktop environments with access to audio devices; MATLAB Online may not support device access reliably.</p>

<ul>
  <li>If you enable the real-time flag in <code>DSP_Project_All_Tasks.m</code>, ensure your default input/output devices are configured in the OS.</li>
  <li>To list devices on supported systems, un-comment or run <code>daq.getDevices</code> inside the EQ script.</li>
</ul>

<hr/>

<h2>Troubleshooting & Tips</h2>

<ul>
  <li><strong>Missing input file:</strong> Place a WAV named <code>recorded_full.wav</code> in the project root or update the script path variables.</li>
  <li><strong>Playback fails in MATLAB Online:</strong> Scripts save WAVs — download them for local listening.</li>
  <li><strong>Real-time glitches:</strong> Try increasing <code>frameSize</code> in the EQ script or reducing figure update frequency (higher <code>plotEveryNFrames</code>).</li>
  <li><strong>Different sample rate:</strong> The scripts attempt to use the file's sample rate; set <code>Fs</code> explicitly in scripts if desired.</li>
</ul>

<hr/>

<h2>Next Steps</h2>

<ul>
  <li>Enable <code>runTask2Realtime</code> in <a href="DSP_Project_All_Tasks.m">DSP_Project_All_Tasks.m</a> and test the real-time EQ on a local machine with audio devices.</li>
  <li>Add README screenshots or short GIFs of the visualizations to help readers quickly see expected results.</li>
</ul>

<hr/>

<p>If you want, I can (choose one):</p>

<ul>
  <li>Enable <code>runTask2Realtime</code> by default in the driver.</li>
  <li>Run a quick existence and sample-rate check for <code>recorded_full.wav</code> and report back.</li>
  <li>Include example plots/images embedded in this README.</li>
</ul>

<p><em>Prepared by the project assistant — update the files or settings to match your local environment before running real-time features.</em></p>
