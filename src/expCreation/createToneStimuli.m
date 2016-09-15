function trials = createToneStimuli(frequency, duration, levels, delays, repFactor)
%CREATETONESTIMULI creates an array of tone stimuli.
%   All tone stimuli have the same frequency and duration. Tone levels and
%   start delays vary by completely crossing these factors.
%
%   Arguments:
%   frequency - the frequency of the tones
%   duration - tone duration
%   levels - an array of tone levels
%   delays - an array of start delays [default: 1.25:5.25]
%   repFactor - replication factor [default: 1]
%   
%   The total number of stimuli will be
%   length(levels)*length(delays)*repFactor.
%   Attention: the output trials will be sorted. It is recommended to use
%   randperm() on the output array. Furthermore, the id of the stimuli is set
%   to 0.

% Author: Lasse Osterhagen

if nargin < 5
    repFactor = 1;
end
if nargin < 4
    delays = 1.25:5.25;
end

% Create all possible combinations between gap durations and
% startDelays.
[p,q] = meshgrid(delays, levels);
pairs = [p(:), q(:)];
pairs = repmat(pairs, repFactor, 1);

% Create stimulus array
packedTrials = arrayfun(@(x,y) ToneStimulus(0, x, 'duration', duration, ...
    'frequency', frequency, 'level', y), ...
    pairs(:,1), pairs(:,2), 'UniformOutput', false);
trials = [packedTrials{:}];
