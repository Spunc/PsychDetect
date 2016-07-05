function trials = createGapStimuli(gapDurations, delays, repFactor)
%CREATEGAPSTIMULI creates an array of gap stimuli.
% Arguments:
% gapDuration - an array of gap durations 
% delays - an array of delays [default: 1.25:5.25]
% repFactor - replication factor
%
% The factors gapDurations and delays are completely crossed. Thus,
% length(gapDurations)*length(delays) different stimuli will be created.
% The total number of stimuli will be
% length(gapDurations)*length(delays)*repFactor.
% Attention: the output trials will be sorted. It is recommended to use
% randperm() on the output array. Furthermore, the id of the stimuli is set
% to 0.

if nargin < 3
    repFactor = 1;
end
if nargin < 2
    delays = 1.25:5.25;
end

% Create all possible combinations between gap durations and
% startDelays.
[p,q] = meshgrid(delays, gapDurations);
pairs = [p(:), q(:)];
pairs = repmat(pairs, repFactor, 1);

% Create stimulus array
packedTrials = arrayfun(@(x,y) GapStimulus(0, x, 'duration', y), ...
    pairs(:,1), pairs(:,2), 'UniformOutput', false);
trials = [packedTrials{:}];
