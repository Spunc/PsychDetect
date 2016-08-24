function [classifiedTrials, classNames] = classifyBlockedTrials(trials, audioObjects)
%CLASSIFYBLOCKEDTRIALS classifies trials by enclosing AudioObjects.
%   Arguments:
%   trials - an array of trials
%   audioObjects - an array of non-trial AudioObjects
%
%   Returns:
%   classifiedTrials - a cell column with each cell containing an array of
%       trials that belong to the same condition.
%   classNames - class labels for each cell row of classifiedTrials
%
%   The function can be used for experiments with more than one condition,
%   if the conditions are arranged in a blocked design and the blocks are
%   marked by enclosing AudioObjects. Those AudioObjects can be for example
%   laser stimulation.
%   The trials will be classified by the IDs of the enclosing AudioObjects.
%   Trials that are played before any of those AudioObjects were played,
%   will be classified under 'none'.

% Author: Lasse Osterhagen

classes = {'none' audioObjects.ID}; % none is for trials before first audio object
classNames = unique(classes);
classifiedTrials = cell(length(classNames), 1);
%classifiedTrials = cell2struct(cell(1, length(uniqueClasses)), uniqueClasses, 2);
timePoints = [0, [audioObjects.NewTrial], realmax];
trialTimes = [trials.NewTrial];
for index = 1:length(timePoints)-1
    classIdx = find(strcmp(classes(index), classNames));
    classifiedTrials{classIdx} = [classifiedTrials{classIdx}, ...
        trials(trialTimes > timePoints(index) & ...
        trialTimes < timePoints(index+1))];
end
