function [stats, conditions] = getBlockedSessionStats(trials, headerStr, trialFilter)
%GETBLOCKEDSESSIONSTATSFROMLOG computes session statistics from an eventLog.
%   Arguments:
%   el - eventLog of a LogBook
%   headerStr - the field name of the trial struct that identifies the
%       grouping factor
%   trialFilter - optional: a function handle to a function that takes a
%       trial struct and returns logically true or false dependent on
%       whether the element should be included or not.
%
%   Returns:
%   stats - session statistics
%   conditions - nams of conditions (subset of fieldnames of stats)
%
%   This function does the same as getSessionStatFromLog(), for experiments
%   with multiple conditions in a blocked design.

% Author: Lasse Osterhagen

lbe = LogbookEvaluator(el);
trials = lbe.getTrials();
if nargin > 2
    % Filter trials
    if ~isempty(trialFilter)
        trials = trials(arrayfun(trialFilter, trials));
    end
end

classifiedTrials = classifyBlockedTrials(trials, lbe.getAudioObjects());
shamTrials = lbe.getShamTrials();
faStats = getFalseAlarmStats(shamTrials);

conditions = fieldnames(classifiedTrials)';

%stats = getSessionStats(trials, headerStr, faStats.adjustedFalseAlarmRate);
for fn = conditions
    stats.(fn{:}) = getSessionStats(classifiedTrials.(fn{:}), headerStr, faStats.adjustedFalseAlarmRate);
end

% Add false alarm statistics to output
stats.numShamTrials = faStats.numShamTrials;
stats.numFalseAlarms = faStats.numFalseAlarms;
stats.falseAlarmRate = faStats.falseAlarmRate;
