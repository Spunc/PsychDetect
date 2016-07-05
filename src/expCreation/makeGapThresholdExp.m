function complete = makeGapThresholdExp(gapDurations, delays, trialFac, ...
    shamTrialFac)
%MAKEGAPTHRESHOLDEXP creates an experiment with gap stimuli.
% Arguments:
% gapDurations - an array of the set of gap durations
% delays - an array of the set of start delays [1.25:5.25]
% trialFac - the multiplicator of trials [3]:
%   numTrials = trialFac*length(gapDuration)*length(delays)
% shamTrialFac - the multiplicator of sham trials [5]:
%   numShamTrials = shamTrialFac*length(delays)

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
