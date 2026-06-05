## Team Members

- Shabnam Kabaran
- Bahar Moghimi
- Ali Mohammadnezhad
- Leila Azinfar
- Kiana Rahimi
- Hoda Orouji
_______________________________________________________
# README — EEG Preprocessing, Eye-Closed Extraction, and Trial Analysis

This project is designed for EEG preprocessing, adding channel locations and event markers, filtering the signal, removing bad channels, running ICA, extracting **eyes-closed** segments, and building trial-based matrices.

---

## Files

### 1) `preproccess and midle matrix.mlx`

This is the Live Script version of the project and is used for running analysis steps and visualizing results. It typically includes tasks such as:

* reading processed data
* computing trial durations
* separating the first trial, middle trials, and the last trial
* building `middleMatrix`
* plotting trial-duration statistics
* finding the shortest trial for each subject

> Note: the filename in the project is written as `preproccess and midle matrix.mlx`, but it is better to rename it to something more standard such as `preprocess_and_middle_matrix.mlx`.

### 2) `finalextractEyeClosed.m`

This file contains the main function for extracting eyes-closed intervals. The function finds the event code you specify, extracts each segment, trims or pads them to a fixed length, and returns a 3D matrix.

The function is intended to be used like this:

```matlab
[finalMatrix, extractedTrials, rejTimes, EEGclean] = extractEyeClosedTrials(EEG,65,4000);
```

However, inside the code, the function is defined as:

```matlab
function [finalMatrix, extractedTrials, EyeClosedTimes, EEGclean] = finalextractEyeClosedTrials(EEG, type, numSamples)
```

> Important: the file name, function name, and function call should match. If the file is named `finalextractEyeClosed.m`, the function name should match that file name exactly.

### 3) `plot duration by trial`

This section reads trial durations from `SubAll.docx` and plots the mean ± standard deviation of trial durations across the following groups:

* First trial
* Middle trials (binned in groups of 5)
* Last trial

### 4) `shortest time`

This section finds the shortest trial duration for each subject and reports subjects whose shortest trial is above or below a chosen threshold (for example, 1000 samples).

---

## Requirements

To run this project, you need:

* **MATLAB**
* **EEGLAB**
* EEGLAB functions/plugins such as:

  * `pop_biosig`
  * `pop_chanedit`
  * `pop_eegfiltnew`
  * `pop_runica`
  * `pop_iclabel`
  * `pop_subcomp`
  * `pop_saveset`
  * `pop_loadset`
  * `pop_select`
* Channel location file: `standard_1005.elc`
* Event file: `*_events.tsv`
* Helper files created during the workflow:

  * `electrode_locations.mat`
  * `loc57.mat`
  * `*_ica_removal_summary.txt`
  * `*_finalMatrix.mat`
  * `*_middle_matrix.mat`

---

## Inputs

### Raw data

* EEG file in `.edf` format

### Event file

* `*_events.tsv`, where events include `value` and `sample`

### Supporting files

* Channel-location definitions
* List of bad channels
* `SubAll.docx` for trial-duration analysis

---

## Outputs

This pipeline typically generates the following files:

* `*_withEventsLoc.set`
* `*_with1HzFilt.set`
* `*_with1and40HzFilt.set`
* `*_no_bad_channels.set`
* `*_cleaned_after_ica.set`
* `*_finalMatrix.mat`
* `*_middle_matrix.mat`
* `*_ica_removal_summary.txt`
* `ClosedEye_ERPStyle_step12.set`
* Separate trial files such as: `*_trial2.newset`, `*_trial3.newset`, ...

---

## Recommended Workflow

### Step 1: Load the EDF file and define channels

* The EDF file is searched in the current folder and subfolders.
* Channel locations are created from the `data_string` block.
* Only the 62 target channels are kept.

### Step 2: Add event markers

* The `*_events.tsv` file is read.
* `value` and `sample` are mapped to `type` and `latency`.
* The event structure is assigned to `EEG.event`.

### Step 3: Save the initial dataset

* The dataset is saved with a name such as `sub-CBM00002_withEventsLoc.set`.

### Step 4: Filter the data

* Apply a 1 Hz high-pass filter
* Apply a 40 Hz low-pass filter

### Step 5: Remove bad channels

* Bad channels are removed by index.
* `loc57.mat` is saved afterward.

### Step 6: Run ICA and ICLabel

* ICA is computed.
* Artifact components are identified with ICLabel.
* Noisy components are removed.
* A summary of the removed components is saved to a text file.

### Step 7: Extract eyes-closed trials

* Event code `65` is treated as the eyes-closed marker.
* Each segment length is measured.
* `finalMatrix` is created.
* The extracted data is saved in a `.mat` file.

### Step 8: Save separate trials and create an ERP-style dataset

* Individual trials are saved separately.
* `middleMatrix` is used to build the final ERP-style dataset.

---

## Function: `finalextractEyeClosedTrials`

### Inputs

* `EEG`: full EEG data structure
* `type`: event code for eyes closed, default `65`
* `numSamples`: fixed length of each segment, default `4000`

### Outputs

* `finalMatrix`: 3D matrix with dimensions `[trial × channel × sample]`
* `extractedTrials`: raw segments stored in a cell array
* `EyeClosedTimes`: start/end sample indices for each segment
* `EEGclean`: EEG dataset after removing the eye-closed segments

### What it does

1. Finds events with the selected code.
2. Builds a start/end window for each segment.
3. Removes those windows from the EEG data.
4. Extracts each segment.
5. Trims or pads all segments to the same length.
6. Stacks the result into a 3D matrix.

---

## Trial-Duration Plot Section

This section reads `SubAll.docx`, extracts trial durations for each subject, and then:

* separates the first trial
* groups middle trials into bins of 5
* keeps the last trial separate
* plots the mean and standard deviation

---

## Shortest-Time Section

This section:

* finds the shortest trial for each subject
* prints subjects whose shortest trial is below 1000 samples
* lists subjects with the smallest trials above 1000 samples
* reports the shortest trial in the whole dataset

---

## Important Notes

1. **The function name and file name must match.**

   * If the function is `finalextractEyeClosedTrials`, the filename should match it exactly.

2. **The `*_events.tsv` file must be available in the expected folder.**

3. **After removing channels, always check `chanlocs` again.**

4. **Do not change `chanlocs` after running ICA unless you know exactly why.**

5. **`middleMatrix` requires at least 3 trials** so that the first and last trials can be removed.

6. **The trial-file naming pattern must match the loading pattern** used by `dir(fullfile(dataFolder, '*_trial*.set'))`.

---

## Suggested Project Structure

For better organization, the files can be arranged like this:

```text
project/
│
├── scripts/
│   ├── preprocess_and_middle_matrix.mlx
│   ├── finalextractEyeClosed.m
│   ├── plot_duration_by_trial.m
│   └── shortest_time.m
│
├── data/
│   ├── raw/
│   ├── processed/
│   └── events/
│
├── outputs/
│   ├── .set files
│   ├── .mat files
│   └── logs/
│
└── README.md
```

---

## Example Usage

```matlab
% Extract eye-closed segments
[finalMatrix, extractedTrials, EyeClosedTimes, EEGclean] = finalextractEyeClosedTrials(EEG, 65, 1000);

% Save the output
save('subject01_finalMatrix.mat', 'finalMatrix', 'extractedTrials', 'EEGclean');
```

---

## Summary

This project provides a full EEG preprocessing pipeline for eyes-closed analysis. The final output includes cleaned data, extracted trials, a 3D trial matrix, and files prepared for further analysis.
