function stats = getSessionStatsFromLog(el, headerStr, trialFilter)
%GETSESSIONSTATSFROMLOG computes session statistics from a eventLog.
%   Arguments:
%   el - eventLog of a LogBook
%   trialFilter - optional: a function handle to a function that takes a
%       trial struct and returns logically true or false dependent on
%       whether the element should be included or not.

% Author: Lasse Osterhagen

lbe = LogbookEvaluator(el);
trials = lbe.getTrials();
if nargin > 2
    % Filter trials
    if ~isempty(trialFilter)
        trials = trials(arrayfun(trialFilter, trials));
    end
end
shamTrials = lbe.getShamTrials();
faStats = getFalseAlarmStats(shamTrials);

stats = getSessionStats(trials, headerStr, faStats.adjustedFalseAlarmRate);

% Add false alarm statistics to output
stats.numShamTrials = faStats.numShamTrials;
stats.numFalseAlarms = faStats.numFalseAlarms;
stats.falseAlarmRate = faStats.falseAlarmRate;
