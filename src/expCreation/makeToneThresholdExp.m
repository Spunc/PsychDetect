function complete = makeToneThresholdExp(frequency, duration, levels, ...
    delays, trialFac, shamTrialFac)
%MAKETONETHRESHOLDEXP creates an experiment with tone stimuli.
%   Arguments (defaults in square brackets):
%   frequency - the frequency of the tones
%   duration - tone duration
%   levels - an array of tone levels
%   delays - an array of the set of start delays [1.25:5.25]
%   trialFac - the multiplicator of trials [3]
%   shamTrialFac - the multiplicator of sham trials [5]:
%
%   The factors level and delays are completely crossed.
%   The total number of trials is equal to:
%       trialFac*length(level)*length(delays).
%   The total number of sham trials is equal to:
%       shamTrialfac*length(delays).

% Author: Lasse Osterhagen

if nargin < 6
    shamTrialFac = 5;
end
if nargin < 5
    trialFac = 3;
end
if nargin < 4
    delays = 1.25:5.25;
end

rng('shuffle');

trials = createToneStimuli(frequency, duration, levels, delays, trialFac);
shamTrials = createShamTrials(delays, shamTrialFac);

% Trials and sham trials together
complete = [trials, shamTrials];
complete = complete(randperm(length(complete))); % shuffle

% Assing ids
ids = num2cell(1:length(complete));
[complete.id] = ids{:};
