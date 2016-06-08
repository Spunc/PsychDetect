function stats = getFalseAlarmStats(shamTrials)
%GETFALSEALARMSTATS calculates the false alarm rate from sham trials.
%   Arguments:
%   shamTrials - a struct array with all sham trials
%   Output:
%   A struct with the following fields:
%       falseAlarmRate - the true false alarm rate
%       adjustedFalseAlarmRate - an adjusted value for the false alarm rate
%           in the case that the true false alarm rate is zero - needed for
%           the calculation of d'.
%       numShamTrials - the number of sham trials
%       numFalseAlarms - the number of false alarms.

% Author: Lasse Osterhagen

validateattributes(shamTrials, {'struct'}, {'nonempty'});

stats.numShamTrials = length(shamTrials);
stats.numFalseAlarms = sum([shamTrials.FalseAlarm]);
stats.falseAlarmRate = stats.numFalseAlarms/stats.numShamTrials;
n = length(shamTrials);

if stats.falseAlarmRate == 0
    stats.adjustedFalseAlarmRate = 1/(2*n);
elseif stats.falseAlarmRate == 1
    stats.adjustedFalseAlarmRate = 1 - 1/(2*n);
else
    stats.adjustedFalseAlarmRate = stats.falseAlarmRate;
end
