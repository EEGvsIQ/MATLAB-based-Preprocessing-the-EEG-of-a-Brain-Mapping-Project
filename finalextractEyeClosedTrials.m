

%run with:   [finalMatrix, extractedTrials, rejTimes, EEGclean] = extractEyeClosedTrials(EEG,65,4000);


%----1......................................................................

function [finalMatrix, extractedTrials, EyeClosedTimes, EEGclean] = finalextractEyeClosedTrials(EEG, type, numSamples)
% extractEyeClosedTrials  Extracts and removes segments around specified events
%
%Inputs:
%EEG – your full EEG dataset structure.
%eventValue – the trigger code you want to find (e.g. 65 for "eyes closed").
%numSamples – how many data points you want from each extracted segment.
%Outputs:
%finalMatrix – a 3D array of all trials, channels, and samples (trimmed/padded).
%extractedTrials – a cell array of the raw segments you removed.
%EyeClosedTimes – start/end sample indices for each segment.
%EEGclean – the EEG dataset after removing those segments.

%.....2...........................................................................

% Defaults
if nargin < 2 || isempty(type), type = 65; end
if nargin < 3 || isempty(numSamples), numSamples = 4000; end

%If didn’t provide eventValue or numSamples, these lines set defaults:
%eventValue = 65
%numSamples = 4000


fs     = EEG.srate;
%sample rate
nPts   = EEG.pnts;
%time points
data   = EEG.data;
%channels × time
events = EEG.event;
%each has a value and a sample


%.....3.............................................................................
% Find event onsets
closedRows = find([events.type] == type);
numTrials  = numel(closedRows);

%find 65
%Find the positions
%Count how many



%.....4.............................................................................
% Preallocate closed time windows
EyeClosedTimes = zeros(numTrials,2);
for i = 1:numTrials
    r = closedRows(i);
    startS = events(r).latency;
    if r < numel(events)
        endS = events(r+1).latency - 1;
    else
        endS = nPts;
    end
    EyeClosedTimes(i,:) = [startS endS];
end

%Build a table (EyeClosedTimes) of start and end sample numbers for each eye-closed segment
%Store [startS endS] in row i of EyeClosedTimes.







%....6.............................................................................
% Remove these segments from the EEG dataset
% pop_select('point',EyeClosedTimes) uses sample indices for removal
EEGclean = pop_select(EEG, 'point', EyeClosedTimes)

%Calls EEGLAB’s pop_select to delete all the sample ranges in EyeClosedTimes from the EEG data.
%Result: EEGclean is your EEG dataset with those eye-closed segments removed.


%....7.............................................................................

% attempt to store back into ALLEEG & refresh GUI if present
try
    [ALLEEG, EEGclean] = eeg_store(ALLEEG, EEGclean, CURRENTSET);
    eeglab redraw;
catch
    % ALLEEG not in scope, skip
end

% If you’re running inside the EEGLAB GUI, this puts EEGclean back into the global dataset array (ALLEEG) and refreshes the GUI.


%.....8..................................................................

% Extract each trial segment and compute duration
extractedTrials = cell(numTrials,1);
durations       = zeros(numTrials,1);
for i = 1:numTrials
    s   = EyeClosedTimes(i,1);
    e   = EyeClosedTimes(i,2);
    seg = data(:, s:e);
    extractedTrials{i} = seg;
    durations(i)    = size(seg,2) / fs;
end
fprintf('Removed %d segments (total %.1f s; min length %.2f s)\n', ...
    numTrials, sum(EyeClosedTimes(:,2)-EyeClosedTimes(:,1))/fs, min(durations))

%Save each removed segment in raw form and measure how long each one was.
%seg slices out data(:, s:e)—all channels, those time-points



%.....9.................................................................

% Trim or pad to numSamples
trimmed = cell(numTrials,1);
%Make a new cell array called trimmed to hold each fixed-length trial.
for i = 1:numTrials
    seg  = extractedTrials{i};
%Take the ith trial segment (a matrix of channels × samples) and store it in seg.
    tlen = size(seg,2);
%Find out how many samples (columns) are in this segment.
%seg is a matrix: channels × time.
%size(seg,2) gives the number of time points (samples) in this segment.


    if tlen >= numSamples
        trimmed{i} = seg(:,1:numSamples);
%if this segment has enough samples or more, take the first numSamples of it and store that in trimmed{i}.
    else
        pad           = zeros(size(seg,1), numSamples);
        pad(:,1:tlen) = seg;
        trimmed{i}    = pad;
    end
end
%If the segment is too short:Make a blank zero-filled matrix (pad) that’s the right size: same number of channels, but numSamples long.



%....10...................................................................
% Build 3D matrix: [trials x channels x samples]
temp3d      = cat(3, trimmed{:}); %[channels × numSamples × nTrials] array
finalMatrix = permute(temp3d, [3, 1, 2]);  % [nTrials × channels × numSamples]

end

%cat(3, ...) stacks them along the third dimension → channels × samples × trials
%permute(..., [3 1 2]) reorders dimensions to trials × channels × samples, the common format for trial-based analyses.
