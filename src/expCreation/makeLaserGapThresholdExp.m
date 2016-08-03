function [exp1, exp2] = makeLaserGapThresholdExp(gapDurations, delays, trialFac, ...
    shamTrialFac)
%MAKELASERGAPEXP creates an experiment with gap stimuli and intervined
%laser stimulation.
%   Arguments (defaults in square brackets):
%   gapDurations - an array of the set of gap durations
%   delays - an array of the set of start delays [1.25:5.25]
%   trialFac - the multiplicator of trials [3]
%   shamTrialFac - the multiplicator of sham trials [5]:

% Author: Lasse Osterhagen

if nargin < 4
    shamTrialFac = 5;
end
if nargin < 3
    trialFac = 2;
end
if nargin < 2
    delays = 1.25:5.25;
end

rng('shuffle');

% Create prototype LaserBlockCtrl AudioObjects
blueLaserAmp = .5;
blueLaser = LaserBlockCtrl('b', 2, 2, blueLaserAmp);
yellowLaser = LaserBlockCtrl('y', 3, 5, 1);

trialSet = createGapStimuli(gapDurations, delays, trialFac);
setLength = length(trialSet);
assert(mod(setLength,2) == 0, 'Trial set length must be even.');

set1 = trialSet(randperm(setLength));
set1 = reshape(set1, 2, setLength/2);
set2 = trialSet(randperm(setLength));
set2 = reshape(set2, 2, setLength/2);

exp1 = ...
    [blueLaser, set1(1,:), ...
    yellowLaser, set2(1,:), ...
    blueLaser, set1(2,:), ...
    yellowLaser, set2(2,:)];

exp2 = ...
    [set1(1,:), ...
    blueLaser, set2(1,:), ...
    yellowLaser, set1(2,:), ...
    blueLaser, set2(2,:), ...
    yellowLaser];

% Sham trials
shamTrials = createShamTrials(delays, shamTrialFac);
shamTrials = shamTrials(randperm(length(shamTrials)));
% Insert sham trials into experiment arrays
totalArraySize = length(exp1)+length(shamTrials);
shamTrialIndex = 1;
while length(exp1) < totalArraySize
    insertIndex = randi([2, length(exp1)-1]);
    exp1 = [exp1(1:insertIndex-1), shamTrials(shamTrialIndex), ...
        exp1(insertIndex:end)];
    exp2 = [exp2(1:insertIndex-1), shamTrials(shamTrialIndex), ...
        exp2(insertIndex:end)];
    shamTrialIndex = shamTrialIndex+1;
end
assert(shamTrialIndex == length(shamTrials)+1);

% Create ids
id = 1;
for index=1:length(exp1)
    if isnumeric(exp1(index).id)
        exp1(index).id = num2str(id);
        id = id+1;
    end
end

id = 1;
for index=1:length(exp2)
    if isnumeric(exp2(index).id)
        exp2(index).id = num2str(id);
        id = id+1;
    end
end

end