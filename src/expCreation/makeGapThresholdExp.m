function complete = makeGapThresholdExp(gapDurations, delays, trialFac, ...
    shamTrialFac)
%MAKEGAPTHRESHOLDEXP creates an experiment with gap stimuli.
%   Arguments (defaults in square brackets):
%   gapDurations - an array of the set of gap durations
%   delays - an array of the set of start delays [1.25:5.25]
%   trialFac - the multiplicator of trials [3]
%   shamTrialFac - the multiplicator of sham trials [5]:
%
%   The factors gapDurations and delays are completely crossed.
%   The total number of trials is equal to:
%       trialFac*length(gapDurations)*length(delays).
%   The total number of sham trials is equal to:
%       shamTrialfac*length(delays).
%   numTrials = trialFac*length(gapDuration)*length(delays)

% Author: Lasse Osterhagen

if nargin < 4
    shamTrialFac = 5;
end
if nargin < 3
    trialFac = 3;
end
if nargin < 2
    delays = 1.25:5.25;
end

rng('shuffle');

trials = createGapStimuli(gapDurations, delays, trialFac);
shamTrials = createShamTrials(delays, shamTrialFac);

% Trials and sham trials together
complete = [trials, shamTrials];
complete = complete(randperm(length(complete))); % shuffle

% Assing ids
ids = num2cell(1:length(complete));
[complete.id] = ids{:};
