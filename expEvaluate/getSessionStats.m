function stats = getSessionStats(trials, headerStr, adjustedFalseAlarmRate)
%GETSESSIONSTATS calculates statistics for a detection experiment session.
%   Arguments:
%   trials - an array of trial structs
%   headerStr - the field name of the trial struct that identifies the
%       grouping factor
%   adjustedFalseAlarmRate - the adjusted false alarm rate for the
%       calculation of d' (output from getFalseAlarmStats())
%
%   Output:
%   A struct with the follwing fields:
%   header - the grouping factor value
%   num - the number of trials
%   hits - the number of hits
%   missings - the number of missing
%   hitRate - the hit rate
%   dPrime - d' statistic

% Author: Lasse Osterhagen

validateattributes(trials, {'struct'}, {'nonempty'}, 1);
validateattributes(headerStr, {'char'}, {'nonempty'}, 2);
validateattributes(adjustedFalseAlarmRate, {'numeric', 'scalar'}, ...
    {'positive'}, 3);

if ~isfield(trials, headerStr)
    error([headerStr, ' is not a field of trials.']);
end

header = unique([trials.(headerStr)])';
numGroups = length(header);
% Fill result arrays
num = zeros(numGroups, 1);
hits = zeros(numGroups,1);
missings = zeros(numGroups,1);

for index=1:numGroups
    trialGroup = trials([trials.(headerStr)]==header(index));
    num(index) = length(trialGroup);
    hits(index) = sum([trialGroup.Hit]);
    missings(index) = sum(~[trialGroup.Hit]);
end

hitRate = hits./num;

% Adjusted hit rate for calculation of d'
hitRateAdjusted = hitRate;
% Adjust hitRate==0
indices = find(hitRate == 0);
for e=1:length(indices)
    hitRateAdjusted(indices(e)) = 1/(2*num(e));
end
% Adust hitRate==1
indices = find(hitRate == 1);
for e=1:length(indices)
    hitRateAdjusted(indices(e)) = 1 - 1/(2*num(e));
end

% Calculate dPrime
zFalseAlarms = norminv(adjustedFalseAlarmRate, 0, 1);
% Calculate z values
zHits = norminv(hitRateAdjusted, 0, 1);

stats.header = header;
stats.num = num;
stats.hits = hits;
stats.missings = missings;
stats.hitRate = hitRate;
stats.dPrime = zHits - zFalseAlarms;
