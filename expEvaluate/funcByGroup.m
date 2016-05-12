function [out, groups] = funcByGroup(values, grouping, func)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

groups = unique(grouping);
numGroups = length(groups);
out = zeros(numGroups, 1);

for index = 1:numGroups
    group = groups(index);
    if iscell(grouping)
        selectIdx = cellfun(@(x) isequal(group{:}, x), grouping);
    else
        selectIdx = grouping == group;
    end
    selectVals = values(selectIdx);
    out(index) = func(selectVals);
end
